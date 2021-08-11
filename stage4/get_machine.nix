{ buildM2
, fetchFromGitHub
, m2-minimal
}:
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
buildM2
  { name = "get_machine";

    m2 = m2-minimal;

    src = stage0 + "/POSIX";
    sources =
      [ "M2libc/sys/types.h"
        "M2libc/stddef.h"
        "M2libc/amd64/Linux/unistd.h"
        "M2libc/stdlib.c"
        "M2libc/amd64/Linux/fcntl.h"
        "M2libc/stdio.c"
        "M2libc/bootstrappable.c"
	      "mescc-tools/get_machine.c"
      ];

    architecture = "amd64";
    endiannes = "little";
  }
