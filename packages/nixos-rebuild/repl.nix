let
  flake = builtins.getFlake "${flake_path}";

  configuration = flake.${flake_attr};

  motd = ''
    $${"\n"}
    Welcome to ${blue}${flake_attr}${reset}
  '';

  scope =
    assert configuration._type or null == "configuration";
    assert configuration.class or "nixos" == "nixos";
    configuration._module.args
    // configuration._module.specialArgs
    // {
      inherit (configuration)
        config
        options
        ;

      inherit
        flake
        ;

      lib = configuration.lib or configuration.pkgs.lib;
    };
in

builtins.seq scope builtins.trace motd scope
