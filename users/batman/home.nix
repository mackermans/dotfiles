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
    "bat/themes" = {
      source = ./.config/bat/themes;
      recursive = true;
    };
    "direnv" = {
      source = ./.config/direnv;
      recursive = true;
    };
    "fish/themes" = {
      source = ./.config/fish/themes;
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
    "wezterm" = {
      source = ./.config/wezterm;
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

    packages =
      [
        # System Tools
        pkgs.btop # process monitor
        pkgs.neofetch # system info
        pkgs.nmap # network scanner
        pkgs.rsync # file sync
        pkgs.tldr # community-maintained man pages
        pkgs.vim # text editor
        pkgs.wakeonlan # wake on lan
        pkgs.wezterm # terminal emulator

        # Fetching Tools
        pkgs.bruno # api explorer
        pkgs.curl # fetch
        pkgs.httpie # fetch cli
        pkgs.wget # fetch

        # Cloud and Infrastructure Management
        pkgs.aws-vault # aws profile and credentials manager
        pkgs.awscli2 # aws cli
        pkgs.granted # aws role switcher
        pkgs.kubectl # k8s management cli
        pkgs.kubectx # k8s context switcher
        pkgs.kubernetes-helm # k8s package manager
        pkgs.terraform # terraform cli for infrastructure provisioning

        # Security and Encryption
        pkgs._1password # 1password: password manager cli
        pkgs.age # encryption cli
        pkgs.sops # encrypted file editor

        # Development Tools
        pkgs.delta # git diff tool
        pkgs.elixir # elixir language
        pkgs.erlang # erlang language
        pkgs.fzf # fuzzy finder
        pkgs.gleam # gleam language
        pkgs.graphite-cli # git stacks cli
        pkgs.mise # package manager
        pkgs.postgresql_16 # postgresql v16
        pkgs.python3 # python v3
        pkgs.rebar3 # erlang build tool
        pkgs.tilt # k8s dev environment
        pkgs.watchman # file watcher

        # Nix
        pkgs.cachix # nix binary cache manager

        # Language Servers, Linters and Formatters
        # bash
        pkgs.nodePackages_latest.bash-language-server # bash language server
        pkgs.shellcheck # shell linter
        pkgs.shfmt # shell formatter
        # elixir
        pkgs.lexical # elixir language server
        # github actions
        pkgs.actionlint # github action linter
        # graphql
        pkgs.nodePackages_latest.graphql-language-service-cli # graphql language server
        # go
        pkgs.gopls # go language server
        pkgs.gomodifytags # go struct tag generator
        pkgs.impl # go method stub generator for interfaces
        pkgs.gofumpt # stricter gofmt
        pkgs.gotools # collection of static analysis tools for go (goimports, etc.)
        # javascript/typescript
        pkgs.quick-lint-js # javascript/typescript linter
        pkgs.nodePackages_latest.typescript-language-server # typescript language server
        # lua
        pkgs.lua-language-server # lua language server
        pkgs.stylua # lua formatter
        # nix
        pkgs.alejandra # nix formatter
        pkgs.deadnix # nix linter
        pkgs.nixd # nix language server
        pkgs.statix # nix linter
        # rust
        pkgs.rust-analyzer # rust language server
        # svelte
        pkgs.nodePackages_latest.svelte-language-server # svelte language server
        # tailwind
        pkgs.tailwindcss-language-server # tailwind language server
        # toml
        pkgs.taplo # toml language server
        # yaml
        pkgs.yaml-language-server # yaml language server
        # misc
        pkgs.biome # linter and formatter
        pkgs.nodePackages_latest.prettier # formatter
        pkgs.vscode-langservers-extracted # vscode language servers (HTML/CSS/JSON/ESLint)

        # JSON and Data Manipulation
        pkgs.fx # terminal json viewer
        pkgs.gron # json grep
        pkgs.jq # json parser
        pkgs.yq-go # yaml/toml/xml parser

        # Utilities and Misc
        pkgs.ast-grep # grep for code
        pkgs.comma # run any nix package as a one-off command
        pkgs.fd # better find
        pkgs.glow # markdown preview
        pkgs.moreutils # more unix utilities (sponge, etc.)
        pkgs.neo4j # graph database
        pkgs.ripgrep # better grep
        pkgs.spotify # music streaming
        pkgs.trash-cli # trash cli for safer rm
        pkgs.websocat # websocket cli

        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        (pkgs.nerdfonts.override {fonts = ["FiraCode"];})

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
        then [
          pkgs._1password-gui
        ]
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
