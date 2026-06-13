{
  pkgs,
  nautilusStyle ? "stable",
  colorVariants ? [ "dark" ],
  opacityVariants ? [ "normal" ],
  schemeVariants ? [ "standard" ],
  altVariants ? [ "normal" ],
  themeVariants ? [ "default" ],
}:
pkgs.whitesur-gtk-theme.override {
  inherit
    nautilusStyle
    colorVariants
    opacityVariants
    schemeVariants
    altVariants
    themeVariants
    ;
}
