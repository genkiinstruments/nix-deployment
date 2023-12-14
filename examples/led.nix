{pkgs, ...}:
{
  system.activationScripts.led = {
    text = ''
      ${pkgs.procps}/bin/pkill -9 gpioset || true
      ${pkgs.libgpiod}/bin/gpioset -c gpiochip0 18=1 &
    '';
  };
}
