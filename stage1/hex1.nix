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
  { name = "hex1";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-wgcuxghvOHk4BZOu2mFGIp1aLIMV0f/+UlLRy9cEoys=";

      buildInputs =
        [ stage0
          hex0
        ];
    };

    kaem = kaem-0;
  }
  ''
    ${hex0} ${stage0}/POSIX/AMD64/hex1_AMD64.hex0 /nix/store/m8490rh1p0mr9r40ny1m4rpxn4w9bcc9-hex1
  ''
