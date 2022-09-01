{ fetchFromGitHub
, lib
, stdenv
, runCommandNoCC, runCommandKaem

, kaem-0
, hex0

, seed ? false
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
if seed then
  runCommandNoCC "kaem-seed" {}
    ''
      cp ${stage0}/seed/POSIX/AMD64/kaem-optional-seed $out
    ''
else
  runCommandKaem
    { name = "kaem-0";
      kaem = kaem-0.override { seed = true; };
      drvArgs = {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "sha256-lJBHYpQxvlR9T4EKFOdSz/4eutbQg0aJay0cMNth9uU=";

        buildInputs = [ stage0 hex0 ];
      };
    }
    ''
      ${hex0} ${stage0}/seed/POSIX/AMD64/kaem-minimal.hex0 /nix/store/nnbsr1i6ad3sf7wd2a06k6y967fcm0i4-kaem-0
    ''
