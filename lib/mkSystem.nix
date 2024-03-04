inputs @ {
  home-manager,
  nix-darwin,
  nix-index-database,
  nixpkgs,
  ...
}: {
  darwin ? false,
  gui ? false,
  hostname,
  installation,
  overlays,
  system,
  user,
}: let
  homeManagerModule =
    if darwin
    then home-manager.darwinModules.home-manager
    else home-manager.nixosModules.home-manager;

  nixIndexModule = let
    modulesByInstallation = {
      "home-manager" = nix-index-database.hmModules.nix-index;
      "nix-darwin" = nix-index-database.darwinModules.nix-index;
      "nixos" = nix-index-database.nixosModules.nix-index;
    };
    lookup = attrs: key: attrs."${key}";
  in
    lookup modulesByInstallation installation;

  nixpkgsConfig = {
    nixpkgs = {
      config = {
        allowBroken = false;
        allowUnfree = true;
        allowUnsupportedSystem = false;
      };
      hostPlatform = system;
      inherit overlays;
    };
  };

  specialArgs =
    inputs
    // {
      currentHostname = hostname;
      currentInstallation = installation;
      currentSystem = system;
      currentUser = user;
      isDarwin = darwin;
      hasGui = gui;
    };

  systemFunc = let
    funcsByInstallation = {
      "home-manager" = home-manager.lib.homeManagerConfiguration;
      "nix-darwin" = nix-darwin.lib.darwinSystem;
      "nixos" = nixpkgs.lib.nixosSystem;
    };
    lookup = attrs: key: attrs."${key}";
  in
    lookup funcsByInstallation installation;

  userHomeManagerModule = ../users/${user}/home-manager.nix;

  userSystemModule =
    ../users/${user}/${
      if darwin
      then "darwin"
      else "nixos"
    }.nix;
in
  systemFunc {
    modules =
      [
        nixIndexModule
        nixpkgsConfig

        # We expose some extra arguments so that our modules can parameterize
        # better based on these values.
        {
          config._module.args = specialArgs;
        }
      ]
      ++ (
        if installation == "home-manager"
        then [
          userHomeManagerModule
        ]
        else [
          homeManagerModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import userHomeManagerModule;
              extraSpecialArgs = specialArgs;
            };
          }

          userSystemModule
        ]
      );
  }
  // (
    if installation == "home-manager"
    then {
      extraSpecialArgs = specialArgs;
      pkgs = nixpkgs.legacyPackages.${system};
    }
    else {
      inherit specialArgs;
    }
  )
