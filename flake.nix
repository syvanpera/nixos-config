{
  description = "A very basic flake";
  outputs = { self, nixpkgs }: {
    package.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    package.x86_64-linux.default = self.packages.x86_64-linux.hello;
  };
}
