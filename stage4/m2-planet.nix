{ buildM2
, fetchFromGitHub
, m2
}:
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
buildM2
  { name = "m2-planet";

    inherit m2;

    src = stage0 + "/POSIX";
    sources =
      [ "M2libc/sys/types.h"
        "M2libc/stddef.h"
        "M2libc/amd64/Linux/unistd.h"
        "M2libc/stdlib.c"
        "M2libc/amd64/Linux/fcntl.h"
        "M2libc/stdio.c"
        "M2libc/bootstrappable.c"
        "M2-Planet/cc.h"
        "M2-Planet/cc_globals.c"
        "M2-Planet/cc_reader.c"
        "M2-Planet/cc_strings.c"
        "M2-Planet/cc_types.c"
        "M2-Planet/cc_core.c"
        "M2-Planet/cc_macro.c"
        "M2-Planet/cc.c"
      ];

    architecture = "amd64";
    endiannes = "little";
  }
