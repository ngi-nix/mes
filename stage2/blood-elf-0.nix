{ runCommandKaem
, lib, fetchFromGitHub
, m0, catm-0, hex2-0, m2-minimal, kaem-0
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
  cSources = import ../utils/c-sources.nix { inherit lib stage0; }
    "-f"
    [ "M2libc/amd64/linux/bootstrap.c"
      "M2libc/bootstrappable.c"
      "mescc-tools/stringify.c"
      "mescc-tools/blood-elf.c"
    ];
in     
runCommandKaem
  { name = "blood-elf-0";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-pGV4pIySgESGbx3S7g5YGfpNYyIKHoNVkt71rHkQWHw=";

      buildInputs =
        [ stage0
          catm-0 m2-minimal m0 hex2-0
        ];

      hasBinDir = false;
    };

    kaem = kaem-0;
  }
  ''
    ${m2-minimal} --architecture amd64 \
	    ${cSources} \
	    --bootstrap-mode \
	    -o /build/blood-elf-0.M1 

    ${catm-0} /build/blood-elf_defs_libc.M1 ${stage0}/POSIX/AMD64/amd64_defs.M1 ${stage0}/POSIX/AMD64/libc-core.M1 /build/blood-elf-0.M1
    ${m0} /build/blood-elf_defs_libc.M1 /build/blood-elf-0.hex2
    ${catm-0} /build/blood-elf_elf.hex2 ${stage0}/POSIX/AMD64/ELF-amd64.hex2 /build/blood-elf-0.hex2
    ${hex2-0} /build/blood-elf_elf.hex2 /nix/store/40g45ls93732rh00zdiicf05dgszlv9j-blood-elf-0
  ''
