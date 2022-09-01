{ runCommandKaem
, callPackage
, mes-m2
, get_machine
, kaem
}:
let
  tinycc = import ../sources/tinycc.nix { inherit (builtins) fetchTarball; };
in
runCommandKaem
  { name = "tinycc-build";
    kaem = builtins.trace "trnstrns" kaem;
  }
  ''
    PATH=${get_machine}/bin:${mes-m2}/bin:/bin
    V=1
    MESCC="mescc --"
    /bin/sh ${tinycc}/bootstrap.sh
  ''
