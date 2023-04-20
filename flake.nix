{
  description = "Tinimini's NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  };

  outputs = { nixpkg, ... }@inputs: {
    # NixOS configuration entrypoint. Available through
    # 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./nixos/configuration.nix ];
      };
    };
  };
}
