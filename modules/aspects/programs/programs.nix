{ den, ... }:
{
  den.aspects.programs.includes = with den.aspects.programs; [
    onepassword
    bambu-studio
    browser
    chat
    codex
    image-editor
    image-viewer
    notes
    ollama
    nautilus
    steam
    wallpaper
    vscode
    word
    youtube
  ];
}
