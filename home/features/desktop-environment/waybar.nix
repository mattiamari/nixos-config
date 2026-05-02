{ pkgs, config, ... }:
{

  programs.waybar = {
    enable = true;
    systemd.enable = false;
    style = ./waybar.css;

    # https://github.com/Alexays/Waybar/wiki/Configuration
    settings = {
      main = {
        layer = "top";
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "hyprland/language"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
          "clock"
          "tray"
        ];

        "hyprland/workspaces" = {
          active-only = false;
        };

        "hyprland/language" = {
          format = "{}";
          "format-en" = "EN";
          "format-it" = "IT";
        };

        clock = {
          tooltip-format = "{calendar}";
          format-alt = "{:%Y-%m-%d %H:%M}";
        };

        cpu = {
          format = "  {usage}%  {avg_frequency}Ghz";
          on-click = "${config.desktop.terminal} -e '${pkgs.btop}/bin/btop'";
        };

        memory = {
          format = "  {}%";
        };

        temperature = {
          format = " {temperatureC}°C";
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 85;
        };

        network = {
          format-ethernet = "󰈀  {ipaddr}";
          format-wifi = "󰖩 {essid} ({signalStrength}%)";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon}  {volume}%  {format_source}";
          format-muted = "󰝟 {format_source}";
          format-source = "󰍬 {volume}%";
          format-source-muted = "󰍭";
          format-icons = {
            default = [
              ""
              ""
            ];
          };
          ignored-sinks = [ "Easy Effects Sink" ];
          on-click = "${pkgs.pwvucontrol}/bin/pwvucontrol";
        };

        tray = {
          icon-size = 20;
        };
      };
    };
  };

}
