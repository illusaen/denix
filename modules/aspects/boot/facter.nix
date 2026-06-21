{rootPath, ...}: {
  den.aspects.boot.facter = {
    nixos = {host, ...}: {
      hardware.facter.reportPath = "${rootPath}/hosts/${host.name}/facter.json";
    };
  };
}
