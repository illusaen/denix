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
    ollama
    nemo
    steam
    switch-input
    vscode
    word
    youtube
  ];
}
