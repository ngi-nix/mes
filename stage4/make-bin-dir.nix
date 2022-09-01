{ runCommandKaem, cp, mkdir, kaem, chmod
}:
src:
let
  ifHasBinDir = x:
    if !(x ? "hasBinDir") || x.hasBinDir then x + "/bin/${x.name}" else x;

  cpP = ifHasBinDir cp;
  mkdirP = ifHasBinDir mkdir;
  kaemP = ifHasBinDir kaem;
  chmodP = ifHasBinDir chmod;
in
runCommandKaem
  { inherit (src) name;
    kaem = kaemP;
    forceNoWriteText = true;

    drvArgs = {
      buildInputs =
        [ cp mkdir chmod
        ];

      hasBinDir = true;
    };
  }
  ''
    set -xe

    ${mkdirP} ''${out}/bin/
    ${cpP} -v ${src} ''${out}/bin/${src.name}
    ${chmodP} -v 755 ''${out}/bin/${src.name}
  ''
