{
  den,
  ...
}:
{
  den.ctx.user.includes = [ den.aspects.starship ];

  den.aspects.starship = {
    os =
      { pkgs, lib, ... }:
      {
        environment.systemPackages = with pkgs; [ starship ];
        programs.fish.interactiveShellInit = ''
          ${lib.getExe pkgs.starship} init fish | source
        '';
      };

    md =
      { pkgs, lib, ... }:
      let
        tomlFormat = pkgs.formats.toml { };
      in
      {
        file.xdg_config."starship.toml".source = tomlFormat.generate "starship.toml" {
          add_newline = true;
          format = lib.concatStrings [
            "$directory"
            "$hostname"
            "$fill"
            "$git_branch $git_status"
            "$direnv"
            "$nodejs"
            "$python"
            "$c"
            "$cmd_duration"
            "$time"
            "$line_break"
            "$character"
          ];
          c.format = "[ $version  ](fg:foreground)";
          character = {
            success_symbol = "[λ](fg:primary)";
            error_symbol = "[×](fg:bold red)";
          };
          cmd_duration = {
            min_time = 500;
            format = "[$duration  ](fg:yellow)";
          };
          directory = {
            format = "[$path$read_only$truncation_symbol  ](fg:bright-blue)";
            home_symbol = "~";
            truncation_symbol = "…/";
            truncation_length = 3;
            read_only = " 󰌾";
            read_only_style = "bright-red";
          };
          direnv = {
            disabled = false;
            format = "[$allowed  ](fg:foreground)";
            not_allowed_msg = "󱙲";
            allowed_msg = "󰍁";
          };
          fill.symbol = " ";
          git_branch.format = "[$branch](fg:foreground)";
          git_status = {
            ignore_submodules = true;
            format = "[$all_status$ahead_behind  ](fg:bright-red)";
            ahead = "";
            diverged = "󰹹";
            behind = "";
            deleted = "";
            staged = "";
            conflicted = "";
          };
          hostname = {
            ssh_only = true;
            format = "[$hostname](fg:foreground bg:bright-red)";
            disabled = false;
          };
          nodejs = {
            disabled = false;
            format = "[󰎙 $version  ](fg:bright-green)";
          };
          python.format = "[ $version (\($virtualenv\))  ](fg:foreground)";
          time = {
            disabled = false;
            format = "[$time](fg:foreground)";
            time_format = "%H:%M";
          };
        };
      };
  };
}
