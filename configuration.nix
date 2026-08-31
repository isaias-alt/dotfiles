{ ... }:

{
  # Determinate already manages the Nix deamon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "lucascodev";
  system.stateVersion = 6;
}
