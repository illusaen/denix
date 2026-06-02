{ den, ... }:
{
  den.aspects.programs.includes = with den.aspects.programs; [
    onepassword
    bambu-studio
    browser
    chat
    image-editor
    image-viewer
    llm
    nemo
    steam
    switch-input
    vscode
    word
    youtube
  ];
}
