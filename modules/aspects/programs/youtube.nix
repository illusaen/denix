{
  den.aspects.programs.youtube = {
    provides.to-users.persistUser.directories = [".config/YouTube Music Desktop App"];

    os = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        yt-dlp
        ytmdesktop
      ];

      environment.etc."yt-dlp.conf".text = ''
        -t aac
        --cookies-from-browser chrome
      '';
    };
  };
}
