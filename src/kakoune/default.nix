{ config, pkgs, lib, ... }:
let
  pyls = pkgs.buildEnv {
    name = "pyls";
    paths = [
      (pkgs.python37.withPackages (p:
        with p; [
          python-language-server
          pyls-black
          pyls-isort
          pyflakes
          rope
        ]))
    ];
    pathsToLink = [ "/bin" "/lib" ];
  };
  lsp_toml = pkgs.substituteAll {
    src = ./lsp.toml;
    pyls = "${pyls}/bin/pyls";
    nixlsp = "${pkgs.rnix-lsp}/bin/rnix-lsp";
  };
  sources = import ../../nix/sources.nix;
  fzf = sources."fzf.kak";
  smarttab = sources."smarttab.kak";
  repl-bridge = sources.kakoune-repl-bridge;
  nord = sources."nord-kakoune";
  powerline = sources."powerline.kak";
in {
  programs.kakoune = {
    enable = true;
    config = {
      showMatching = true;
      indentWidth = 2;
      tabStop = 2;
      colorScheme = "nord";
      numberLines = {
        enable = true;
        relative = true;
        highlightCursor = true;
      };
      scrollOff = {
        columns = 0;
        lines = 0;
      };
      ui = {
        enableMouse = true;
        assistant = "cat";
        setTitle = true;
        statusLine = "bottom";
      };
      hooks = [
        {
          commands = ''
            nop sh %{
              printf %s "$kak_main_reg_dquote" | pbcopy
            }
          '';
          name = "NormalKey";
          option = "y|d|c";
        }
        {
          commands = ''
            try %{
              execute-keys -draft 'h<a-K>\h<ret>'
              map window insert <tab> <c-n>
              map window insert <s-tab> <c-p>
            }
          '';
          name = "InsertCompletionShow";
          option = ".*";
        }
        {
          commands = ''
            try %{
              unmap window insert <tab> <c-n>
              unmap window insert <s-tab> <c-p>
            }
          '';
          name = "InsertCompletionHide";
          option = ".*";
        }
        {
          commands = ''
            set-option window lintcmd "${pkgs.python37Packages.flake8}/bin/flake8 --filename='*' --format='%%(path)s:%%(row)d:%%(col)d: error: %%(text)s'"
            set window formatcmd '${pkgs.black}/bin/black --fast -q -'
            set-option window indentwidth 4
            lsp-enable-window
            hook window BufWritePre .* %{format}
            map global normal = ': repl-bridge python send<ret>R'
          '';
          name = "WinSetOption";
          option = "filetype=(python)";
        }
        {
          commands = ''
            set window formatcmd '${pkgs.nixfmt}/bin/nixfmt'
            set-option window indentwidth 4
            lsp-enable-window
            hook window BufWritePre .* %{format}
          '';
          name = "WinSetOption";
          option = "filetype=(nix)";
        }
      ];
      keyMappings = [
        {
          key = "F";
          mode = "user";
          docstring = "fzf mode";
          effect = ": fzf-mode<ret>";
        }
        {
          key = "f";
          mode = "user";
          docstring = "fzf files";
          effect = ": fzf-mode<ret>f";
        }
        {
          key = "b";
          mode = "user";
          docstring = "fzf buffers";
          effect = ": fzf-mode<ret>b";
        }
        {
          key = "/";
          mode = "user";
          docstring = "fzf search";
          effect = ": fzf-mode<ret>/";
        }
        {
          key = "l";
          mode = "user";
          docstring = "language tools";
          effect = ":<space>enter-user-mode<space>lsp<ret>";
        }
        {
          key = "=";
          mode = "global";
          docstring = "wrap paragraph";
          effect = "|fmt -w $kak_opt_autowrap_column<ret>";
        }
      ];
    };
    extraConfig = ''
      eval %sh{
        ${pkgs.kak-lsp}/bin/kak-lsp --kakoune \
            -s \$kak_session --config ${lsp_toml}
      }
      nop %sh{
          (${pkgs.kak-lsp}/bin/kak-lsp -s $kak_session -vvv ) > /tmp/lsp_"$(date +%F-%T-%N)"_kak-lsp_log 2>&1 < /dev/null &
      }

      # powerline
      source "${powerline}/rc/powerline.kak"
      source "${powerline}/rc/modules/bufname.kak"
      source "${powerline}/rc/modules/session.kak"
      source "${powerline}/rc/modules/git.kak"
      source "${powerline}/rc/modules/mode_info.kak"
      source "${powerline}/rc/modules/lsp.kak"
      source "${powerline}/rc/themes/default.kak"

      powerline-start
      hook global ModuleLoaded powerline %{
          set-option global powerline_format "bufname git session mode_info lsp"
      }

      # fzf
      source "${fzf}/rc/fzf.kak"
      source "${fzf}/rc/modules/fzf-file.kak"   # fzf file chooser
      source "${fzf}/rc/modules/fzf-buffer.kak" # switching buffers with fzf
      source "${fzf}/rc/modules/fzf-search.kak" # search within file contents
      source "${fzf}/rc/modules/fzf-vcs.kak"
      source "${fzf}/rc/modules/fzf-grep.kak"

      hook global ModuleLoaded fzf %{
        set-option global fzf_implementation 'sk'
        set-option global fzf_highlight_command 'bat'
        set-option global fzf_grep_command 'rg'
        set-option global fzf_file_command "rg --files --hidden"
      }

      source "${smarttab}/rc/smarttab.kak"
      hook global ModuleLoaded smarttab %{
        set-option global sofftabstop 4
        hook global WinSetOption  expandtab
        hook global WinSetOption filetype=(makefile|gas) noexpandtab
      }

      source "${repl-bridge}/repl-bridge.kak"

      hook global ModeChange insert:.* %{
          set-face global PrimaryCursor      rgb:ffffff,rgb:000000+F
      }

      hook global ModeChange .*:insert %{
          set-face global PrimaryCursor      rgb:ffffff,rgb:008800+F
      }
    '';
  };

  home.file.".config/kak/colors/nord.kak".source = "${nord}/nord.kak";
  programs.fish.functions.kak = ''
    if test -z "$TMUX_SESSION_NAME"
      command kak $argv
    else
      set --local socket_name (command kak -l | grep $TMUX_SESSION_NAME)
      if test -z "$socket_name"
        command kak -s $TMUX_SESSION_NAME $argv
      else
        command kak -c $TMUX_SESSION_NAME $argv
      end
    end
  '';
}
