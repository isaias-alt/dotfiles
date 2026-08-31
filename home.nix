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
    eza       # better ls
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];

  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zoxide.enable = true;

  programs.zsh = {
    enable = true;
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
      eval "$(fnm env)"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      main = "git switch main";
      develop = "git switch develop";
      cc = "claude --dangerously-skip-permissions";
      ls = "eza";
      ll = "eza -la";
      la = "eza -a";
      l = "eza -l";
      lt = "eza -TL 2";
      cd = "z";
    };
   };

   home.file.".config/wezterm".source =
     config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
}
