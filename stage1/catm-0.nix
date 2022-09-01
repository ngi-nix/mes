{ runCommandKaem
, hex0, kaem-0
, lib
, fetchFromGitHub
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
runCommandKaem
  { name = "catm-0";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-LHR9l/A+JMfcwctJN37lh7PbVDHELsSUmq76RMBZNr0=";

      buildInputs =
        [ stage0
          hex0
        ];
    };

    kaem = kaem-0;
  }
  ''
    ${hex0} ${stage0}/POSIX/AMD64/catm_AMD64.hex0 /nix/store/cg9dzhkznkwg9779hkvffvm7qyr239kn-catm-0
  ''
