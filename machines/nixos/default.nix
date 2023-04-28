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

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = mkSure true;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
}
