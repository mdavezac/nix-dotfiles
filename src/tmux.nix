{
  config,
  pkgs,
  lib,
  ...
}: let
  attach = "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace";
in {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    aggressiveResize = false;
    historyLimit = 100000;
    resizeAmount = 5;
    escapeTime = 0;
    terminal = "xterm-kitty";
    secureSocket = false;
    plugins = [pkgs.tmuxPlugins.cpu pkgs.tmuxPlugins.nord];
    extraConfig = ''
      is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(ssh|view|n?vim?x?)(diff)?$"'

      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' { if -F '#{pane_at_left}' "" 'select-pane -L' }
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' { if -F '#{pane_at_bottom}' "" 'select-pane -D' }
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' { if -F '#{pane_at_top}' "" 'select-pane -U' }
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' { if -F '#{pane_at_right}' "" 'select-pane -R' }

      bind-key -T copy-mode-vi 'C-h' if -F '#{pane_at_left}' "" 'select-pane -L'
      bind-key -T copy-mode-vi 'C-j' if -F '#{pane_at_bottom}' "" 'select-pane -D'
      bind-key -T copy-mode-vi 'C-k' if -F '#{pane_at_top}' "" 'select-pane -U'
      bind-key -T copy-mode-vi 'C-l' if -F '#{pane_at_right}' "" 'select-pane -R'

      set-option -g default-command "${attach} -l fish"
      set-option -g default-shell ${pkgs.fish}/bin/fish

      bind-key "F" run-shell -b ${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/main.sh
      set -g status off
    '';
  };
}
