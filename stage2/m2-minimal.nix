{ runCommandKaem
, m0, catm-0, hex2-0, cc, kaem-0
, lib
, fetchFromGitHub
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
  cSources = import ../utils/c-sources.nix { inherit lib stage0; }
    ""
    [ "M2libc/amd64/Linux/bootstrap.c"
      "M2-Planet/cc.h"
      "M2libc/bootstrappable.c"
      "M2-Planet/cc_globals.c"
      "M2-Planet/cc_reader.c"
      "M2-Planet/cc_strings.c"
      "M2-Planet/cc_types.c"
      "M2-Planet/cc_core.c"
      "M2-Planet/cc_macro.c"
      "M2-Planet/cc.c"
    ];
in
runCommandKaem
  { name = "m2-minimal";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-BP8EBzlt7s6VRNUt99SnZ60vAndrX6b3rLexKLv4gpo=";

      hasBinDir = false;

      buildInputs =
        [ stage0
          catm-0 m0 hex2-0 cc
        ];
    };

    kaem = kaem-0;
  }
  ''
    ${catm-0} /build/M2.c ${cSources}
    ${cc} /build/M2.c /build/M2-0.M1
    ${catm-0} /build/M2.M1 ${stage0}/POSIX/AMD64/amd64_defs.M1 ${stage0}/POSIX/AMD64/libc-core.M1 /build/M2-0.M1
    ${m0} /build/M2.M1 /build/M2.hex2
    ${catm-0} /build/ELF_M2.hex2 ${stage0}/POSIX/AMD64/ELF-amd64.hex2 /build/M2.hex2
    ${hex2-0} /build/ELF_M2.hex2 /nix/store/rn77jp3d27iqhyy944xqnr1dagbybvvm-m2-minimal
  ''
