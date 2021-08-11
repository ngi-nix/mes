{ runCommandKaem
, hex1, kaem-0
, lib
, fetchFromGitHub
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
runCommandKaem
  { name = "hex2-0";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-JjHfI7spXoKupuYe12ByMGeKiWcGUbgdHwqsOhdFG7Q=";

      buildInputs =
        [ stage0
          hex1
        ];
    };

    kaem = kaem-0;
  }
  ''
    ${hex1} ${stage0}/POSIX/AMD64/hex2_AMD64.hex1 /nix/store/i4bd7aysfq8dd09w21519g81j7nhy20y-hex2-0
  ''
