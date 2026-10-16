{inputs, ...}: {
  flake.nixosConfigurations.vermissian = inputs.nixpkgs.lib.nixosSystem {
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
      inputs.self.modules.nixos.gamestream
      inputs.self.modules.nixos.ollama
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-cpu-amd-pstate
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      ../../hardware/vermissian.nix
      {
        limonene.machineBehaviors.disableSleep.enable = true;
        # vermissian is a remote-only box. Its streaming session is a dedicated
        # headless sway compositor (a lingering systemd user service, see the
        # gamestream module) with a virtual HEADLESS-1 output for Sunshine /
        # Moonlight — there is no physical display and no greetd/login manager.
        # The resolution below is what Sunshine captures and streams.
        limonene.gamestream.headless.enable = true;
        limonene.gamestream.headless.mode = "2560x1600@165Hz";

        home-manager.users.nicole.imports = [inputs.self.modules.homeManager.nicole-desktop];

        networking.hostName = "vermissian";

        # Dedicated builder-only key: lets other machines' nix-daemons (root)
        # use this box as a remote builder by SSHing in as `nicole`, without
        # granting root login anywhere.
        users.users.nicole.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFi9Jf4Md8NnzczjN/yk1FEluXTvWEMeJda6rsgx9n0i nix-builder@idol"
        ];

        boot.initrd.luks.devices."luks-1b5555a7-d2e4-4cf2-9654-f19eb0dfc349".device = "/dev/disk/by-uuid/1b5555a7-d2e4-4cf2-9654-f19eb0dfc349";
      }
    ];
    specialArgs = {inherit inputs;};
  };
}
