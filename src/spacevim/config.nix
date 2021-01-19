pkgs:
let
  pyls = pkgs.buildEnv {
    name = "pyls";
    paths = [ pkgs.python37Packages.python-language-server ];
    pathsToLink = [ "/bin" ];
  };
in {
  custom_plugins = [
    { name = "dhruvasagar/vim-zoom"; }
    { name = "direnv/direnv.vim"; }
    { name = "jpalardy/vim-slime"; }
    { name = "goerz/jupytext.vim"; }
    { name = "mbbill/undotree"; }
    {
      name = "tmhedberg/SimpylFold";
      filetype = [ "python" ];
    }
    { name = "puremourning/vimspector"; }
    { name = "hashivim/vim-terraform"; }
  ];
  layers = [
    { name = "tmux"; }
    { name = "colorscheme"; }
    { name = "cscope"; }
    { name = "tools#dash"; }
    { name = "ctrlspace"; }
    { name = "test"; }
    {
      name = "shell";
      default_position = "right";
      default_width = 50;
    }
    { name = "lang#toml"; }
    { name = "lang#markdown"; }
    { name = "lang#python"; }
    { name = "lang#nix"; }
    { name = "lang#sh"; }
    { name = "lang#docker"; }
    { name = "lang#julia"; }
    { name = "lang#rust"; }
    { name = "autocomplete"; }
    {
      name = "lsp";
      filetypes = [ "python" ];
      python_file_head = [ ];
      override_cmd.python = [ "${pyls}/bin/pyls" ];
      enable_typeinfo = true;
    }
    {
      name = "git";
      git-plugin = "fugitive";
    }
    { name = "leaderf"; }
  ];
  options = {
    autocomplete_method = "coc";
    buffer_index_type = 4;
    colorscheme = "gruvbox";
    colorscheme_bg = "dark";
    default_indent = 4;
    enable_cursor_column = 0;
    enable_tabline_filetype_icon = true;
    enable_guicolors = true;
    max_column = 100;
    plugin_bundle_dir = "$HOME/.local/share/spacevim/repos";
    statusline_display_mode = true;
    statusline_inactive_separator = "arrow";
    statusline_separator = "curve";
    bootstrap_after = "localcustomconfig#after";
    bootstrap_before = "localcustomconfig#before";
  };
}
