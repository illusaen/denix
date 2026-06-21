{
  den.aspects.programs.image-viewer = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        image-roll
      ];
      xdg.mime.defaultApplications = {
        "image/*" = "com.github.weclaw1.ImageRoll.desktop";
      };
    };
  };
}
