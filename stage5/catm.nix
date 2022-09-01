{ buildM2
, fetchFromGitHub
}:
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
buildM2
  { name = "catm";

    src = stage0 + "/POSIX";
    sources =
      [ "M2libc/sys/types.h"
        "M2libc/stddef.h"
        "M2libc/amd64/linux/unistd.c"
        "M2libc/stdlib.c"
        "M2libc/amd64/linux/fcntl.c"
        "M2libc/stdio.c"
	      "mescc-tools/catm.c"
      ];

    architecture = "amd64";
    endiannes = "little";
  }
