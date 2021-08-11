{ runCommandKaem
, lib, fetchFromGitHub
, m2-minimal, blood-elf-0, m1-0, catm-0, hex2-0, kaem-0
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
  m2Sources = import ../utils/c-sources.nix { inherit lib stage0; }
    "-f"
    [ "M2libc/sys/types.h"
      "M2libc/amd64/Linux/sys/stat.h"
      "M2libc/stddef.h"
      "M2libc/amd64/Linux/unistd.h"
      "M2libc/stdlib.c"
      "M2libc/amd64/Linux/fcntl.h"
      "M2libc/stdio.c"
      "M2libc/bootstrappable.c"
      "mescc-tools/hex2_linker.c"
    ];
  m1Sources = import ../utils/c-sources.nix { inherit lib stage0; }
    "-f"
    [ "M2libc/amd64/amd64_defs.M1"
      "M2libc/amd64/libc-full.M1"
    ];
in
runCommandKaem
  { name = "hex2-1";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-UbM0hNuGLfAmCNcQt0tsPtsiiL08hLkJJX8Mfjp1xw8=";

      hasBinDir = false;

      buildInputs =
        [ stage0
          m2-minimal blood-elf-0 m1-0 catm-0 hex2-0
        ];
    };

    kaem = kaem-0;
  }
  ''
    ${m2-minimal} --architecture amd64 \
      ${m2Sources} \
      --debug \
      -o /build/hex2-1.M1 

    ${blood-elf-0} --64 -f /build/hex2-1.M1 -o /build/hex2-1_footer.M1
    ${m1-0} --architecture amd64 \
            --little-endian \
            ${m1Sources} \
            -f /build/hex2-1.M1 -f /build/hex2-1_footer.M1 \
            -o /build/hex2-1.hex2

    ${catm-0} /build/hex2-1_elf_dbg.hex2 ${stage0}/POSIX/M2libc/amd64/ELF-amd64-debug.hex2 /build/hex2-1.hex2
    ${hex2-0} /build/hex2-1_elf_dbg.hex2 /nix/store/2ch0w7gs78sky87x843j9l2pzaxg742j-hex2-1
  ''
