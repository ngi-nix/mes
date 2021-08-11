{ runCommandKaem
, hex2-0, catm-0, kaem-0
, lib
, fetchFromGitHub
}:
with lib;
let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };
in
runCommandKaem
  { name = "m0";
    drvArgs = {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-diC1DHXfJ+0fOm6qb60GlKxdCJ84c7uzqZw+il+zUFQ=";

      buildInputs =
        [ stage0
          hex2-0
          catm-0
        ];
    };

    kaem = kaem-0;
  }
  ''
    ${catm-0} /build/M0_ELF_AMD64.hex2 ${stage0}/POSIX/AMD64/ELF-amd64.hex2 ${stage0}/POSIX/AMD64/M0_AMD64.hex2
    ${hex2-0} /build/M0_ELF_AMD64.hex2 /nix/store/f8z519n0dq7nn5jlhp9v5h9kcwzn6kb5-m0
  ''
