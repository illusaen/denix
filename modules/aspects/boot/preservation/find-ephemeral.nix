{
  den.aspects.boot.preservation.find-ephemeral = {
    nixos =
      {
        host,
        config,
        lib,
        self',
        ...
      }:
      let
        inherit (host.preservation) persistMount;
        cfg = config.preservation.preserveAt.${persistMount};

        combined =
          attr:
          cfg.${attr}
          ++ lib.pipe cfg.users [
            builtins.attrNames
            (map (u: cfg.users.${u}.${attr}))
            lib.flatten
          ];

        filterPaths =
          configAttr: pathSegment:
          lib.pipe configAttr [
            combined
            (builtins.catAttrs pathSegment)
          ];

        persisted = builtins.toJSON {
          # preservation.preserveAt."/persisted".directories => { directory = "/etc/folder"; ...}
          directories = filterPaths "directories" "directory";
          files = filterPaths "files" "file";
        };
      in
      {
        environment.systemPackages = [
          (self'.packages.find-ephemeral-persist.override { inherit persisted; })
          (self'.packages.find-orphaned-persist.override {
            inherit persistMount persisted;
          })
        ];
        environment.etc."persisted-paths.json".text = persisted;
      };
  };
}
