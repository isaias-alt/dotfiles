{ config, pkgs, user, ... }:

let
  username = "macuser";
  homeDir = "/Users/lucascodev";
  dotfiles = "${homeDir}/.dotfiles";
in

{
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep # fast search
    fd # fast find
    eza # better ls
    fzf # fuzzy finder
    jq # json on the command line
    neovim
    go # official Go toolchain
    delta # side-by-side diffs for lazygit
    # the font everything renders in
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
    CLAUDE_CODE_AUTO_COMPACT_WINDOW = "500000"; # compact at a fixed 500k tokens instead of Claude Code's per-model default
    CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
  };
  home.sessionPath = [
    "${config.home.homeDirectory}/flutter/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

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
      export PATH="$HOME/.no-mistakes/bin:$PATH"
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
      status = "git status";
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
      # Colors match the solarized-osaka palette (same theme as nvim/wezterm/herdr).
      directory.style = "bold #268bd3";
      git_branch.style = "bold #d23681";
      git_status.style = "#b28500";
      character = {
        success_symbol = "[❯](bold #849900)";
        error_symbol = "[❯](bold #e05561)";
      };
      cmd_duration.format = "[$duration](#b28500) ";
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
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/AGENTS.md";

}
