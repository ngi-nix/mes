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
        outputHash = "sha256-Nz5Sp5buTdggkR9GK4s8+2bvZDOHLyArPMOcDXyIWss=";

        buildInputs =
          [ stage0
            hex0s
          ];
      };
    }
    ''
      ${hex0s} ${stage0}/seed/POSIX/AMD64/hex0_AMD64.hex0 /nix/store/02g0hhbd3ahkzjflb72bwm6zd4ba2bbp-hex0
    ''
