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
    alacritty = {
      enable = hasGui;

      settings = {
        cursor = {
          style = "Block";
          unfocused_hollow = true;
        };

        env.TERM = "xterm-256color";

        font = {
          normal = {
            family = "FiraCode Nerd Font Mono";
            style = "Regular";
          };
          bold = {
            family = "FiraCode Nerd Font Mono";
            style = "Bold";
          };
          italic = {
            family = "FiraCode Nerd Font Mono";
            style = "Italic";
          };
          bold_italic = {
            family = "FiraCode Nerd Font Mono";
            style = "Bold-Italic";
          };
          size = 16.0;
        };

        hints = {
          enabled = [
            {
              binding = {
                mods = "Command";
                key = "Period";
              };
              command = "open";
              hyperlinks = true;
            }
          ];
        };

        import = [
          "${config.xdg.configHome}/alacritty/catppuccin/catppuccin-macchiato.yml"
        ];

        key_bindings = [
          {
            key = "K";
            mods = "Command";
            chars = "ClearHistory";
          }
          {
            key = "V";
            mods = "Command";
            action = "Paste";
          }
          {
            key = "C";
            mods = "Command";
            action = "Copy";
          }
          {
            key = "Key0";
            mods = "Command";
            action = "ResetFontSize";
          }
          {
            key = "Equals";
            mods = "Command";
            action = "IncreaseFontSize";
          }
          {
            key = "Minus";
            mods = "Command";
            action = "DecreaseFontSize";
          }
        ];

        selection = {
          # This string contains all characters that are used as separators for
          # "semantic words" in Alacritty.
          semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
          # When set to `true`, selected text will be copied to the primary clipboard.
          save_to_clipboard = true;
        };

        window = {
          # decorations = "None";
          decorations_theme_variant = "Dark";
          dynamic_padding = true;
          dynamic_title = true;
          option_as_alt = "Both";
          padding = {
            x = 10;
            y = 0;
          };
        };
      };
    };

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
      enableAliases = true;
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
        vimr = {
          body = "nvr --servername (nvr --serverlist | tail -n1) --remote-silent";
          description = "open file with nvim in existing instance";
          wraps = "nvr";
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

        ${
          if isDarwin
          then ''
            # homebrew
            eval "$(/opt/homebrew/bin/brew shellenv)"
          ''
          else ''
          ''
        }
      '';

      shellAbbrs = {
        gci = "git checkout-interactive";
        t = "tmux";
        tf = "terraform";
        v = "vim";
      };

      shellAliases = {
        cat = "bat";
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

      delta.enable = true;

      aliases = {
        checkout-interactive = "!git checkout $(git branch | fzf | xargs)";
      };

      extraConfig = {
        commit = {
          gpgsign = true;
        };
        core = {
          fsmonitor = true;
          untrackedCache = true;
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

    kitty = {
      enable = hasGui;
      extraConfig = ''
        map kitty_mod+t no_op
      '';
      font = {
        name = "FiraCode Nerd Font Mono";
        size = 16;
      };
      keybindings = {
        # "cmd+d" = "launch --location=vsplit --cwd=current";
        # "cmd+shift+d" = "launch --location=hsplit --cwd=current";

        # "cmd+[" = "previous_window";
        # "cmd+]" = "next_window";

        # "cmd+1" = "goto_tab 1";
        # "cmd+2" = "goto_tab 2";
        # "cmd+3" = "goto_tab 3";
        # "cmd+4" = "goto_tab 4";
        # "cmd+5" = "goto_tab 5";
        # "cmd+6" = "goto_tab 6";
        # "cmd+7" = "goto_tab 7";
        # "cmd+8" = "goto_tab 8";
        # "cmd+9" = "goto_tab 9";
      };
      settings = {
        enabled_layouts = "splits:split_axis=horizontal";
        font_features = "+cv02 +cv05 +cv09 +cv14 +ss04 +cv16 +cv31 +cv25 +cv26 +cv32 +cv28 +ss10 +zero +onum";
        # hide_window_decorations = "yes";
        # macos_option_as_alt = "yes";
        # macos_titlebar_color = "background";
        tab_bar_min_tabs = 2;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
        window_padding_width = "0 10 0 10";
      };
      shellIntegration = {
        enableFishIntegration = true;
      };
      theme = "Catppuccin-Macchiato";
    };

    neovim = {
      defaultEditor = true;
      enable = true;
      extraPackages = [pkgs.gcc];
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
      escapeTime = 0;

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
        bind -n M-t new-window -a -c "#{pane_current_path}"
        bind -n M-d split-window -h -c "#{pane_current_path}"
        bind -n M-D split-window -v -c "#{pane_current_path}"

        # Status bar
        set-option -g status-position top
        set -g status 2 # 2 lines high
        set -g "status-format[1]" "" # blank line

        # Fullscreen
        bind -n M-f resize-pane -Z

        # Kill shortcuts
        bind -n C-M-w kill-window
        bind -n C-M-q confirm -p "Kill this tmux session?" kill-session

        # Cycle previous/next pane
        bind -n M-[ select-pane -t :.-
        bind -n M-] select-pane -t :.+

        # Switch windows
        bind -n M-\{ previous-window
        bind -n M-\} next-window

        bind -n M-1 select-window -t 1
        bind -n M-2 select-window -t 2
        bind -n M-3 select-window -t 3
        bind -n M-4 select-window -t 4
        bind -n M-5 select-window -t 5
        bind -n M-6 select-window -t 6
        bind -n M-7 select-window -t 7
        bind -n M-8 select-window -t 8
        bind -n M-9 select-window -t 9

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
        {
          plugin = tmuxPlugins.catppuccin.overrideAttrs (_: {
            src = fetchFromGitHub {
              owner = "catppuccin";
              repo = "tmux";
              rev = "89ad057ebd47a3052d55591c2dcab31be3825a49";
              hash = "sha256-4JFuX9clpPr59vnCUm6Oc5IOiIc/v706fJmkaCiY2Hc=";
            };
          });
          extraConfig = ''
            set -g @catppuccin_flavour 'mocha'
            set -g @catppuccin_window_tabs_enabled on
            set -g @catppuccin_date_time_text "%H:%M"

            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_right_separator " "
            set -g @catppuccin_window_middle_separator " █"
            set -g @catppuccin_window_number_position "right"

            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"

            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W"

            set -g @catppuccin_status_modules_right "date_time"
            set -g @catppuccin_status_left_separator  " "
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_right_separator_inverse "no"
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"

            set -g @catppuccin_directory_text "#{pane_current_path}"

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

    zoxide = {
      enable = true;
    };
  };
}
