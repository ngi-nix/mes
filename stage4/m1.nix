{ buildM2
, fetchFromGitHub
, m2, blood-elf, m1, hex2
}:
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
buildM2
  { name = "m1";
  
    inherit m1 m2 blood-elf hex2;
    
    src = stage0 + "/POSIX";
    sources = 
      [ "M2libc/sys/types.h"
        "M2libc/stddef.h"
        "M2libc/amd64/linux/fcntl.c"
        "M2libc/amd64/linux/unistd.c"
        "M2libc/string.c"
        "M2libc/stdlib.c"
        "M2libc/stdio.c"
        "M2libc/bootstrappable.c"
        "mescc-tools/stringify.c"
        "mescc-tools/M1-macro.c"
      ];
    architecture = "amd64";
    endiannes = "little";
  }
