{
  description = "system configuration by writing lua";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";
    zls-flake.url = "github:zigtools/zls";
    zls-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    zig-overlay,
    zls-flake,
    ...
  }:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      perSystem = {
        system,
        pkgs,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [
            zig-overlay.packages."${system}"."0.13.0"
            zls-flake.packages."${system}".default
            pkgs.gnumake
          ];
        };
      };
    };
}
