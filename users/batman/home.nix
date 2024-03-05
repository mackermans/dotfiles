{
  currentInstallation,
  currentUser,
  hasGui,
  isDarwin,
  nixRebuild,
  pkgs,
  ...
}: {
  imports = [
    ./programs.nix
  ];

  xdg.configFile = {
    "alacritty/catppuccin" = {
      source = ./.config/alacritty/catppuccin;
      recursive = true;
    };
    "nvim" = {
      source = ./.config/nvim;
      recursive = true;
    };
  };

  home = {
    file = {
      ".dotfiles/.git/hooks/pre-commit" = let
        dotfilesPrecommitHook = pkgs.writeShellScript "dotfiles-git-pre-commit-hook" ''
          echo "Rebuilding Nix configuration..."
          if ! nix-rebuild; then
            echo "Rebuild failed, aborting commit"
            exit 1
          fi
          echo "Rebuild successful, continuing commit"
        '';
      in {
        source = dotfilesPrecommitHook;
      };

      ".hammerspoon" = {
        source = ./.config/hammerspoon;
        recursive = true;
      };

      ".local/share/nvim/nix/nvim-treesitter/" = {
        recursive = true;
        source = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      };
    };

    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    homeDirectory =
      if isDarwin
      then "/Users/${currentUser}"
      else "/home/${currentUser}";
    username = "${currentUser}";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.

    packages = with pkgs;
      [
        # ported from system packages
        btop # process monitor
        comma # run any nix package as a one-off command
        curl # fetch
        rsync # file sync
        vim # text editor
        wget # fetch

        _1password # 1password: password manager cli
        age # encryption cli
        alejandra # nixOS formatter
        awscli2 # aws cli
        aws-vault # aws profile and credentials manager
        cachix # nix binary cache manager
        chezmoi # dotfiles manager
        deadnix # nixOS linter
        fd # better find
        fx # terminal json viewer
        fzf # fuzzy finder
        httpie # fetch cli
        graphite-cli # git stacks cli
        glow # markdown preview
        gron # json grep
        jq # json parser
        kubectl # k8s management cli
        kubectx # k8s context switcher
        kubernetes-helm # k8s package manager
        lazygit # git management cli
        neo4j # graph database
        neofetch # system info
        nmap # network scanner
        nixd # nix language server
        python3 # python v3
        ripgrep # better grep
        shellcheck # shell linter
        sops # encrypted file editor
        statix # nixOS linter
        terraform # terraform cli for infrastructure provisioning
        trash-cli # trash cli for safer rm
        wakeonlan # wake on lan cli
        websocat # websocket cli
        yq-go # yaml/toml/xml parser

        nodejs_21
        nodePackages_latest.pnpm

        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        (nerdfonts.override {fonts = ["FiraCode"];})

        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:
        (pkgs.writeShellScriptBin "nix-rebuild" ''
          ${nixRebuild} switch --flake "$HOME/.dotfiles#${currentInstallation}";
        '')

        (pkgs.writeShellScriptBin "nix-rollback" ''
          ${nixRebuild} switch --rollback;
        '')
      ]
      ++ (
        if !isDarwin && hasGui
        then with pkgs; [_1password-gui]
        else []
      );

    sessionVariables = {
      fish_greeting = ""; # 🐟
      DOCKER_BUILDKIT = "1";
      LANG = "en_US.UTF-8";
    };
  };

  nix = {
    settings = {
      # Manual optimise storage: nix-store --optimise
      # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
      auto-optimise-store = true;

      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";

      trusted-users = [currentUser];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
