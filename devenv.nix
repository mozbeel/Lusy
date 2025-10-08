{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  zigPkg = inputs.zig-overlay.packages.${pkgs.stdenv.hostPlatform.system}."0.15.1";
  zlsPkg = inputs.zls.packages.${pkgs.stdenv.hostPlatform.system}.zls;
in
{
  packages = [
    pkgs.git
    pkgs.tree
    pkgs.cloc
  ];

  languages.zig = {
    enable = true;
    package = zigPkg;
    zls.package = zlsPkg;
  };
}
