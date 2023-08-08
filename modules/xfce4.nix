{ inputs, config, lib, pkgs, ... }:
let
in
{
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
}
