{ lib, inputs, nixpkgs, username, ... }:
let
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  lib = nixpkgs.lib;
in
{
  # Virtual machine
  nixos = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs username; };
    modules = [
      ./nixos
      ./configuration.nix
    ];
  };

  # Huawei Matebook Pro
  omnumnom = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs username; };
    modules = [
      ./omnumnom
      ./configuration.nix
    ];
  };
}
