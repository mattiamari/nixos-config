{ pkgs, ... }:
{

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    # https://wiki.hyprland.org/0.40.0/Configuring/Variables
    settings = {
      monitor = [
        "HDMI-A-2,3840x2160@60,auto,1.0,bitdepth,10"
        "Unknown-1,disable"
      ];

      input = {
        kb_layout = "us,it";
        kb_options = "grp:ctrl_space_toggle";
        numlock_by_default = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
      };

      decoration = {
        rounding = 10;
      };

      animations = {
        enabled = true;
      };

      misc = {
        # force "hyprland logo" wallpaper
        force_default_wallpaper = 0;

        # prevents "your XDG_CURRENT_DESKTOP seems to be managed externally" warning
        disable_xdg_env_checks = true;
      };

      debug = {
        disable_logs = true;
      };

      exec-once = [
        "${pkgs.dunst}/bin/dunst"
        "${pkgs.waybar}/bin/waybar"
      ];

      "$mod" = "SUPER";

      # https://wiki.hyprland.org/0.45.0/Configuring/Dispatchers
      bind =
        let
          monitorDev = "/dev/i2c-4";
        in
        [
          "$mod, Q, exec, alacritty"
          "$mod, E, exec, thunar"
          "$mod, SPACE, exec, rofi -show combi"
          "$mod, W, exec, rofi -show calc -modi calc -no-show-match -no-sort"
          "$mod, C, killactive"
          "$mod, F, fullscreen, 1"
          "$mod, M, exec, rofi -show power-menu -modi power-menu:${pkgs.rofi-power-menu}/bin/rofi-power-menu"
          ", XF86Calculator, exec, rofi -show calc -modi calc -no-show-match -no-sort"

          # float and pin (i.e. picture in picture that follows you across workspaces)
          "$mod, P, toggleFloating"
          "$mod, P, pin, active"
          #"$mod, P, fakefullscreen"

          # move focus with arrow keys
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # move window
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"

          # resize window
          "$mod CONTROL, left, resizeactive, -10% 0%"
          "$mod CONTROL, right, resizeactive, 10% 0%"
          "$mod CONTROL, up, resizeactive, 0% -10%"
          "$mod CONTROL, down, resizeactive, 0% 10%"

          # switch to prev/next workspace
          "$mod ALT, left, workspace, e-1"
          "$mod ALT, right, workspace, e+1"

          # volume control
          ",code:123, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
          ",code:122, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",code:121, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          # media control
          ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
          ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
          ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"

          # brightness control
          ",XF86MonBrightnessUp, exec, ddccontrol -r 0x10 -W +5 dev:${monitorDev}"
          ",XF86MonBrightnessDown, exec, ddccontrol -r 0x10 -W -5 dev:${monitorDev}"
          "$mod, F2, exec, ddccontrol -r 0x10 -w 100 dev:${monitorDev}"
          "$mod, F1, exec, ddccontrol -r 0x10 -w 50 dev:${monitorDev}"

          # screenshots
          ",Print,exec,${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
        ]
        # switch workspaces
        ++ builtins.genList (n: "$mod, ${toString (n + 1)}, workspace, ${toString (n + 1)}") 9

        # move windows between workspaces
        ++ builtins.genList (n: "$mod SHIFT, ${toString (n + 1)}, movetoworkspace, ${toString (n + 1)}") 9;

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrule = [
        # Smart gaps
        "border_size 0, rounding 0, match:float no, match:workspace w[tv1]"
        "border_size 0, rounding 0, match:float no, match:workspace f[1]"

        # "tile, title:^web\.whatsapp\.com.*$"
        # "float, title:Calculator"
        # "float, title:^Extension.*Bitwarden.*$"
      ];

      workspace = [
        # Smart gaps
        "w[tv1], gapsin:0, gapsout:0"
        "f[1], gapsout:0, gapsin:0"
      ];
    };
  };

  services.hyprpaper =
    let
      wall1 = "~/Pictures/wallpapers/yLXrKS.jpg";
    in
    {
      enable = true;
      settings = {
        splash = false;
        ipc = "on";

        preload = [
          wall1
        ];

        wallpaper = [
          ",${wall1}"
        ];
      };
    };

}
