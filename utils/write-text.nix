{ stdenv
, kaem
, bootstrap
}@args:
{ kaem ? args.kaem
, name
, drvArgs ? {}
}:
content:
derivation (rec {
  inherit name content;
  inherit (stdenv) system;
  passAsFile = [ "content" ];
  builder = if kaem ? "hasBinDir" && kaem.hasBinDir then kaem + "/bin/${kaem.name}" else kaem;
  buildInputs = [ bootstrap.cp ];
  args =
    assert kaem.name != "kaem-0";
    assert kaem.name != "kaem-seed";
    [ "-v" "-f"
      (builtins.toFile "builder.kaem"
        (builtins.unsafeDiscardStringContext ''
          ${bootstrap.cp}/bin/cp "''${contentPath}" ''${out}
        ''))
    ];
} // drvArgs)
