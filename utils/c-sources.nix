{ lib
, stage0
}:
with lib;
prefix:
cSources:
concatMapStringsSep
  " "
  (x: (optionalString (prefix != "" && prefix != null) prefix + " ") + stage0 + "/POSIX/" + x)
  cSources
