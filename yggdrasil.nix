{ config, pkgs, lib, ... }:
{
  networking = {
    useNetworkd = true;
    firewall.allowedTCPPorts = [ 9001 ];
  };
  services.yggdrasil = {
    enable = true;
    openMulticastPort = true;
    persistentKeys = true;
    settings = {
      "Peers" = [
        "tls://uk1.servers.devices.cwinfo.net:28395"
        "tls://51.38.64.12:28395"
        "tcp://88.210.3.30:65533"
        "tcp://s2.i2pd.xyz:39565"
      ];
      "MulticastInterfaces" = [
        {
          "Regex" = "w.*";
          "Beacon" = true;
          "Listen" = true;
          "Port" = 9001;
          "Priority" = 0;
        }
      ];
      "AllowedPublicKeys" = [];
      "IfName" = "auto";
      "IfMTU" = 65535;
      "NodeInfoPrivacy" = false;
      "NodeInfo" = null;
    };
  };
  systemd.services.radvd ={
    after = [ "yggdrasil.service" ];
    serviceConfig = {
      ExecStart = lib.mkForce "@${config.services.radvd.package}/bin/radvd radvd -n -u radvd -C /run/radvd-config";
      ExecStartPre = let
        script = pkgs.writeShellScript "f" ''
          SUBNET=$(${pkgs.yggdrasil}/bin/yggdrasilctl -json getSelf | ${pkgs.jq}/bin/jq .subnet -r)
          cp --no-preserve=mode ${builtins.toFile "conf" config.services.radvd.config} /run/radvd-config
          sed "s,@YGGDRASIL_PREFIX@,$SUBNET,g" -i /run/radvd-config
        '';
      in "+${script}";
    };
  };
  services.radvd = {
    enable = true;
    config = ''
      interface wlan0
      {
           AdvSendAdvert on;
           prefix @YGGDRASIL_PREFIX@ {
               AdvOnLink on;
               AdvAutonomous on;
           };
           route 200::/7 {};
      };
      interface end0
      {
           AdvSendAdvert on;
           prefix @YGGDRASIL_PREFIX@ {
               AdvOnLink on;
               AdvAutonomous on;
           };
           route 200::/7 {};
      };
    '';
  };
  boot.kernel.sysctl = {
    # Enable IPv6 forwarding
    "net.ipv6.conf.all.forwarding" = "1";
  };
}


