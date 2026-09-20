{inputs, ...}: {
  flake.nixosConfigurations.idol = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.self.modules.nixos.base
      inputs.self.modules.nixos.common
      inputs.self.modules.nixos.general
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
      }
      inputs.self.modules.nixos.users-nicole
      inputs.self.modules.nixos.sway
      inputs.self.modules.nixos.gaming
      inputs.self.modules.nixos.display-greetd
      inputs.hardware.nixosModules.framework-16-amd-ai-300-series
      # inputs.hardware.nixosModules.common-cpu-amd
      # inputs.hardware.nixosModules.common-cpu-amd-pstate
      # inputs.hardware.nixosModules.common-gpu-amd
      # inputs.hardware.nixosModules.common-pc-ssd
      ../../hardware/idol.nix
      ({
        lib,
        pkgs,
        ...
      }: {
        boot.kernelPackages = lib.mkForce (pkgs.unstable.linuxPackagesFor (pkgs.unstable.linux_latest.override {
          kernelPatches = [
            {
              name = "framework16-min-brightness";
              patch = ./framework16-min-brightness.patch;
            }
          ];
        }));
      })
      {
        limonene.autologinUser = "nicole";
        limonene.defaultSession = "sway";

        home-manager.users.nicole.imports = [inputs.self.modules.homeManager.nicole-desktop];

        networking.hostName = "idol";

        systemd.oomd = {
          enableRootSlice = true;
          enableUserSlices = true;
        };
        zramSwap.enable = true;
        boot.kernel.sysctl."vm.swappiness" = 10;

        boot.initrd.luks.devices."luks-099e44df-0372-4808-bf9a-74f2dba56f71".device = "/dev/disk/by-uuid/099e44df-0372-4808-bf9a-74f2dba56f71";
      }
    ];
    specialArgs = {inherit inputs;};
  };
}
