{ inputs, config, pkgs, ... }: {
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

  networking.hostName = "devbox";
  networking.networkmanager.enable = true;

  # The base system profile packages (to search, use $ nix search <xxx>)
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
  ];
}
