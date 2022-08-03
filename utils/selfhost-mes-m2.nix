{ mes-m2, catm, mkdir, cp
, runCommandKaem, fetchFromGitHub
, lib
}:
# buildSteps:

with lib;

let
  module =
    { config, ... }:
    let
      buildSteps = config.buildSteps;
      buildInputs = config.buildInputs;
    in
      {
        options = {
          buildSteps = mkOption {
            description = "buildSteps";
            type = types.listOf (types.submodule
              {
                options = {
                  cd = mkOption {
                    description = "cd into directory.";
                    type = with types; nullOr (oneOf [ package str ]);
                    default = null;
                  };
                } // {
                  catm = mkOption {
                    description = "Run catm.";
                    type = types.bool;
                    default = false;
                  };

                  files = mkOption {
                    description = "Which files to concatenate.";
                    type = with types; listOf str;
                    default = [];
                  };

                  outputFile = mkOption {
                    description = "Into which file to concatenate.";
                    type = with types; str;
                  };
                } // {
                  mes-m2 = mkOption {
                    description = "Run mes-m2.";
                    type = types.bool;
                    default = false;
                  };

                  sourceFiles = mkOption {
                    description = "Files which to compile.";
                    type = with types; listOf str;
                  };

                  includeDirectories = mkOption {
                    description = "Directories to include.";
                    type = with types; listOf str;
                    default = [];
                  };

                  defines = mkOption {
                    description = "Define directives.";
                    type = with types; attrsOf str;
                    default = {};
                  };
                } // {
                  mkdir = mkOption {
                    description = "Run mkdir.";
                    type = types.bool;
                    default = false;
                  };

                  directories = mkOption {
                    description = "Directories to create.";
                    type = with types; listOf str;
                  };
                } // {
                  cp = mkOption {
                    description = "Run cp.";
                    type = types.bool;
                    default = false;
                  };

                  sourceDirectory = mkOption {
                    description = "Directory to copy from.";
                    type = types.str;
                  };

                  destinationDirectory = mkOption {
                    description = "Directory to copy to.";
                    type = types.string;
                  };

                  files = mkOption {
                    description = "Files to copy";
                    type = with types; listOf str;
                  };
                } // {
                  environment = mkOption {
                    description = "Set environment variables.";
                    type = with types; attrsOf str;
                  };
                };
              });
            default = [];
          };

          buildInputs = mkOption {
            description = "Build inputs.";
            type = with types; listOf (oneOf [ package string ]);
            default = [];
          };

          output = mkOption {
            description = "Output script.";
            type = types.package;
          };
        };

        config.output =
          runCommandKaem
            { name = "stuff";
              drvArgs = {
                buildInputs =
                  [ mes-m2 cp mkdir
                  ] ++ buildInputs;
              };
            }
            (''
              set -xe
            ''
            +
            (concatMapStringsSep "\n" (x:
              if x.cd != null then
                "cd ${x.cd}"
              else if x.catm then
                "${catm}/bin/catm ${x.outputFile} ${concatStringsSep " " x.files}"
              else if x.mes-m2 then
                let
                  defines = concatStrings (mapAttrsToList (n: v: "-D ${n}=${v} ") x.defines);
                  includeDirectories = concatMapStrings (i: "-I " + i + " ") x.includeDirectories;
                in
                  concatMapStringsSep "\n" (f:
                    "${mes-m2}/bin/mescc -- ${defines} ${includeDirectories} ${f}"
                  ) x.sourceFiles
              else if x.mkdir then
                "${mkdir}/bin/mkdir ${concatStringsSep " " x.directories}"
              else
                throw "Unknow error"
            ) buildSteps));
      };

  filename = str:
    last (splitString "/" str);

  stripExtension = str:
    concatStringsSep "." (body (splitString "." str));

  addExtension = ext: str:
    str + "." + ext;

  replaceExtension = ext: str:
    addExtension ext (stripExtension str);

  body = list:
    (reverseList (tail (reverseList list)));

  libc-miniSources =
    [ "lib/mes/eputs.c"
      "lib/mes/oputs.c"
      "lib/mes/globals.c"
      "lib/stdlib/exit.c"
      "lib/linux/x86-mes-mescc/_exit.c"
      "lib/linux/x86-mes-mescc/_write.c"
      "lib/stdlib/puts.c"
      "lib/string/strlen.c"
      "lib/mes/mini-write.c"
    ];

  libcSources =
    [ "lib/ctype/isnumber.c"
      "lib/mes/abtol.c"
      "lib/mes/cast.c"
      "lib/mes/eputc.c"
      "lib/mes/fdgetc.c"
      "lib/mes/fdputc.c"
      "lib/mes/fdputs.c"
      "lib/mes/fdungetc.c"
      "lib/mes/itoa.c"
      "lib/mes/ltoa.c"
      "lib/mes/ltoab.c"
      "lib/mes/mes_open.c"
      "lib/mes/ntoab.c"
      "lib/mes/oputc.c"
      "lib/mes/ultoa.c"
      "lib/mes/utoa.c"
      "lib/ctype/isdigit.c"
      "lib/ctype/isspace.c"
      "lib/ctype/isxdigit.c"
      "lib/mes/assert_msg.c"
      "lib/posix/write.c"
      "lib/stdlib/atoi.c"
      "lib/linux/lseek.c"
      "lib/mes/__assert_fail.c"
      "lib/mes/__buffered_read.c"
      "lib/mes/__mes_debug.c"
      "lib/posix/execv.c"
      "lib/posix/getcwd.c"
      "lib/posix/getenv.c"
      "lib/posix/isatty.c"
      "lib/posix/open.c"
      "lib/posix/buffered-read.c"
      "lib/posix/setenv.c"
      "lib/posix/wait.c"
      "lib/stdio/fgetc.c"
      "lib/stdio/fputc.c"
      "lib/stdio/fputs.c"
      "lib/stdio/getc.c"
      "lib/stdio/getchar.c"
      "lib/stdio/putc.c"
      "lib/stdio/putchar.c"
      "lib/stdio/ungetc.c"
      "lib/stdlib/free.c"
      "lib/stdlib/malloc.c"
      "lib/stdlib/realloc.c"
      "lib/string/memchr.c"
      "lib/string/memcmp.c"
      "lib/string/memcpy.c"
      "lib/string/memmove.c"
      "lib/string/memset.c"
      "lib/string/strcmp.c"
      "lib/string/strcpy.c"
      "lib/string/strncmp.c"
      "lib/posix/raise.c"
      "lib/linux/access.c"
      "lib/linux/brk.c"
      "lib/linux/chmod.c"
      "lib/linux/clock_gettime.c"
      "lib/linux/dup.c"
      "lib/linux/dup2.c"
      "lib/linux/execve.c"
      "lib/linux/fork.c"
      "lib/linux/fsync.c"
      "lib/linux/_getcwd.c"
      "lib/linux/gettimeofday.c"
      "lib/linux/ioctl3.c"
      "lib/linux/_open3.c"
      "lib/linux/_read.c"
      "lib/linux/time.c"
      "lib/linux/unlink.c"
      "lib/linux/waitpid.c"
      "lib/linux/x86-mes-mescc/syscall.c"
      "lib/linux/getpid.c"
      "lib/linux/kill.c"
    ];

  libcTccSources =
    [ "lib/ctype/islower.c"
      "lib/ctype/isupper.c"
      "lib/ctype/tolower.c"
      "lib/ctype/toupper.c"
      "lib/mes/abtod.c"
      "lib/mes/dtoab.c"
      "lib/mes/search-path.c"
      "lib/posix/execvp.c"
      "lib/stdio/fclose.c"
      "lib/stdio/fdopen.c"
      "lib/stdio/ferror.c"
      "lib/stdio/fflush.c"
      "lib/stdio/fopen.c"
      "lib/stdio/fprintf.c"
      "lib/stdio/fread.c"
      "lib/stdio/fseek.c"
      "lib/stdio/ftell.c"
      "lib/stdio/fwrite.c"
      "lib/stdio/printf.c"
      "lib/stdio/remove.c"
      "lib/stdio/snprintf.c"
      "lib/stdio/sprintf.c"
      "lib/stdio/sscanf.c"
      "lib/stdio/vfprintf.c"
      "lib/stdio/vprintf.c"
      "lib/stdio/vsnprintf.c"
      "lib/stdio/vsprintf.c"
      "lib/stdio/vsscanf.c"
      "lib/stdlib/calloc.c"
      "lib/stdlib/qsort.c"
      "lib/stdlib/strtod.c"
      "lib/stdlib/strtof.c"
      "lib/stdlib/strtol.c"
      "lib/stdlib/strtold.c"
      "lib/stdlib/strtoll.c"
      "lib/stdlib/strtoul.c"
      "lib/stdlib/strtoull.c"
      "lib/string/memmem.c"
      "lib/string/strcat.c"
      "lib/string/strchr.c"
      "lib/string/strlwr.c"
      "lib/string/strncpy.c"
      "lib/string/strrchr.c"
      "lib/string/strstr.c"
      "lib/string/strupr.c"
      "lib/stub/sigaction.c"
      "lib/stub/ldexp.c"
      "lib/stub/mprotect.c"
      "lib/stub/localtime.c"
      "lib/stub/sigemptyset.c"
      "lib/x86-mes-mescc/setjmp.c"
      "lib/linux/close.c"
      "lib/linux/rmdir.c"
      "lib/linux/stat.c"
    ];
  
  buildSteps =
    { ... }:
    {
      buildInputs = [ (import ../sources/mes-m2.nix { inherit fetchFromGitHub; }) ]; 
      buildSteps =
        [ { cd = import ../sources/mes-m2.nix { inherit fetchFromGitHub; }; }
          { mes-m2 = true;
            sourceFiles = [ "lib/linux/x86-mes-mescc/crt1.c" ];
            includeDirectories = [ "include" "include/linux/x86" ];
            defines =
              { HAVE_CONFIG_H="1";
              };
          }
          
          { mes-m2 = true;
            sourceFiles = libc-miniSources;
            includeDirectories = [ "include" "include/linux/x86" ];
            defines =
              { HAVE_CONFIG_H="1";
              };
          }
          { catm = true;
            outputFile = "libc-mini.o";
            files = map (x: replaceExtension "o" (filename x)) libc-miniSources;
          }
          { catm = true;
            outputFile = "libc-mini.s";
            files = map (x: replaceExtension "s" (filename x)) libc-miniSources;
          }

          { mes-m2 = true;
            sourceFiles = libcSources;
            includeDirectories = [ "include" "include/linux/x86" ];
            defines =
              { HAVE_CONFIG_H="1";
              };
          }
          { catm = true;
            outputFile = "libc.a";
            files = map (x: replaceExtension "o" (filename x)) ((body libc-miniSources) ++ libcSources);
            
          }
          { catm = true;
            outputFile = "libc.s";
            files = map (x: replaceExtension "s" (filename x)) ((body libc-miniSources) ++ libcSources);
          }

          { mes-m2 = true;
            sourceFiles = libcTccSources;
            includeDirectories = [ "include" "include/linux/x86" ];
            defines =
              { HAVE_CONFIG_H="1";
              };
          }
          { catm = true;
            outputFile = "libc+tcc.a";
            files = map (x: replaceExtension "o" (filename x)) libcTccSources;
            
          }
          { catm = true;
            outputFile = "libc+tcc.s";
            files = map (x: replaceExtension "s" (filename x)) libcTccSources;
          }

          { mkdir = true;
            directories =
              [ "\${out}/lib/linux"
                "\${out}/include/mes"
                "\${out}/include/sys"
                "\${out}/include/linux"
                "\${out}/lib/x86-mes"
                "\${out}/lib/linux/x86-mes"
                "\${out}/include/linux/x86"
              ];
          }
        ];
    };

  evaledModules = lib.evalModules { modules = [ module buildSteps ]; };
in
evaledModules
