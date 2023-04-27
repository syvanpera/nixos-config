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

  networking.hostName = "omnunnom";
  networking.networkmanager.enable = true;

  # Define a user account
  users.users.tuomo = {
    description = "Tuomo Syvänperä";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      firefox
    ];
  };

  # The base system profile packages (to search, use $ nix search <xxx>)
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
  ];
}
