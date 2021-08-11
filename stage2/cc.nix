{ runCommandKaem
, m0, catm-0, hex2-0, kaem-0
, lib
, fetchFromGitHub
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
runCommandKaem
  { name = "cc";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-9Rd3mwbI6QuAXkzPu3/dT1C2BqsEiRIIn7vf0EYieEQ=";

      buildInputs =
        [ stage0
          catm-0 m0 hex2-0
        ];
    };

    kaem = kaem-0;
  }
  ''
    ${m0} ${stage0}/POSIX/AMD64/cc_amd64.M1 /build/cc_amd64.hex2
    ${catm-0} /build/cc_ELF_amd64.hex2 ${stage0}/POSIX/AMD64/ELF-amd64.hex2 /build/cc_amd64.hex2
    ${hex2-0} /build/cc_ELF_amd64.hex2 /nix/store/7mp661bb7fnc6j35jz59jg2mx357ligm-cc
  ''
