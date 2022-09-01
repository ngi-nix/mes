{ runCommandKaem
, lib, fetchFromGitHub
, m0, catm-0, blood-elf-0, hex2-0, m2-minimal, kaem-0
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
  cSources = import ../utils/c-sources.nix { inherit lib stage0; }
    "-f"
    [ "M2libc/amd64/linux/bootstrap.c"
      "M2libc/bootstrappable.c"
      "mescc-tools/M1-macro.c"
    ];
in     
runCommandKaem
  { name = "m1-0";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-xvH8nJ5zSQcrqXOC9YVqg7qLlTPAeMAO2WehZEWFNPg=";

      hasBinDir = false;

      buildInputs =
        [ stage0
          catm-0 m2-minimal m0 hex2-0 blood-elf-0
        ];
    };

    kaem = kaem-0;
  }
  ''
    ${m2-minimal} --architecture amd64 \
	    ${cSources} \
	    --bootstrap-mode \
      --debug \
	    -o /build/m1-0.M1 

    ${blood-elf-0} --64 -f /build/m1-0.M1 -o /build/m1-0-footer.M1
    ${catm-0} /build/m1-0_defs_libc_dbg.M1 ${stage0}/POSIX/M2libc/amd64/amd64_defs.M1 ${stage0}/POSIX/M2libc/amd64/libc-core.M1 /build/m1-0.M1 /build/m1-0-footer.M1
    ${m0} /build/m1-0_defs_libc_dbg.M1 /build/m1-0.hex2
    ${catm-0} /build/m1-0_dbg.hex2 ${stage0}/POSIX/M2libc/amd64/ELF-amd64-debug.hex2 /build/m1-0.hex2
    ${hex2-0} /build/m1-0_dbg.hex2 /nix/store/04jvbv19visppgh3yg1qzwz6s6qs3qaj-m1-0
  ''
