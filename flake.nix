{
  description = "Maarten's unified NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };

    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/nix-index-database";
    };
  };

  outputs = inputs @ {
    home-manager,
    nix-darwin,
    nix-index-database,
    nixpkgs,
    ...
  }: let
    darwinArgs =
      inputs
      // {
        currentHostname = "batmac";
        currentInstallation = "nix-darwin";
        currentSystem = "aarch64-darwin";
        currentUser = "batman";
        isDarwin = true;
        hasGui = true;
        nixRebuild = "darwin-rebuild";
      };
    nixosArgs =
      inputs
      // {
        currentHostname = "batnix";
        currentInstallation = "nixos";
        currentSystem = "aarch64-linux";
        currentUser = "batman";
        isDarwin = false;
        hasGui = true;
        nixRebuild = "sudo nixos-rebuild";
      };
  in {
    darwinConfigurations = {
      nix-darwin = nix-darwin.lib.darwinSystem {
        specialArgs = darwinArgs;
        system = darwinArgs.currentSystem;
        modules = [
          ./users/${darwinArgs.currentUser}/${darwinArgs.currentInstallation}.nix

          home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = darwinArgs;
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${darwinArgs.currentUser} = import ./users/${darwinArgs.currentUser}/home.nix;
            };
          }

          nix-index-database.darwinModules.nix-index
          {
            nixpkgs = {
              config = {
                allowBroken = false;
                allowUnfree = true;
                allowUnsupportedSystem = false;
              };
              hostPlatform = darwinArgs.currentSystem;
              overlays = [
                (import ./overlays)
              ];
            };
          }
        ];
      };
    };

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = nixosArgs;
        system = nixosArgs.currentSystem;
        modules = [
          ./hosts/${nixosArgs.currentHostname}/configuration.nix
          ./users/${nixosArgs.currentUser}/${nixosArgs.currentInstallation}.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = nixosArgs;
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${nixosArgs.currentUser} = import ./users/${nixosArgs.currentUser}/home.nix;
            };
          }

          nix-index-database.nixosModules.nix-index
          {
            nixpkgs = {
              config = {
                allowBroken = false;
                allowUnfree = true;
                allowUnsupportedSystem = false;
              };
              hostPlatform = nixosArgs.currentSystem;
              overlays = [
                (import ./overlays)
              ];
            };
          }
        ];
      };
    };
  };
}
