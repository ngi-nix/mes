{ runCommandKaem
, callPackage
}:
let
  tinycc = import ../sources/tinycc.nix { inherit (builtins) fetchTarball; };
in
runCommandKaem { name = "tinycc"; } ""
