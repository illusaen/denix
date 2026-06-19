{
  wlib,
  lib,
  pkgs,
  config,
  ...
}@top:
let
  topConfig = top.config;
  fakeNixosConfig.systemd = {
    package = pkgs.systemd;
    globalEnvironment = { };
    enableStrictShellChecks = false;
  };
  nixosUtils = import "${pkgs.path}/nixos/lib/utils.nix" {
    inherit lib pkgs;
    config = fakeNixosConfig;
  };
  inherit (nixosUtils) systemdUtils;
  serviceUnit = systemdUtils.lib.serviceToUnit topConfig.service;
in
{
  imports = [ wlib.modules.constructFiles ];

  options.service = lib.mkOption {
    type = lib.types.submodule [
      systemdUtils.unitOptions.stage2ServiceOptions
      systemdUtils.lib.unitConfig
      (
        { config, ... }:
        {
          config = {
            enable = lib.mkDefault false;
            name = lib.mkDefault "${config.serviceName}.service";
            description = lib.mkDefault "Start ${config.serviceName}";
            wantedBy = lib.mkDefault [ "graphical-session.target" ];
            partOf = lib.mkDefault [ "graphical-session.target" ];
            requires = lib.mkDefault [ "graphical-session-pre.target" ];
            after = lib.mkDefault [
              "graphical-session.target"
              "graphical-session-pre.target"
            ];
            enableStrictShellChecks = lib.mkDefault true;
            serviceConfig = {
              ExecStart = lib.mkDefault config.executable;
              Restart = lib.mkDefault "on-failure";
              RestartSec = lib.mkDefault 2;
            };
          };
          options = {
            serviceName = lib.mkOption {
              type = lib.types.str;
              default = topConfig.binName;
              description = "Base service name, without the `.service` suffix.";
            };
            executable = lib.mkOption {
              type = lib.types.str;
              default = topConfig.wrapperPaths.placeholder;
              description = "Executable used as the default service ExecStart.";
            };
          };
        }
      )
    ];
    default = { };
    description = "Systemd user service generated into lib/systemd/user.";
  };

  config = lib.mkIf config.service.enable {
    constructFiles.generatedServiceFile = {
      relPath = "lib/systemd/user/${config.service.name}";
      content = serviceUnit.text;
    };
  };
}
