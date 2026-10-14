{inputs, ...}: {
  flake.modules.homeManager.meshcore = {pkgs, ...}: {
    # MeshCore LoRa client, built from source by the meshcore-open flake
    # via flutter.buildFlutterApplication (its own nixpkgs-unstable).
    home.packages = [inputs.meshcore-client.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };
}
