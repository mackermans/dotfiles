{
  config,
  lib,
  osConfig,
  pkgs,
  isDarwin,
  ...
}: {
  programs = {
    # better "cat" util
    bat = {
      enable = true;
      config = {
        theme = "tokyonight_moon";
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
        trim = {
          body = "sed 's/^[ \\t]*//;s/[ \\t]*$//';";
          description = "trim whitespace";
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
        # {
        #   name = "tide";
        #   inherit (pkgs.fishPlugins.tide) src;
        # }
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

        # TokyoNight Moon for FZF
        # https://github.com/folke/tokyonight.nvim/blob/78cc1ae48a26990dd028f4098892a5d6c041e194/extras/fzf/tokyonight_moon.sh
        set --export FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS \
          --highlight-line \
          --info=inline-right \
          --ansi \
          --layout=reverse \
          --border=none
          --color=bg+:#2d3f76 \
          --color=bg:#1e2030 \
          --color=border:#589ed7 \
          --color=fg:#c8d3f5 \
          --color=gutter:#1e2030 \
          --color=header:#ff966c \
          --color=hl+:#65bcff \
          --color=hl:#65bcff \
          --color=info:#545c7e \
          --color=marker:#ff007c \
          --color=pointer:#ff007c \
          --color=prompt:#65bcff \
          --color=query:#c8d3f5:regular \
          --color=scrollbar:#589ed7 \
          --color=separator:#ff966c \
          --color=spinner:#ff007c \
        "

        # fzf end

        # neovim
        set --export EDITOR nvim

        # bun
        set --export BUN_INSTALL "$HOME/.bun"
        fish_add_path $BUN_INSTALL/bin

        # theme
        fish_config theme choose tokyonight_moon

        # ~/.local/bin for user-installed binaries
        fish_add_path "$HOME/.local/bin"

        # pnpm
        set --export PNPM_HOME "$HOME/.local/share/pnpm"
        fish_add_path "$PNPM_HOME"

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
        jbd = "jj bookmark delete (git branch | fzf | trim)";
        jbl = "jj bookmark list";
        jbs = "jj bookmark set (git branch | fzf | trim)";

        gci = "git checkout-interactive";
        t = "tmux";
        tf = "terraform";
        v = "vim";
      };

      shellAliases = {
        cat = "bat";
        vim = "nvim";
        vimdiff = "vim -d";
      };
    };

    # git version control
    git = {
      enable = true;

      extraConfig = {
        commit = {
          gpgsign = true;
        };
        core = {
          pager = "delta";
          untrackedCache = true;
        };
        delta = {
          line-numbers = true;
          navigate = true; # use n and N to move between diff sections

          # TokyoNight Moon for Delta
          # https://github.com/folke/tokyonight.nvim/blob/main/extras/delta/tokyonight_moon.gitconfig
          minus-style = "syntax \"#3a273a\"";
          minus-non-emph-style = "syntax \"#3a273a\"";
          minus-emph-style = "syntax \"#6b2e43\"";
          minus-empty-line-marker-style = "syntax \"#3a273a\"";
          line-numbers-minus-style = "#e26a75";
          plus-style = "syntax \"#273849\"";
          plus-non-emph-style = "syntax \"#273849\"";
          plus-emph-style = "syntax \"#305f6f\"";
          plus-empty-line-marker-style = "syntax \"#273849\"";
          line-numbers-plus-style = "#b8db87";
          line-numbers-zero-style = "#3b4261";
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
        fix = {
          tool-command = ["pnpm" "prettier"];
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

    lazygit = {
      enable = true;
      settings = {
        # TokyoNight Moon for Lazygit
        # https://github.com/folke/tokyonight.nvim/blob/main/extras/lazygit/tokyonight_moon.yml
        gui = {
          nerdFontsVersion = "3";
          theme = {
            activeBorderColor = ["#ff966c" "bold"];
            inactiveBorderColor = ["#589ed7"];
            searchingActiveBorderColor = ["#ff966c" "bold"];
            optionsTextColor = ["#82aaff"];
            selectedLineBgColor = ["#2d3f76"];
            cherryPickedCommitFgColor = ["#82aaff"];
            cherryPickedCommitBgColor = ["#c099ff"];
            markedBaseCommitFgColor = ["#82aaff"];
            markedBaseCommitBgColor = ["#ffc777"];
            unstagedChangesColor = ["#c53b53"];
            defaultFgColor = ["#c8d3f5"];
          };
        };
      };
    };

    # suggest packages from nixpkgs when command not found using nix-index
    command-not-found.enable = false;
    nix-index.enable = true;

    nushell = {
      enable = true;
    };

    oh-my-posh = {
      enable = true;
      settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ./.config/oh-my-posh/config.toml));
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
        set -g default-terminal "screen-256color"

        # Bug in tmux 3.5: Fish as default-shell not respected
        # https://github.com/nix-community/home-manager/issues/5952#issuecomment-2410207554
        set -g default-command "$SHELL"

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

        # TokyoNight colors for Tmux
        # https://github.com/folke/tokyonight.nvim/blob/78cc1ae48a26990dd028f4098892a5d6c041e194/extras/tmux/tokyonight_moon.tmux
        set -g mode-style "fg=#82aaff,bg=#3b4261"
        set -g message-style "fg=#82aaff,bg=#3b4261"
        set -g message-command-style "fg=#82aaff,bg=#3b4261"
        set -g pane-border-style "fg=#3b4261"
        set -g pane-active-border-style "fg=#82aaff"
        set -g status "on"
        set -g status-justify "left"
        set -g status-style "fg=#82aaff,bg=#1e2030"
        set -g status-left-length "100"
        set -g status-right-length "100"
        set -g status-left-style NONE
        set -g status-right-style NONE
        set -g status-left "#[fg=#1b1d2b,bg=#82aaff,bold] #S #[fg=#82aaff,bg=#1e2030,nobold,nounderscore,noitalics]"
        set -g status-right "#[fg=#1e2030,bg=#1e2030,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#1e2030] #{prefix_highlight} #[fg=#3b4261,bg=#1e2030,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#3b4261] %Y-%m-%d  %I:%M %p #[fg=#82aaff,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#1b1d2b,bg=#82aaff,bold] #h "
        if-shell '[ "$(tmux show-option -gqv "clock-mode-style")" == "24" ]' {
          set -g status-right "#[fg=#1e2030,bg=#1e2030,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#1e2030] #{prefix_highlight} #[fg=#3b4261,bg=#1e2030,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#3b4261] %Y-%m-%d  %H:%M #[fg=#82aaff,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#1b1d2b,bg=#82aaff,bold] #h "
        }
        setw -g window-status-activity-style "underscore,fg=#828bb8,bg=#1e2030"
        setw -g window-status-separator ""
        setw -g window-status-style "NONE,fg=#828bb8,bg=#1e2030"
        setw -g window-status-format "#[fg=#1e2030,bg=#1e2030,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#1e2030,bg=#1e2030,nobold,nounderscore,noitalics]"
        setw -g window-status-current-format "#[fg=#1e2030,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#3b4261,bold] #I  #W #F #[fg=#3b4261,bg=#1e2030,nobold,nounderscore,noitalics]"
        # tmux-plugins/tmux-prefix-highlight support
        set -g @prefix_highlight_output_prefix "#[fg=#ffc777]#[bg=#1e2030]#[fg=#1e2030]#[bg=#ffc777]"
        set -g @prefix_highlight_output_suffix ""
      '';

      # Use vi keybindings
      keyMode = "vi";

      # Use mouse for pane navigation and scrolling
      mouse = true;

      plugins = with pkgs; [
        tmuxPlugins.open
        tmuxPlugins.yank
        tmuxPlugins.vim-tmux-navigator
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
      prefix = "C-a";

      # Make clipboard work with Neovim, Tmux and OSX
      shell = "${pkgs.fish}/bin/fish";

      # Use 256 colors
      terminal = "xterm-256color";
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
