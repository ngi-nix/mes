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
        outputHash = "sha256-AnKNvJtTO/FjfnPoe4SbnWQZr2uG8HTdh6KoeDySMrI=";

        buildInputs = [ stage0 hex0 ];
      };
    }
    ''
      ${hex0} ${stage0}/seed/POSIX/AMD64/kaem-minimal.hex0 /nix/store/fwg0niaw8icl5sc1f32bj4b41rli31wj-kaem-0
    ''
