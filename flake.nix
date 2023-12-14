{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };
  outputs = { self, nixpkgs, nixos-hardware }: rec {
    images = {
      pi = (self.nixosConfigurations.pi.extendModules {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          {
            disabledModules = [ "profiles/base.nix" ];
            sdImage.compressImage = false;
          }
        ];
      }).config.system.build.sdImage;
    };
    packages.x86_64-linux = {
      pi-image = images.pi;
      deploy = nixpkgs.legacyPackages.x86_64-linux.writeScriptBin "deploy" ''
        nix copy ${self.nixosConfigurations.pi.config.system.build.toplevel} --to ssh://default@genki.local
        ssh -t default@genki.local 'sudo nix-env -p /nix/var/nix/profiles/system --set ${self.nixosConfigurations.pi.config.system.build.toplevel}'
        ssh -t default@genki.local 'sudo ${self.nixosConfigurations.pi.config.system.build.toplevel}/bin/switch-to-configuration switch'
      '';
    };
    packages.aarch64-linux.pi-image = images.pi;
    nixosConfigurations = rec {
      genki = pi;
      pi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./configuration.nix
          ./base.nix
        ];
      };
    };
  };
}

