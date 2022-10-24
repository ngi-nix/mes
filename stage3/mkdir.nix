{ runCommandKaem
, lib, fetchFromGitHub
, m2-minimal, blood-elf-0, m1-0, hex2-1
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
  m2Sources = import ../utils/c-sources.nix { inherit lib stage0; }
    "-f"
    [ "M2libc/sys/types.h"
      "M2libc/amd64/linux/sys/stat.c"
      "M2libc/stddef.h"
      "M2libc/amd64/linux/unistd.c"
      "M2libc/amd64/linux/fcntl.c"
      "M2libc/stdlib.c"
      "M2libc/stdio.c"
	    "M2libc/string.c"
      "mescc-tools-extra/mkdir.c"
    ];
  m1Sources = import ../utils/c-sources.nix { inherit lib stage0; }
    "-f"
    [ "M2libc/amd64/amd64_defs.M1"
      "M2libc/amd64/libc-full.M1"
    ];
in
runCommandKaem
  { name = "mkdir";
    forceNoWriteText = true;
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-iFUhdeSyO5ka2h26iJlDEprSlU04ifukuzvwxTKmvXY=";

      hasBinDir = false;

      buildInputs =
        [ stage0
          m2-minimal blood-elf-0 m1-0 hex2-1
        ];
    };
  }
  ''
    ${m2-minimal} --architecture amd64 \
      ${m2Sources} \
      --debug \
      -o /build/mkdir.M1

    ${blood-elf-0} --64 -f /build/mkdir.M1 -o /build/mkdir_footer.M1

    ${m1-0} --architecture amd64 \
      --little-endian \
      ${m1Sources} \
      -f /build/mkdir.M1 \
      -f /build/mkdir_footer.M1 \
      -o /build/mkdir.hex2

    ${hex2-1} --architecture amd64 \
      --little-endian \
      --base-address 0x00600000 \
      -f ${stage0}/POSIX/M2libc/amd64/ELF-amd64-debug.hex2 \
      -f /build/mkdir.hex2 \
      -o /nix/store/19zdkd2rgj0cxdl31mnjlh6kp3h9asfv-mkdir
  ''
