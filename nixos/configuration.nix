# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  boot = {
    loader = {
      systemd.boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

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

  services.xserver = {
    # Enable the X11 windowing system
    enable = true;

    # Enable the XFCE Desktop Environment
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;

    # Configure keymap in X11
    layout = "fi";
    xkbVariant = "nodeadkeys";
  };

  # Configure keymap in console
  console.keyMap = "fi";

  # Enable CUPS
  services.printing.enable = true;

  # Enable pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # Use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    media-session.enable = true;
  };

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
    starship
  ];

  # Enable vendor fish completions provided by Nixpkgs
  programs.fish.enable = true;

  # Services to enable
  # Enable the OpenSSH daemon
  # services.openssh.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}
