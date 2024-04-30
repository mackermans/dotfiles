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
    "direnv" = {
      source = ./.config/direnv;
      recursive = true;
    };
    "karabiner" = {
      source = ./.config/karabiner;
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
        # System Tools
        btop # process monitor
        neofetch # system info
        nmap # network scanner
        rsync # file sync
        tldr # community-maintained man pages
        vim # text editor
        wakeonlan # wake on lan

        # Fetching Tools
        bruno # api explorer
        curl # fetch
        httpie # fetch cli
        wget # fetch

        # Cloud and Infrastructure Management
        aws-vault # aws profile and credentials manager
        awscli2 # aws cli
        granted # aws role switcher
        kubectl # k8s management cli
        kubectx # k8s context switcher
        kubernetes-helm # k8s package manager
        terraform # terraform cli for infrastructure provisioning

        # Security and Encryption
        _1password # 1password: password manager cli
        age # encryption cli
        sops # encrypted file editor

        # Development Tools
        delta # git diff tool
        fzf # fuzzy finder
        graphite-cli # git stacks cli
        mise # package manager
        lazygit # git management cli
        nodePackages_latest.pnpm # node package manager
        nodejs_21 # nodejs v21
        python3 # python v3
        tilt # k8s dev environment
        watchman # file watcher

        # Nix
        cachix # nix binary cache manager

        # Language Servers, Linters and Formatters
        # bash
        nodePackages_latest.bash-language-server # bash language server
        shellcheck # shell linter
        shfmt # shell formatter
        # github actions
        actionlint # github action linter
        # graphql
        nodePackages_latest.graphql-language-service-cli # graphql language server
        # go
        gopls # go language server
        gomodifytags # go struct tag generator
        impl # go method stub generator for interfaces
        gofumpt # stricter gofmt
        gotools # collection of static analysis tools for go (goimports, etc.)
        # javascript/typescript
        quick-lint-js # javascript/typescript linter
        nodePackages_latest.typescript-language-server # typescript language server
        # lua
        lua-language-server # lua language server
        stylua # lua formatter
        # nix
        alejandra # nix formatter
        deadnix # nix linter
        nixd # nix language server
        statix # nix linter
        # rust
        rust-analyzer # rust language server
        # svelte
        nodePackages_latest.svelte-language-server # svelte language server
        # tailwind
        tailwindcss-language-server # tailwind language server
        # toml
        taplo # toml language server
        # yaml
        yaml-language-server # yaml language server
        # misc
        biome # linter and formatter
        nodePackages_latest.prettier # formatter
        vscode-langservers-extracted # vscode language servers (HTML/CSS/JSON/ESLint)

        # JSON and Data Manipulation
        fx # terminal json viewer
        gron # json grep
        jq # json parser
        yq-go # yaml/toml/xml parser

        # Utilities and Misc
        comma # run any nix package as a one-off command
        fd # better find
        glow # markdown preview
        neo4j # graph database
        ripgrep # better grep
        trash-cli # trash cli for safer rm
        websocat # websocket cli

        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        (nerdfonts.override {fonts = ["FiraCode"];})

        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:

        # should be a script, so it can be used in other scripts
        (pkgs.writeShellScriptBin "nix-rebuild" ''
          ${nixRebuild} switch --flake "$HOME/.dotfiles#${currentInstallation}"
        '')

        (pkgs.writeShellScriptBin "nix-rollback" ''
          ${nixRebuild} switch --rollback
        '')

        (pkgs.writeShellScriptBin "nix-edit" ''
          pushd "$HOME/.dotfiles"; /usr/bin/env vim flake.nix; popd
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
