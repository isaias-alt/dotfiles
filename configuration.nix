{ ... }:

{
  # Determinate already manages the Nix deamon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "macuser";
  users.users.macuser = {
    home = "/Users/macuser";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = false; # keep the menu bar always visible
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    user = "macuser";
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "herdr"
      "bash"
      "colima"
      "docker"
      "docker-buildx"
      "docker-compose"
      "flyctl"
      "fnm"
      "gh"
      "git"
      "node"
      "pnpm"
      "postgresql@14"
      "powerlevel10k"
      "pure"
      "shfmt"
      "tree-sitter-cli"
      "zoxide"
      "zsh-autosuggestions"
      "zsh-syntax-highlighting"
      "unar"
    ];
    casks = [
      "wezterm"
      "claude-code"
      "font-meslo-lg-nerd-font"
      "postman"
      "temurin@21"
      "visual-studio-code"
      "vorssaint"
      "warp"
    ];
  };
}
