{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pkgs-by-name.url = "github:drupol/pkgs-by-name-for-flake-parts";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake
      {
        inherit
          inputs
          ;
      }
      {
        systems = [
          "x86_64-linux"
          "x86_64-darwin"
        ];

        imports = [
          inputs.pkgs-by-name.flakeModule
          inputs.treefmt-nix.flakeModule
        ];

        perSystem =
          {
            lib,
            config,
            system,
            ...
          }:
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                inputs.nur.overlays.default
              ];
            };
          in
          {
            _module.args = { inherit pkgs; };

            pkgsDirectory = ./packages;
            pkgsNameSeparator = ".";

            treefmt = {
              programs = {
                beautysh.enable = true;
                black.enable = true;
                nixfmt.enable = true;
                toml-sort.enable = true;
                yamlfmt.enable = true;

                mdformat = {
                  enable = true;
                  plugins =
                    ps:
                    lib.attrValues {
                      inherit (pkgs.python312Packages)
                        mdformat-beautysh
                        ;

                      inherit (config.packages)
                        mdformat-black
                        mdformat-config
                        ;
                    };
                };

                formatjson5 = {
                  enable = true;
                  indent = 2;
                };
              };
            };
          };

        debug = true;
      };
}
