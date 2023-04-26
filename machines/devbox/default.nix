{ inputs, config, lib, pkgs, ... }:
let
  mkSure = lib.mkOverride 0;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };

  # Make things work in QEMU VM
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = mkSure true;

  networking.hostName = "devbox";
  networking.networkmanager.enable = true;
}
