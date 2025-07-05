{ config, pkgs, inputs, lib, ... }:

let
  findFFProfile = ''
    ls "$HOME/.mozilla/firefox" | grep '\.default-release$' | head -n1
  '';
in {
  programs = {
    home-manager = { enable = true; };
    nushell = {
      enable = true;
      shellAliases = {
        "cd" = "z";
        "cd.." = "z ..";
        ".." = "z ..";
        "g" = "git";
        "ll" = "ls -l";
        "cls" = "clear";
        "reload-debug" = "sudo nixos-rebuild switch --flake ~/dot";
        "reload" = "nh os switch ~/dot";
        "update" = "sudo nix flake update --flake ~/dot";
        "clean" = "nh clean all --keep-since 7d";
        "dev" = "nix-shell --command 'nu'";
        "clock" = "termdown -zsf roman";
      };
      settings = { show_banner = false; };
    };
    # carapace = {
    #   enable = true;
    #   enableNushellIntegration = true;
    # };
    starship = {
      enable = true;
      settings = { add_newline = true; };
    };
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
    fastfetch = { enable = true; };
    nh = {
      enable = true;
      clean.enable = true;
      flake = "/home/lucas/dot/flake.nix";
    };
    git = {
      enable = true;
      userEmail = "lucas@somfic.dev";
      userName = "Lucas";
    };
    gh = { enable = true; };
    vscode = { enable = true; };
    kitty = {
      enable = true;
      settings = { window_padding_width = 10; };
    };
    waybar = { enable = true; };
    rofi = { enable = true; };
    direnv = { enable = true; };
    lazydocker = { enable = true; };
    firefox = {
      enable = true;

    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";
      cursor = {
        inactive_timeout = 10;
        no_hardware_cursors = true;
        hide_on_key_press = false;
      };
      monitor = [
        ", preferred, auto, auto"
        "DP-2, preferred, auto-right, 1"
        "DP-3, preferred, auto-left, 1"
      ];
      general = {
        border_size = 0;
        gaps_in = 7;
        gaps_out = 14;
      };
      decoration = {
        rounding = 15;
        blur = {
          size = 8;
          passes = 3;
          brightness = 0.45;
          vibrancy = 1.0;
          noise = 5.0e-2;
          new_optimizations = true;
          ignore_opacity = true;
        };
        shadow = {
          enabled = false;
          range = 8;
        };
      };
      windowrulev2 = [ "float,move 10 10,title:^(initialkitty)$" ];
      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
      bind = [
        "$mod, R, exec, rofi -show drun -show-icons"
        "$mod, V, togglefloating"
        "$mod, F, exec, firefox"
        "$mod, C, exec, code"
        "$mod, S, exec, spotify"
        "$mod, D, exec, discord"
        "$mod, T, exec, kitty"
        "$mod, J, togglesplit,"
        "$mod, M, exit"

        # moving focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # moving windows
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # closing windows
        "$mod, mouse:274, killactive"
        "$mod, Q, killactive"

        ", Print, exec, grimblast copy area"
      ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]) 9));

      exec-once = [
        "kitty --title initialkitty -e bash -ic 'fastfetch; exec nu' & waybar"
      ];
    };
  };

  home.username = "lucas";
  home.homeDirectory = "/home/lucas";
  home.stateVersion = "25.05";

  home.activation.firefoxBlurCss = lib.mkAfter ''
        profile=$( ${findFFProfile} )
        fullpath="$HOME/.mozilla/firefox/$profile/chrome"
        mkdir -p "$fullpath"
        cat > "$fullpath/userContent.css" <<'EOF'
    @-moz-document url-prefix("http://"), url-prefix("https://") {
      /* make the page background fully transparent */
      html {
        background: transparent !important;
      }
      /* frosted-glass effect */
      body {
        background-color: rgba(255,255,255,0.3) !important;
        backdrop-filter: blur(15px) !important;
      }
    }
    EOF
  '';

  home.packages = with pkgs; [
    ffmpeg-full
    discord
    betterdiscordctl
    google-chrome
    jetbrains.idea-ultimate
    obs-studio
    mprocs # running multiple processes
    termdown # terminal clock
    just # running commands
    spotify
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
}
