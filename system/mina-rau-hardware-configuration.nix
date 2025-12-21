# Hardware Configuration for mina-rau
#
# ⚠️  IMPORTANT: This is a PLACEHOLDER file!
#
# During NixOS installation, the installer will generate a hardware-configuration.nix
# file that is specific to your computer's hardware. You need to REPLACE this file
# with the auto-generated one from the installer.
#
# The auto-generated file will be located at: /etc/nixos/hardware-configuration.nix
#
# It will contain:
# - CPU type (Intel/AMD)
# - Kernel modules needed for your hardware
# - File system mount points
# - Swap device configuration
# - Network interface settings
#
# TO REPLACE THIS FILE:
# 1. After installing NixOS, copy the generated file:
#    cp /etc/nixos/hardware-configuration.nix /home/brad/limonene/system/mina-rau-hardware-configuration.nix
# 2. Commit the change to git
# 3. Rebuild your system

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # PLACEHOLDER - These will be filled in by the NixOS installer
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];  # Change to "kvm-amd" if using AMD processor
  boot.extraModulePackages = [ ];

  # PLACEHOLDER - File systems (these will be auto-generated during installation)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";  # Will be replaced with actual device
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";  # Will be replaced with actual device
    fsType = "vfat";
  };

  # PLACEHOLDER - Swap device (if you choose to use swap during installation)
  # swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  # Enable DHCP on network interfaces (usually auto-detected)
  networking.useDHCP = lib.mkDefault true;

  # Platform architecture
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Enable CPU microcode updates (uncomment the right one for your CPU)
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
