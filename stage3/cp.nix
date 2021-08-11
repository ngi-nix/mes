{ buildM2
, fetchFromGitHub
}:
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
buildM2
  { name = "cp";

    src = stage0 + "/POSIX";
    sources =
      [ "M2libc/sys/types.h"
        "M2libc/amd64/Linux/sys/stat.h"
        "M2libc/stddef.h"
        "M2libc/amd64/Linux/unistd.h"
        "M2libc/stdlib.c"
        "M2libc/amd64/Linux/fcntl.h"
        "M2libc/stdio.c"
        "M2libc/string.c"
	      "M2libc/bootstrappable.c"
	      "mescc-tools-extra/cp.c"
      ];

    architecture = "amd64";
    endiannes = "little";
  }
