{
  description = ''
    .__   __.  __  ___   ___ 
    |  \ |  | |  | \  \ /  / 
    |   \|  | |  |  \  V  /  
    |  . `  | |  |   >   <   
    |  |\   | |  |  /  .  \  
    |__| \__| |__| /__/ \__\ 
                             
    .______      ___       ______  __  ___      ___       _______  _______      _______.
    |   _  \    /   \     /      ||  |/  /     /   \     /  _____||   ____|    /       |
    |  |_)  |  /  ^  \   |  ,----'|  '  /     /  ^  \   |  |  __  |  |__      |   (----`
    |   ___/  /  /_\  \  |  |     |    <     /  /_\  \  |  | |_ | |   __|      \   \    
    |  |     /  _____  \ |  `----.|  .  \   /  _____  \ |  |__| | |  |____ .----)   |   
    | _|    /__/     \__\ \______||__|\__\ /__/     \__\ \______| |_______||_______/    
  '';

  inputs = {
    nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs-unstable = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    pkgs-by-name = {
      type = "github";
      owner = "drupol";
      repo = "pkgs-by-name-for-flake-parts";
    };

    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nur = {
      type = "github";
      owner = "nix-community";
      repo = "NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
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
        ];

        perSystem =
          {
            self',
            system,
            ...
          }:
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                inputs.nur.overlays.default
                # (_f: _p: {
                #   inherit (inputs.emmanuelrosa-nix.lib.${system})
                #     mkWindowsApp
                #     mkWindowsAppNoCC
                #     copyDesktopIcons
                #     makeDesktopIcon
                #     ;
                # })
              ];
            };
          in
          {
            _module.args = { inherit pkgs; };

            pkgsDirectory = ./packages;
            pkgsNameSeparator = ".";

            packages = rec {
              default = updater;
              updater = pkgs.callPackage ./updater.nix {
                inherit self';
              };
            };
          };

        debug = true;
      };
}
