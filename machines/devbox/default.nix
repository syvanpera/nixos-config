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
      grub = {
        enable = true;
        version = 2;
        device = "/dev/vda";
      };
    };
  };

  # Make things work in QEMU VM
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = mkSure true;

  # Enable OpenSSH daemon
  services.openssh.enable = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
}
