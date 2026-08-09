{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "git-vrc";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/anatawa12/git-vrc/releases/download/v${finalAttrs.version}/git-vrc-x86_64-unknown-linux-musl";
    sha256 = "06arr5gh7bb8bjqkynicwmv14jf62dajivx7zfvq4c3mw312q4nr";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/git-vrc
    runHook postInstall
  '';

  meta = {
    description = "Git extension to reduce meaningless diff on VRC (VRChat) Unity projects";
    homepage = "https://github.com/anatawa12/git-vrc";
    license = with lib.licenses; [
      asl20
      mit
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "git-vrc";
  };
})
