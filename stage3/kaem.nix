{ runCommandKaem
, lib, fetchFromGitHub
, m2-minimal, blood-elf-0, m1-0, hex2-1, kaem-0
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
  mescc-tools = import ../sources/mescc-tools.nix { inherit fetchFromGitHub; };
  m2Sources = import ../utils/c-sources.nix { inherit lib stage0; }
    "-f"
    [ "M2libc/sys/types.h"
      "M2libc/stddef.h"
      "M2libc/string.c"
      "M2libc/amd64/linux/fcntl.c"
      "M2libc/amd64/linux/unistd.c"
      "M2libc/stdlib.c"
      "M2libc/stdio.c"
      "M2libc/bootstrappable.c"
    ];
  m1Sources = import ../utils/c-sources.nix { inherit lib stage0; }
    "-f"
    [ "M2libc/amd64/amd64_defs.M1"
      "M2libc/amd64/libc-full.M1"
    ];
in
runCommandKaem
  { name = "kaem";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-N2hLpVNjwt8/Z05Xh/Syi3sCDpQLSa2iDVdNXIaS/0M=";

      hasBinDir = false;

      buildInputs =
        [ stage0 mescc-tools
          m2-minimal blood-elf-0 m1-0 hex2-1
        ];
    };

    kaem = kaem-0;
  }
  ''
    ${m2-minimal} --architecture amd64 \
      ${m2Sources} \
      -f ${mescc-tools}/Kaem/kaem.h \
      -f ${mescc-tools}/Kaem/variable.c \
      -f ${mescc-tools}/Kaem/kaem_globals.c \
      -f ${mescc-tools}/Kaem/kaem.c \
      --debug \
      -o /build/kaem.M1

    ${blood-elf-0} --64 --little-endian -f /build/kaem.M1 -o /build/kaem_footer.M1

    ${m1-0} --architecture amd64 \
      --little-endian \
      ${m1Sources} \
      -f /build/kaem.M1 \
      -f /build/kaem_footer.M1 \
      -o /build/kaem.hex2

    ${hex2-1} --architecture amd64 \
      --little-endian \
      --base-address 0x00600000 \
      -f ${stage0}/POSIX/M2libc/amd64/ELF-amd64-debug.hex2 \
      -f /build/kaem.hex2 \
      -o /nix/store/cv4yhpg7myq48w7s5ghphv4gdqicdr1v-kaem
  ''
