{ stdenv
, writeTextK
, kaem
}@args:
{ kaem ? args.kaem
, name
, forceNoWriteText ? false
, forceDiscardContext ? false
, drvArgs ? {}
}:
command:
derivation ({
  inherit name;
  system = stdenv.system;
  builder = if kaem ? "hasBinDir" && kaem.hasBinDir then kaem + "/bin/${kaem.name}" else kaem;
  args = builtins.trace { inherit forceNoWriteText name forceDiscardContext; }
    (if kaem.name == "kaem-0" || kaem.name == "kaem-seed" then
      builtins.trace "${name}-1" [ (builtins.toFile "builder.kaem" (builtins.unsafeDiscardStringContext command)) ]
     else if forceNoWriteText then
       builtins.trace "${name}-2" [ "-v" "-f" (builtins.toFile "builder.kaem" (builtins.unsafeDiscardStringContext command)) ]
     else if forceDiscardContext then
       builtins.trace "${name}-3" [ "-v" "-f" (builtins.toFile "builder.kaem" (builtins.unsafeDiscardStringContext command)) ]
     else
       builtins.trace "${name}-4" [ "-v" "-f" (writeTextK { name = "${name}-builder.kaem"; } command)]);
} // drvArgs)
