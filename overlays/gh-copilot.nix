{
  fetchurl,
  stdenv,
  ...
}:
stdenv.mkDerivation rec {
  pname = "gh-copilot";
  version = "v0.5.4-beta";

  src = fetchurl {
    url =
      {
        "aarch64-darwin" = "https://github.com/github/gh-copilot/releases/download/${version}/darwin-arm64";
        "aarch64-linux" = "https://github.com/github/gh-copilot/releases/download/${version}/linux-arm64";
        "x86_64-linux" = "https://github.com/github/gh-copilot/releases/download/${version}/linux-amd64";
      }
      .${stdenv.hostPlatform.system};
    hash =
      {
        "aarch64-darwin" = "sha256-F2OA66h/ptkjLZ2oQgkbZlDo31YDZzhk5Pre36TkHvI=";
        "aarch64-linux" = "sha256-4vX9On0upgfjM/IL/UzQj5ioeVnSsd2rUgIz6w4szZM=";
        "x86_64-linux" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      }
      .${stdenv.hostPlatform.system};
  };

  phases = ["installPhase" "patchPhase"];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/gh-copilot
    chmod +x $out/bin/gh-copilot
  '';
}
