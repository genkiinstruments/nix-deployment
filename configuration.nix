{ pkgs, config, lib, ... }:
{
  imports = [
    ./avahi.nix
    ./zram.nix
    ./yggdrasil.nix
    ./motd.nix
#    ./examples/gnome.nix
#    ./examples/xfce4.nix
#    ./examples/netdata.nix
#    ./examples/vaultwarden.nix
  ];
  environment.systemPackages = with pkgs; [
    vim
    git
    libgpiod
    qrencode
  ];
  services.openssh.enable = true;
  users = {
    users.default = {
      password = "default";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };
  system.autoUpgrade = {
    allowReboot = true;
    enable = true;
    flake = "github:genkiinstruments/nix-deployment";
    dates = "minutely";
    flags = [ "--refresh" ];
  };
  networking = {
    networkmanager.enable = lib.mkForce false;
    interfaces."wlan0".useDHCP = true;
    wireless = {
      interfaces = [ "wlan0" ];
      enable = true;
      networks = {
        DoESLiverpool.psk = "decafbad00";
      };
    };
  };
}
