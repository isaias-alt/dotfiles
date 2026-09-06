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
    ripgrep # fast search
    fd # fast find
    eza # better ls
    fzf # fuzzy finder
    jq # json on the command line
    neovim
    delta # side-by-side diffs for lazygit
    # the font everything renders in
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";
  home.sessionPath = [ "${config.home.homeDirectory}/flutter/bin" ];

  programs.zoxide.enable = true;

  programs.lazygit = {
    enable = true;
    settings = {
      gui.sidePanelWidth = 0.2; # more room for the side-by-side diff
      git.pagers = [
        { colorArg = "never"; pager = "delta --side-by-side --dark --paging=never"; }
      ];
    };
  };

  programs.zsh = {
    enable = true;
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    autosuggestion.enable = true; # ghost text from history
    syntaxHighlighting.enable = true; # commands turn green when valid
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
      cc = "claude";
      ls = "eza";
      ll = "eza -la";
      la = "eza -a";
      l = "eza -l";
      lt = "eza -TL 2";
      cd = "z";
    };
  };

  programs.git.settings.user = {
    name = "isaias-alt";
    email = "cascolucasisaias@gmail.com";
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      # Colors match the atom-one-night-flat palette (same theme as nvim/wezterm/herdr).
      directory.style = "bold #4aa5f0";
      git_branch.style = "bold #c162de";
      git_status.style = "#d18f52";
      character = {
        success_symbol = "[❯](bold #8cc265)";
        error_symbol = "[❯](bold #e05561)";
      };
      cmd_duration.format = "[$duration](#d18f52) ";
    };
  };

  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/skills";
  home.file.".claude/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/themes";

}
