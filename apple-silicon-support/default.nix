{ pkgs-systemd-boot, ... }:
{ ... }:

{
  imports = [
    (import ./modules/default.nix { inherit pkgs-systemd-boot; })
  ];
}
