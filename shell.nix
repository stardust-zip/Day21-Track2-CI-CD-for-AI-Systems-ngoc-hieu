{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) lib stdenv zlib;
  gcloud = pkgs.google-cloud-sdk.withExtraComponents (
    with pkgs.google-cloud-sdk.components;
    [
      gke-gcloud-auth-plugin
    ]
  );
in
pkgs.mkShell {
  name = "lab21";

  NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
    stdenv.cc.cc # libstdc++
    zlib # libz (for numpy)
  ];

  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";

  # --- SSL Certificate Fixes ---
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  REQUESTS_CA_BUNDLE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  packages = with pkgs; [
    uv
    python312
    python312Packages.python-dotenv
    basedpyright
    ruff
    black

    # --- Added for building pyarrow (Option 2) ---
    cmake
    gcc
    gnumake
    # ---------------------------------------------

    gcloud
    dvc
    python312Packages.dvc-gs
  ];

  shellHook = ''
    # Fix for npm/npx trying to access read-only nix store paths
    mkdir -p "$HOME/.npm-global/bin" "$HOME/.npm-global/lib"
    export npm_config_prefix="$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"

    # Keep the library path for Python and Next.js SWC binaries
    export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
  '';
}
