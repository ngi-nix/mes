{ buildM2
, fetchFromGitHub, runCommandKaem, writeTextK
, m1, hex2
, cp, kaem, mkdir, chmod
}:
let
  mes-m2 = import ../sources/mes-m2.nix { inherit fetchFromGitHub; };
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
  nyacc = builtins.fetchTarball
    { url = "https://download.savannah.gnu.org/releases/nyacc/nyacc-1.00.2.tar.gz";
      sha256 = "sha256:06rg6pn4k8smyydwls1abc9h702cri3z65ac9gvc4rxxklpynslk";
    };

  mes = builtins.toFile "mes"
    ( builtins.unsafeDiscardStringContext
      ''
        #!${kaem}/bin/kaem -f
        set -xe

        GUILE_LOAD_PATH=${mes-m2}/mes/module:${mes-m2}/module
        MES_PREFIX=${mes-m2}
        ${base}/bin/mes "$@"
      '');

  mescc = # builtins.toFile "mescc"
    buildM2
      { name = "mescc";

        src = "/";
        sources =
          (map (x: stage0 + "/POSIX/" + x)
            [ "M2libc/sys/types.h"
              "M2libc/amd64/linux/sys/stat.c"
              "M2libc/stddef.h"
              "M2libc/amd64/linux/unistd.c"
              "M2libc/amd64/linux/bootstrap.c"
              "M2libc/stdlib.c"
              "M2libc/amd64/linux/fcntl.c"
              "M2libc/stdio.c"
              "M2libc/string.c"
	            "M2libc/bootstrappable.c"
            ]) ++
          (map (x: mes-m2 + "/" + x)
            [ "include/mes/lib.h"
              "include/mes/lib-mini.h"
              "lib/posix/getenv.c"
              "lib/posix/setenv.c"
              "lib/posix/execvp.c"
            ]) ++
          [ (writeTextK { name = "mescc.c"; }
              ''
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.c>
#include <fcntl.c>
#include "M2libc/bootstrappable.h"
#include "${mes-m2}/include/mes/lib-mini.h"
#include "${mes-m2}/include/unistd.c"

int main(int argc, char** argv, char** envp)
{
  environ = envp;
  char* path = strcat("${m1}/bin:${hex2}/bin:", getenv("PATH"));
  int* args_len = 4 + argc + 1;
  char** args = malloc(sizeof(char*) * args_len);
  args[0] = "${base}/bin/mes";
  args[1] = "-e";
  args[2] = "main";
  args[3] = "${mes-m2}/scripts/mescc.scm";

  int i = 4;
  while (i < argc + 4)
  {
    args[i] = argv[i - 4];

    i = i + 1;
  }
  args[args_len] = NULL;

  setenv("GUILE_LOAD_PATH", "${mes-m2}/mes/module:${mes-m2}/module:${nyacc}/module");
  setenv("PATH", path);
  chdir("${mes-m2}");
  execvp("${base}/bin/mes", args);
}
              '')
          ];

        architecture = "amd64";
        endiannes = "little";
      };
    # ( builtins.unsafeDiscardStringContext
    #   ''
    #     #!${kaem}/bin/kaem -f
    #     GUILE_LOAD_PATH=${mes-m2}/mes/module:${mes-m2}/module:${nyacc}/module
    #     PATH=${m1}/bin:${hex2}/bin:''${PATH}
    #     cd ${mes-m2}
    #     ${base}/bin/mes -e main ${mes-m2}/scripts/mescc.scm "$@"
    #   '');
  base =
    buildM2
      { name = "mes";

        src = mes-m2;
        sources =
          [ "include/m2/lib.h"
            "lib/linux/x86-mes-m2/crt1.c"
            "lib/linux/x86-mes-m2/mini.c"
            "lib/mes/globals.c"
            "lib/m2/cast.c"
            "lib/m2/exit.c"
            "lib/mes/mini-write.c"
            "lib/linux/x86-mes-m2/syscall.c"
            "include/linux/x86/syscall.h"
            "lib/linux/brk.c"
            "lib/stdlib/malloc.c"
            "lib/string/memset.c"
            "lib/m2/read.c"
            "lib/mes/fdgetc.c"
            "lib/stdio/getchar.c"
            "lib/stdio/putchar.c"
            "lib/m2/open.c"
            "lib/m2/mes_open.c"
            "lib/string/strlen.c"
            "lib/mes/eputs.c"
            "lib/mes/fdputc.c"
            "lib/mes/eputc.c"

            "include/mes/mes.h"
            "include/mes/builtins.h"
            "include/mes/constants.h"
            "include/mes/symbols.h"

            "lib/mes/__assert_fail.c"
            "lib/mes/assert_msg.c"

            "lib/mes/fdputc.c"
            "lib/string/strncmp.c"
            "lib/posix/getenv.c"
            "lib/mes/fdputs.c"
            "lib/mes/ntoab.c"
            "lib/ctype/isdigit.c"
            "lib/ctype/isxdigit.c"
            "lib/ctype/isspace.c"
            "lib/ctype/isnumber.c"
            "lib/mes/abtol.c"
            "lib/stdlib/atoi.c"
            "lib/string/memcpy.c"
            "lib/stdlib/free.c"
            "lib/stdlib/realloc.c"
            "lib/string/strcpy.c"
            "lib/mes/itoa.c"
            "lib/mes/ltoa.c"
            "lib/mes/fdungetc.c"
            "lib/posix/setenv.c"
            "lib/linux/access.c"
            "lib/m2/chmod.c"
            "lib/linux/ioctl3.c"
            "lib/m2/isatty.c"
            "lib/linux/fork.c"
            "lib/m2/execve.c"
            "lib/m2/execv.c"
            "lib/linux/waitpid.c"
            "lib/linux/gettimeofday.c"
            "lib/m2/clock_gettime.c"
            "lib/m2/time.c"
            "lib/linux/_getcwd.c"
            "lib/m2/getcwd.c"
            "lib/linux/dup.c"
            "lib/linux/dup2.c"
            "lib/string/strcmp.c"
            "lib/string/memcmp.c"
            "lib/linux/unlink.c"
            "src/builtins.c"
            "src/core.c"
            "src/display.c"
            "src/eval-apply.c"
            "src/gc.c"
            "src/hash.c"
            "src/lib.c"
            "src/apply-m2.c"
            "src/math.c"
            "src/mes.c"
            "src/module.c"
            "src/posix.c"
            "src/reader.c"
            "src/stack.c"
            "src/string.c"
            "src/struct.c"
            "src/symbol.c"
            "src/vector.c"
          ];

        m1Args =
          # for some reason this can't be on multiple lines
          "-f ${mes-m2}/lib/m2/x86/x86_defs.M1 -f ${mes-m2}/lib/x86-mes/x86.M1 -f ${mes-m2}/lib/linux/x86-mes-m2/crt1.M1";

        hex2Args = "-f ${mes-m2}/lib/m2/x86/ELF-i386-debug.hex2";

        architecture = "x86";
        endiannes = "little";

        m2Args = "--bootstrap-mode";
        base-address = "0x1000000";
        withM2LibC = false;

        buildInputs = [ cp mes-m2 ];
  };
in
runCommandKaem
  { name = "mes-m2";
    drvArgs = {
      buildInputs =
        [ mkdir mes mescc chmod cp base mes-m2 m1 hex2 nyacc
        ];
    };
  }
  ''
    ${mkdir}/bin/mkdir -v ''${out}/bin/

    ${cp}/bin/cp -v ${mes} ''${out}/bin/mes
    ${cp}/bin/cp -v ${mescc} ''${out}/bin/mescc

    ${chmod}/bin/chmod -v 755 ''${out}/bin/mes
    ${chmod}/bin/chmod -v 755 ''${out}/bin/mescc
  ''
