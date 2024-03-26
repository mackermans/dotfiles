{
  currentHostname,
  currentUser,
  pkgs,
  self,
  ...
}: {
  imports = [
    ../../lib/darwin/touchId.nix
  ];

  environment = {
    shells = with pkgs; [bashInteractive zsh fish];

    systemPackages = with pkgs; [
      pam-reattach # use touch ID within tmux sessions
    ];
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;

      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    taps = [];

    # `brew install`
    brews = [
      # "koekeishiya/formulae/skhd" # hotkey daemon
      # "koekeishiya/formulae/yabai" # tiling window manager
      "pinentry-mac" # gpg passkey agent
    ];

    # `brew install --cask`
    casks = [
      "1password"
      "amethyst"
      "orbstack"
      "raycast"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      DaisyDisk = 411643860;
      Dato = 1470584107;
      "DaVinci Resolve" = 571213070;
      "Final Cut Pro" = 424389933;
      "Raivo Receiver" = 1498497896;
      "Slack for Desktop" = 803453959;
      Tailscale = 1475387142;
      WireGuard = 1451685025;
      XCode = 497799835;
    };
  };

  networking.computerName = currentHostname;
  networking.hostName = currentHostname;

  # # zsh is the default shell on Mac and we want to make sure that we're
  # # configuring the rc correctly with nix-darwin paths.
  programs = {
    zsh.enable = true;
    zsh.shellInit = ''
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix
    '';

    fish.enable = true;
    fish.shellInit = ''
      # Nix
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      end
      # End Nix
    '';
  };

  system = {
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock

      # other macOS's defaults configuration.
      # ......
      dock = {
        autohide = true;
        show-recents = false; # disable recent apps
      };

      NSGlobalDomain.AppleFontSmoothing = 1;

      smb.NetBIOSName = currentHostname;
    };

    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdTmux = true; # only works when macbook lid is open

  services = {
    # karabiner-elements.enable = true;
    nix-daemon.enable = true;
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.${currentUser} = {
    home = "/Users/${currentUser}";
    shell = pkgs.fish;
  };
}
