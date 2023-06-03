{ inputs, pkgs, config, ... }: {
  imports = [
    inputs.spacenix.modules.${pkgs.system}.prepackaged
  ];
  packages = [
    pkgs.git
    pkgs.awscli2
    pkgs.aws-vault
    pkgs.pass
    pkgs.poetry
    pkgs.pre-commit
    pkgs.google-cloud-sdk
    pkgs.pandoc
    pkgs.texlive.combined.scheme-full
  ];

  languages.nix.enable = true;
  languages.python.enable = true;

  spacenix = {
    layers.git.github = true;
    layers.debugger.enable = true;
    layers.neorg.enable = false;
    languages.markdown = true;
    languages.nix = true;
    languages.python = true;
    dash.python = [ "pandas" "numpy" ];
    treesitter-languages = [ "json" "toml" "yaml" "bash" "fish" ];
    colorscheme = "oh-lucy";
    cursorline = true;
    post.vim = ''
      autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
    '';
    telescope-theme = "ivy";
    formatters.isort.exe = "isort";
    formatters.black.exe = "black";
    formatters.nixpkgs-fmt.enable = false;
    formatters.alejandra.enable = true;
    layers.terminal.repl.repl-open-cmd = ''
      require('iron.view').split.vertical.botright(
          "40%", { number = false, relativenumber = false }
      )
    '';
    init.vim = ''
      function PythonModuleName()
          let relpath = fnamemodify(expand("%"), ":.:s")
          return substitute(substitute(relpath, ".py", "", ""), "\/", ".", "g")
      endfunction

      au BufRead,BufNewFile *.jsonl  set filetype=json
    '';
    which-key.bindings = [
      {
        key = "<leader>gd";
        command = "<CMD>DiffviewOpen origin/develop...HEAD<CR>";
        description = "Diff current branch";
      }
      {
        key = "<leader>fm";
        command = "<CMD>let @\\\" = PythonModuleName()<CR>";
        description = "Filename as python module";
      }
    ];

    layers.terminal.repl.repls.python = "require('iron.fts.python').ipython";
  };
}
