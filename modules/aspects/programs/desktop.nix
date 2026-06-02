{ den, ... }:
{
  den.aspects.programs.includes = with den.aspects.programs; [
    onepassword
    bambu-studio
    browser
    chat
    image-editor
    llm
    steam
    vscode
    word
    youtube
  ];
}
