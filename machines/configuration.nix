{ config, lib, pkgs, inputs, username, ... }: {
  nixpkgs.config.allowUnfree = true;

  # Define a user account
  users.users.${username} = {
    description = "Tuomo Syvänperä";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      firefox
    ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    ripgrep
    tmux
  ];

  # Enable vendor fish completions provided by Nixpkgs
  programs.fish.enable = true;

  time.timeZone = "Europe/Helsinki";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  nix = {
    settings = {
      # Enable flakes and the new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # Configure keymap in console
  console.keyMap = "fi";

  services = {
    openssh = {
      enable = true;
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    xserver = {
      # Enable the X11 windowing system
      enable = true;

      # Enable the XFCE Desktop Environment
      displayManager.lightdm.enable = true;
      desktopManager.xfce.enable = true;

      libinput.enable = true;

      # Configure keymap in X11
      layout = "fi";
      xkbVariant = "nodeadkeys";
    };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # See https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}
