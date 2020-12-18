{ config, pkgs, lib, ... }:
let
  attach = "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace";
in {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    aggressiveResize = true;
    historyLimit = 100000;
    resizeAmount = 5;
    escapeTime = 0;
    terminal = "xterm-kitty";
    secureSocket = false;
    extraConfig = ''
      is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?x?)(diff)?$"'
      bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
      bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
      bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
      bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
      bind -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"

      #  modes
      setw -g clock-mode-colour colour5
      setw -g mode-style 'fg=colour1 bg=colour18 bold'
      # panes
      set -g pane-border-style 'fg=colour19 bg=colour0'
      set -g pane-active-border-style 'bg=colour0 fg=colour9'

      set-option -g default-command "${attach} -l fish"
      set-option -g default-shell ${pkgs.fish}/bin/fish
      set -g status off

      set-option -g aggressive-resize off
    '';
  };
}
