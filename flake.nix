{
  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems' = systems: fun: nixpkgs.lib.genAttrs systems fun;
      forAllSystems = forAllSystems' supportedSystems;
    in
      {
        overlays.bootstrap = final: prev:
          {
                runCommandKaem = final.callPackage ./utils/run-command-kaem.nix {};
                buildM2 = final.callPackage ./utils/build-m2.nix
                  { m2-planet = final.m2-minimal;
                    blood-elf = final.blood-elf-0;
                    m1 = final.m1-0;
                    hex2 = final.hex2-1;
                  };

                hex0 = final.callPackage ./stage0/hex0.nix {};
                kaem-0 = final.callPackage ./stage0/kaem-0.nix {};
                hex0-seed = final.callPackage ./stage0/hex0.nix { seed = true; };
                kaem-0-seed = final.callPackage ./stage0/kaem-0.nix { seed = true; };

                hex1   = final.callPackage ./stage1/hex1.nix {};
                hex2-0 = final.callPackage ./stage1/hex2-0.nix {};
                catm-0   = final.callPackage ./stage1/catm-0.nix {};
                m0     = final.callPackage ./stage1/m0.nix {};

                cc     = final.callPackage ./stage2/cc.nix {};
                m2-minimal   = final.callPackage ./stage2/m2-minimal.nix {};
                blood-elf-0  = final.callPackage ./stage2/blood-elf-0.nix {};
                m1-0   = final.callPackage ./stage2/m1-0.nix {};
                hex2-1 = final.callPackage ./stage2/hex2-1.nix {};

                kaem   = final.callPackage ./stage3/kaem.nix {};
                mkdir  = final.callPackage ./stage3/mkdir.nix {};
                chmod = final.callPackage ./stage3/chmod.nix {};
                cp = final.callPackage ./stage3/cp.nix {}; 
          };

        overlays.mes = final: prev:
          {
            bootstrap =
              let
                pkgs = import nixpkgs
                  { overlays = [ self.overlays.bootstrap ];
                    system = final.stdenv.system;
                  };
                this = self.overlays.bootstrap pkgs prev;
              in
                this;

            runCommandKaem = final.callPackage ./utils/run-command-kaem.nix {};
            buildM2 = final.callPackage ./utils/build-m2.nix {};
            makeBinDir = final.callPackage ./stage4/make-bin-dir.nix
              { inherit (final.bootstrap) kaem mkdir;
              };

            inherit (final.bootstrap) cp chmod;
            kaem = final.makeBinDir final.bootstrap.kaem;
            mkdir = final.makeBinDir final.bootstrap.mkdir;
            m2-planet = final.callPackage ./stage4/m2-planet.nix
              { m2 = final.bootstrap.m2-minimal;
              };
            blood-elf = final.callPackage ./stage4/blood-elf.nix
              { m2 = final.bootstrap.m2-minimal;
                blood-elf = final.bootstrap.blood-elf-0;
              };
            m1     = final.callPackage ./stage4/m1.nix
              { m2 = final.bootstrap.m2-minimal;
                blood-elf = final.bootstrap.blood-elf-0;
                m1 = final.bootstrap.m1-0;
                hex2 = final.bootstrap.hex2-1;
              };
            hex2   = final.callPackage ./stage4/hex2.nix
              { m2 = final.bootstrap.m2-minimal;
                blood-elf = final.bootstrap.blood-elf-0;
                hex2 = final.bootstrap.hex2-1;
              };
            get_machine = final.callPackage ./stage4/get_machine.nix
              { m2 = final.bootstrap.m2-minimal;
              };

            catm = final.callPackage ./stage5/catm.nix {};
            sha256sum = final.callPackage ./stage5/sha256sum.nix {};
            untar = final.callPackage ./stage5/untar.nix {};
            ungz = final.callPackage ./stage5/ungz.nix {};

            mes-m2 = final.callPackage ./stage5/mes-m2.nix {};
          };

        overlay = self.overlays.mes;

        packages = forAllSystems
          (system:
            let
              pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
            in
              {
                inherit (pkgs) bootstrap;

                inherit (pkgs.bootstrap)
                  hex0      kaem-0     hex0-seed   kaem-0-seed         # stage 0
                  hex1      hex2-0     catm-0      m0                  # stage 1
                  cc        m2-minimal blood-elf-0 m1-0        hex2-1; # stage 2

                inherit (pkgs)
                  m2-planet blood-elf m1 hex2 get_machine
                  kaem mkdir chmod cp
                  catm sha256sum untar ungz
                  mes-m2;

                fancyModule = pkgs.callPackage ./utils/selfhost-mes-m2.nix {};
              }
          );


        checks = forAllSystems
          (system:
            let
              pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
              bootstrap = pkgs.bootstrap;
            in
              {
                hex0 = pkgs.runCommandNoCCLocal "hex0-check" {}
                  ''
                    hex0u="$(sha256sum ${bootstrap.hex0} | cut -d' ' -f 1)"
                    hex0s="$(sha256sum ${bootstrap.hex0-seed} | cut -d' ' -f 1)"

                    if [[ "$hex0u" = "$hex0s" ]] ; then
                       cat > $out <<EOF
                    ${bootstrap.hex0} -> $hex0u 
                    ${bootstrap.hex0-seed} -> $hex0s 
                    EOF
                    else
                      exit 1
                    fi
                  '';

                kaem = pkgs.runCommandNoCCLocal "kaem-check" {}
                  ''
                    kaemu="$(sha256sum ${bootstrap.kaem-0} | cut -d' ' -f 1)"
                    kaems="$(sha256sum ${bootstrap.kaem-0-seed} | cut -d' ' -f 1)"

                    if [[ "$kaemu" = "$kaems" ]] ; then
                       cat > $out <<EOF
                    ${bootstrap.kaem-0} -> $kaemu 
                    ${bootstrap.kaem-0-seed} -> $kaems 
                    EOF
                    else
                      exit 1
                    fi
                  '';
              }
          );
      };
}
