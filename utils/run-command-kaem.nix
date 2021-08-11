{ stdenv
, kaem
}@args:
{ kaem ? args.kaem
, name
, drvArgs ? {}
}:
command:
derivation ({
  inherit name;
  system = stdenv.system;
  builder = if !(kaem ? "hasBinDir") || kaem.hasBinDir then kaem + "/bin/${kaem.name}" else kaem;
  args =
    (if kaem.name == "kaem-0" || kaem.name == "kaem-seed" then [] else [ "-f" ])
    ++
    [
      (builtins.toFile "builder.kaem" (builtins.unsafeDiscardStringContext command))
    ];
} // drvArgs)
