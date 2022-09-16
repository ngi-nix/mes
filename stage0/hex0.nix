{ runCommandNoCC, runCommandKaem
, fetchFromGitHub
, lib

, hex0, kaem-0

, seed ? false
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
  hex0s = (hex0.override { seed = true; });
in
if seed then
  runCommandNoCC "hex0"
    {}
    ''
      echo a
      cp ${stage0}/seed/POSIX/AMD64/hex0-seed $out
    ''
else
  runCommandKaem
    { name = "hex0";
      kaem = kaem-0.override { seed = true; };
      drvArgs = {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "sha256-3/4dGQnmmK6aJnNHW/iiRCvlgVEilxFzo6mE24rYX78=";

        buildInputs =
          [ stage0
            hex0s
          ];
      };
    }
    ''
      ${hex0s} ${stage0}/seed/POSIX/AMD64/hex0_AMD64.hex0 /nix/store/7m87krp7ghhrcxwsc7g238106m8iwhnj-hex0
    ''
