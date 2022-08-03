{ mes, catm, mkdir, cp
, runCommandKaem
, lib
}:
buildSteps:
let
  module =
    { ... }:
    {
      options = {
        
      };
    };

  evaledModules = lib.evalModules { modules = [ module ]; };
in
evaledModules
