{ config, pkgs, lib, ... }:
let
  lsp_toml = pkgs.substituteAll {
    src = ./lsp.toml;
    pyls = "${pkgs.python38Packages.python-language-server}/bin/pyls";
  };
  fzf = pkgs.fetchFromGitHub {
    owner = "andreyorst";
    repo = "fzf.kak";
    rev = "master";
    sha256 = "1d3d5v3hlrbxan5qgq6hj7hr3v7fdqlrvccgf7d72x2009v17x2a";
  };
  smarttab = pkgs.fetchFromGitHub {
    owner = "andreyorst";
    repo = "smarttab.kak";
    rev = "master";
    sha256 = "048qq8aj405q3zm28jjh6ardxb8ixkq6gs1h3bwdv2qc4zi2nj4g";
  };
  repl-bridge = pkgs.fetchFromGitHub {
    owner = "JJK96";
    repo = "kakoune-repl-bridge";
    rev = "master";
    sha256 = "16w6qi0zmyb4wx95yx5m9id8kpf84bcvnw0y9k156d42wf4kqjp8";
  };
in {
  programs.kakoune = {
    enable = true;
    config = {
      showMatching = true;
      indentWidth = 2;
      tabStop = 2;
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
        statusLine = "top";
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
            set window formatcmd '${pkgs.python38Packages.black}/bin/black --fast -q -'
            set-option window indentwidth 4
            lsp-enable-window
            hook window BufWritePre .* lsp-formatting-sync
            map global normal = ': repl-bridge python send<ret>R'
          '';
          name = "WinSetOption";
          option = "filetype=(python)";
        }
      ];
    };
    extraConfig = ''
      eval %sh{
        ${pkgs.kak-lsp}/bin/kak-lsp --kakoune \
            -s \$kak_session --config ${lsp_toml}
      }

      # fzf
      map -docstring 'fzf mode' global normal '<c-p>' ': fzf-mode<ret>'
      source "${fzf}/rc/fzf.kak"
      source "${fzf}/rc/modules/fzf-file.kak"   # fzf file chooser
      source "${fzf}/rc/modules/fzf-buffer.kak" # switching buffers with fzf
      source "${fzf}/rc/modules/fzf-search.kak" # search within file contents
      source "${fzf}/rc/modules/fzf-vcs.kak"
      source "${fzf}/rc/modules/VCS/fzf-git.kak"

      hook global ModuleLoaded fzf %{
        set-option global fzf_implementation 'fzf'
        set-option global fzf_highlight_command 'bat'
        set-option global fzf_file_command "${pkgs.ripgrep}/bin/rg --files --hidden"
      }

      source "${smarttab}/rc/smarttab.kak"
      hook global ModuleLoaded smarttab %{
        set-option global sofftabstop 4
        hook global WinSetOption  expandtab
        hook global WinSetOption filetype=(makefile|gas) noexpandtab
      }

      source "${repl-bridge}/repl-bridge.kak"
    '';
  };
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
