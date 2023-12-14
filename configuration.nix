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
    #./examples/led.nix
  ];
  environment.systemPackages = with pkgs; [
    vim
    git
    libgpiod
    qrencode
    procps
  ];
  services.openssh.enable = true;
  users = {
    users.default = {
      password = "default";
      isNormalUser = true;
      extraGroups = [ "wheel" "gpio" ];
    };
    groups.gpio = {};
  };

#   systemd.user.services.blinkLED = {
#    description = "Blink LED after rebuild";
#    after = [ "default.target" ];
#    wantedBy = [ "default.target" ];
#    serviceConfig = {
#      ExecStart = let
#        gpioset="${pkgs.libgpiod}/bin/gpioset";
#      in ''
#        ${gpioset} gpioset -c gpiochip0 18=1 &
#      '';
#      User = "default";
#      Group = "default";
#    };
#  };

 systemd.services.turnOnLED = {
   description = "Turn on LED on GPIO pin 18";
   wantedBy = [ "multi-user.target" ];
   serviceConfig = {
     ExecStart = "${pkgs.libgpiod}/bin/gpioset -c gpiochip0 18=1";
     Type = "oneshot";
     RemainAfterExit = true;
   };
 };

  # Change permissions gpio devices
  services.udev.extraRules = ''
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio",MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio  /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
    SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
  '';

  system.autoUpgrade = {
    allowReboot = true;
    enable = true;
    flake = "github:genkiinstruments/nix-deployment";
    dates = "minutely";
    flags = [ "--refresh" ];
  };
  networking = {
    firewall.enable = false;
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
