{ lib, runCommandKaem
, fetchFromGitHub
, m2-planet, blood-elf, m1, hex2
, kaem, mkdir
}@top:
{ name
, sources ? []
, src
, debug ? true
, withM2LibC ? true
, architecture
, endiannes # either "little" or "big"
, base-address ? "0x00600000"
, buildInputs ? []
, m2Args ? "", m1Args ? "", blood-elfArgs ? "", hex2Args ? ""
, m2 ? top.m2-planet, blood-elf ? top.blood-elf, m1 ? top.m1, hex2 ? top.hex2
, kaem ? top.kaem, mkdir ? top.mkdir

, postInstall ? ""
}@args:
with lib;

assert endiannes == "little" || endiannes == "big";
assert
   architecture == "aarch64"
   || architecture == "amd64"
   || architecture == "x86";

let
  stage0 = import ../sources/stage0.nix { inherit fetchFromGitHub; };

  ifHasBinDir = x:
    if !(x ? "hasBinDir") || x.hasBinDir then x + "/bin/${x.name}" else x;

  m2P = ifHasBinDir m2;
  blood-elfP = ifHasBinDir blood-elf;
  m1P = ifHasBinDir m1;
  hex2P = ifHasBinDir hex2;
  mkdirP = ifHasBinDir mkdir;
  cpP = ifHasBinDir cp;

  is64 = if architecture == "aarch64" || architecture == "amd64" then true else false;
in
runCommandKaem
  { inherit name kaem;
    drvArgs = {
      buildInputs =
        [ m2 blood-elf m1 hex2 mkdir src stage0
        ] ++ buildInputs;
    };
  }
  ''
    set -xe

    ${m2P} --architecture ${architecture} \
      ${concatMapStringsSep " " (x: "-f " + src + "/" + x) sources} \
      --debug \
      ${m2Args} \
      -o /build/pkg.M1

    ${blood-elfP} ${if is64 then "--64" else ""} -f /build/pkg.M1 -o /build/pkg_footer.M1 ${blood-elfArgs}

    ${m1P} --architecture ${architecture} \
      --little-endian \
      ${if withM2LibC then "-f ${stage0}/POSIX/M2libc/${architecture}/${architecture}_defs.M1 -f ${stage0}/POSIX/M2libc/${architecture}/libc-full.M1" else ""} \
      ${m1Args} \
      -f /build/pkg.M1 \
      -f /build/pkg_footer.M1 \
     	-o /build/pkg.hex2

    ${mkdirP} ''${out}/bin/

    ${hex2P} --architecture ${architecture} \
      --${endiannes}-endian \
      --base-address ${base-address} \
      ${hex2Args} \
      ${if withM2LibC then "-f ${stage0}/POSIX/M2libc/${architecture}/ELF-${architecture}-debug.hex2" else ""} \
      -f /build/pkg.hex2 \
     	-o ''${out}/bin/${name}

    echo asd
    ${postInstall}
  ''
