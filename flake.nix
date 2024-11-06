{
  description = "Apple Silicon support for NixOS";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?rev=41dea55321e5a999b17033296ac05fe8a8b5a257";
    };

    nixpkgs-systemd-boot = {
        # pin the systemd version to one that can boot.
        # See https://github.com/tpwrules/nixos-apple-silicon/issues/248 for more information
        url = "github:nixos/nixpkgs?rev=41dea55321e5a999b17033296ac05fe8a8b5a257";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      flake = false;
    };

    flake-compat.url = "github:nix-community/flake-compat";
  };

  outputs = { self, ... }@inputs:
    let
      # build platforms supported for uboot in nixpkgs
      systems = [ "aarch64-linux" "x86_64-linux" ]; # "i686-linux" omitted

      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
    in
      {
        overlays = rec {
          apple-silicon-overlay = import ./apple-silicon-support/packages/overlay.nix;
          default = apple-silicon-overlay;
        };

        nixosModules = rec {
          apple-silicon-support = import ./apple-silicon-support {
            pkgs-systemd-boot = import inputs.nixpkgs-systemd-boot {};
          };
          default = apple-silicon-support;
        };

        packages = forAllSystems (system:
          let
            pkgs = import inputs.nixpkgs {
              crossSystem.system = "aarch64-linux";
              localSystem.system = system;
              overlays = [
                (import inputs.rust-overlay)
                self.overlays.default
              ];
            };
          in {
            inherit (pkgs) m1n1 uboot-asahi linux-asahi asahi-fwextract mesa-asahi-edge;
            inherit (pkgs) asahi-audio;

            installer-bootstrap =
              let
                installer-system = inputs.nixpkgs.lib.nixosSystem {
                  inherit system;

                  # make sure this matches the post-install
                  # `hardware.asahi.pkgsSystem`
                  pkgs = import inputs.nixpkgs {
                    crossSystem.system = "aarch64-linux";
                    localSystem.system = system;
                    overlays = [ self.overlays.default ];
                  };

                  specialArgs = {
                    modulesPath = inputs.nixpkgs + "/nixos/modules";
                  };

                  modules = [
                    ./iso-configuration
                    { hardware.asahi.pkgsSystem = system; }
                  ];
                };

                config = installer-system.config;
              in (config.system.build.isoImage.overrideAttrs (old: {
                # add ability to access the whole config from the command line
                passthru = (old.passthru or {}) // { inherit config; };
              }));
          });
      };
}
