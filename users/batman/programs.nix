{
  config,
  lib,
  osConfig,
  pkgs,
  hasGui,
  isDarwin,
  ...
}: {
  programs = {
    # better "cat" util
    bat = {
      enable = true;
      config = {
        theme = "catppuccin-macchiato";
      };
      themes = {
        catppuccin-macchiato = {
          file = "Catppuccin-mocha.tmTheme";
          src =
            pkgs.fetchFromGitHub
            {
              owner = "catppuccin";
              repo = "bat";
              rev = "477622171ec0529505b0ca3cada68fc9433648c6";
              sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
            };
        };
      };
    };

    direnv = {
      enable = true;
    };

    eza = {
      enable = true;
      extraOptions = [
        "--group-directories-first"
      ];
      icons = true;
    };

    # shell
    fish = {
      enable = true;

      functions = {
        gitignore = "curl -sL https://www.gitignore.io/api/$argv";
        gg = {
          body = "lazygit $argv;";
          description = "alias lg lazygit";
          wraps = "lazygit";
        };
        rm = {
          body = "echo \"'rm' is restricted. Alternative: 'trash', or '$(which rm)' if you need to.\";";
          description = "block usage of rm command";
        };
      };

      plugins = [
        {
          name = "fzf-fish";
          inherit (pkgs.fishPlugins.fzf-fish) src;
        }
        {
          name = "plugin-git";
          inherit (pkgs.fishPlugins.plugin-git) src;
        }
        {
          name = "plugin-kubectl";
          src =
            pkgs.fetchFromGitHub
            {
              owner = "blackjid";
              repo = "plugin-kubectl";
              rev = "f3cc9003077a3e2b5f45e3988817a78e959d4131";
              sha256 = "sha256-ABzVSzM135UeAJ97CUBb9rhK9Pc6ItLSmJQOacq09gQ=";
            };
        }
        {
          name = "tide";
          inherit (pkgs.fishPlugins.tide) src;
        }
      ];

      loginShellInit =
        if isDarwin
        then let
          # fix nix-darwin & home-manager PATH sources
          #
          # This naive quoting is good enough in this case. There shouldn't be any
          # double quotes in the input string, and it needs to be double quoted in case
          # it contains a space (which is unlikely!)
          dquote = str: "\"" + str + "\"";

          makeBinPathList = map (path: path + "/bin");
        in ''
          fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
          set fish_user_paths $fish_user_paths
        ''
        else "";

      shellInit = ''
        set npm_token (sed '1q;d' "$HOME/.npmrc" | awk -F= '{print $2}')
        set -gx NPM_TOKEN "$npm_token"

        # fzf start

        # customize keybindings
        fzf_configure_bindings \
          --directory=\ct \
          --git_log=\e\cl \
          --git_status=\e\cs \
          --history=\cr \
          --processes=\e\cp \
          --variables=\cv
        # use eza for directory search
        set fzf_preview_dir_cmd eza --all --color=always

        # width=20 so delta decorations don't wrap around small fzf preview pane
        set fzf_diff_highlighter delta --paging=never --width=20

        # find hidden directories and exclude .git
        set fzf_fd_opts --hidden --exclude=.git

        # fzf end

        # bun
        set --export BUN_INSTALL "$HOME/.bun"
        set --export PATH $BUN_INSTALL/bin $PATH

        # jujutsu
        set --export JJ_CONFIG "${config.xdg.configHome}/jj/config.toml"

        # mise
        mise activate fish | source

        ${
          if isDarwin
          then ''
            # homebrew
            eval "$(/opt/homebrew/bin/brew shellenv)"

            # 1password ssh agent compatibility for git used by jujutsu
            set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
          ''
          else ''
          ''
        }
      '';

      shellAbbrs = {
        jn = "jj new";
        jnm = "jj new -m";
        jdm = "jj describe -m";
        jc = "jj commit";
        jcm = "jj commit -m";
        jgf = "jj git fetch";
        jgp = "jj git push";
        jd = "jj diff";
        jlog = "jj log";
        jst = "jj status";
        jbc = "jj branch create";
        jbl = "jj branch list";
        jbs = "jj branch set";
        jbsel = "jj branch set \"(git branch | fzf)\"";

        gci = "git checkout-interactive";
        t = "tmux";
        tf = "terraform";
        v = "vim";
      };

      shellAliases = {
        cat = "bat";
        vimdiff = "vim -d";
      };
    };

    gh = {
      enable = true;

      extensions = [
        pkgs.gh-actions-cache
        pkgs.gh-copilot
        pkgs.gh-dash
      ];
    };

    # git version control
    git = {
      enable = true;

      aliases = {
        checkout-interactive = "!git checkout $(git branch | fzf | xargs)";
      };

      extraConfig = {
        commit = {
          gpgsign = true;
        };
        core = {
          fsmonitor = true;
          pager = "delta";
          untrackedCache = true;
        };
        delta = {
          line-numbers = true;
          navigate = true; # use n and N to move between diff sections
          side-by-side = true;
        };
        diff = {
          colorMoved = "default";
        };
        gpg =
          {
            format = "ssh";
          }
          // (
            if isDarwin
            then {
              ssh = {
                program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
              };
            }
            else {}
          );
        init = {
          defaultBranch = "main";
        };
        interactive = {
          diffFilter = "delta --color-only";
        };
        merge = {
          conflictStyle = "diff3";
        };
        rebase = {
          updateRefs = true;
        };
        # record merge resolutions (REuse REcorded REsolution)
        rerere = {
          enabled = true;
        };
        user = {
          email = "4571935+mackermans@users.noreply.github.com";
          name = "Maarten Ackermans";
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARYUd5GUouM1r3YV5aEfwQryc1/7wnA1+Kys/bnV60O";
        };
      };

      ignores = [
        "*~"
        ".DS_Store"
        ".idea"
        ".vscode"
      ];
    };

    jujutsu = {
      enable = true;
      settings = {
        core = {
          fsmonitor = "watchman";
        };
        signing = {
          backend = "ssh";
          backends = {
            ssh = {
              program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
            };
          };
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARYUd5GUouM1r3YV5aEfwQryc1/7wnA1+Kys/bnV60O";
          sign-all = true;
        };
        ui = {
          merge-editor = "vimdiff";
        };
        user = {
          email = "4571935+mackermans@users.noreply.github.com";
          name = "Maarten Ackermans";
        };
      };
    };

    neovim = {
      defaultEditor = true;
      enable = true;
      extraPackages = with pkgs; [gcc];
      vimAlias = true;
    };

    # suggest packages from nixpkgs when command not found using nix-index
    command-not-found.enable = false;
    nix-index.enable = true;

    nushell = {
      enable = true;
    };

    tmux = {
      baseIndex = 1;
      clock24 = true;
      enable = true;
      escapeTime = 10;

      extraConfig = ''
        # iTerm2 shell integration
        set -g allow-passthrough on

        # Automatically renumber tmux windows when one is closed
        set -g renumber-windows on

        # Set true color
        set -ga terminal-overrides ",*256col*:Tc"

        # Reload tmux config
        bind r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "Reloaded!"

        # New tab and pane splitting
        bind t new-window -a -c "#{pane_current_path}"
        bind d split-window -h -c "#{pane_current_path}"
        bind D split-window -v -c "#{pane_current_path}"

        # Status bar
        set-option -g status-position bottom

        # Resize panes
        bind j resize-pane -D 5
        bind k resize-pane -U 5
        bind l resize-pane -R 5
        bind h resize-pane -L 5

        # Fullscreen
        bind m resize-pane -Z

        # copy-mode-vi keybindings (enter copy mode with prefix + [)
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      '';

      # Use vi keybindings
      keyMode = "vi";

      # Use mouse for pane navigation and scrolling
      mouse = true;

      plugins = with pkgs; [
        tmuxPlugins.open
        tmuxPlugins.yank
        tmuxPlugins.vim-tmux-navigator
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @catppuccin_status_background "default"

            set -g @catppuccin_flavour 'mocha'
            set -g @catppuccin_window_tabs_enabled on
            set -g @catppuccin_date_time_text "%H:%M"

            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_right_separator "█"
            set -g @catppuccin_window_middle_separator " "
            set -g @catppuccin_window_number_position "left"
            set -g @catppuccin_window_status_enable "yes"

            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"

            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W"

            set -g @catppuccin_directory_text "#{pane_current_path}"

            set -g @catppuccin_status_modules_left ""
            set -g @catppuccin_status_modules_right "date_time"
            set -g @catppuccin_status_left_separator  " "
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_fill "all"
            set -g @catppuccin_status_connect_separator "yes"

          '';
        }
        # {
        #   plugin = tmuxPlugins.resurrect;
        #   extraConfig = ''
        #     set -g @resurrect-strategy-vim 'session'
        #     set -g @resurrect-strategy-nvim 'session'
        #     set -g @resurrect-capture-pane-contents 'on'
        #   '';
        # }
        # {
        #   plugin = tmuxPlugins.continuum;
        #   extraConfig = ''
        #     set -g @continuum-restore 'on'
        #     set -g @continuum-save-interval '60' # minutes
        #   '';
        # }
      ];

      # Use C-Space as prefix
      prefix = "C-Space";

      # Make clipboard work with Neovim, Tmux and OSX
      shell = "${pkgs.fish}/bin/fish";

      # Use 256 colors
      terminal = "xterm-256color";
    };

    wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./.config/wezterm/config.lua;
    };

    xplr = {
      enable = true;

      # Optional params:
      plugins = {
        trash-cli = pkgs.fetchFromGitHub {
          owner = "sayanarijit";
          repo = "trash-cli.xplr";
          rev = "2c5c8c64ec88c038e2075db3b1c123655dc446fa";
          sha256 = "sha256-Yb6meF5TTVAL7JugPH/znvHhn588pF5g1luFW8YYA7U=";
        };
        tri-pane = pkgs.fetchFromGitHub {
          owner = "sayanarijit";
          repo = "tri-pane.xplr";
          rev = "v0.20.2";
          sha256 = "sha256-iUpaTfsYz4vdmfoVbk//cEvK3GqsLfeR84y5Pzj8j/Q=";
        };
        tree-view = pkgs.fetchFromGitHub {
          owner = "sayanarijit";
          repo = "tree-view.xplr";
          rev = "v0.1.4";
          sha256 = "sha256-4iuJPNenHFX7izZXFSlP4DXG3qKkvFbR7+9zP4UzanQ=";
        };
        zoxide = pkgs.fetchFromGitHub {
          owner = "sayanarijit";
          repo = "zoxide.xplr";
          rev = "e50fd35db5c05e750a74c8f54761922464c1ad5f";
          sha256 = "sha256-ZiOupn9Vq/czXI3JHvXUlAvAFdXrwoO3NqjjiCZXRnY=";
        };
      };
      extraConfig = ''
        require("trash-cli").setup()
        require("tri-pane").setup()
        require("tree-view").setup()
        require("zoxide").setup()

        xplr.config.modes.builtin.default.key_bindings.on_key["e"] = {
          help = "edit in Neovim",
          messages = {
            {
              BashExecSilently0 = [=[
                nvim "$\{XPLR_FOCUS_PATH:?}"
              ]=]
            },
          },
        }
      '';
    };

    zoxide = {
      enable = true;
    };
  };
}
