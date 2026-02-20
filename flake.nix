{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pkgs-by-name.url = "github:drupol/pkgs-by-name-for-flake-parts";

    rycee-pkgs = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
            pkgs,
            lib,
            config,
            system,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };

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
                    (lib.attrValues {
                      inherit (pkgs.python312Packages)
                        mdformat-beautysh
                        ;
                    })
                    ++ [
                      config.packages.mdformat-black
                      config.packages.mdformat-config
                    ];
                };

                formatjson5 = {
                  enable = true;
                  indent = 2;
                };
              };
            };
          };
      };
}
