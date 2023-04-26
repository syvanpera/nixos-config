{
  description = "Tinimini's NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      username = "tuomo";
    in {
      nixosConfigurations = (
        import ./machines { inherit (nixpkgs) lib; inherit inputs nixpkgs username; }
      );
    };
  # nixos = nixpkgs.lib.nixosSystem {
  #   specialArgs = { inherit inputs; };
  #   modules = [ ./machines/nixos ];
  # };

  # devbox = nixpkgs.lib.nixosSystem {
  #   specialArgs = { inherit inputs; };
  #   modules = [ ./machines/devbox ];
  # };
  # };
}
