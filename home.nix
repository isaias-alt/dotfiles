{ config, pkgs, ... }:

let 
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = "macuser";
  home.homeDirectory = "/Users/macuser";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];

  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";
  
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
}
