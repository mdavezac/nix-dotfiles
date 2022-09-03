rec {
  description = "360Learning environment";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    spacenix.url = "/Users/mdavezac/personal/spacenix";
    mach-nix.url = "github:DavHau/mach-nix";
    detectron2 = {
      url = "https://github.com/facebookresearch/detectron2.git";
      flake = false;
    };
  };

  outputs = { self, flake-utils, devshell, nixpkgs, spacenix, mach-nix, detectron2 }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
        configuration.nvim = {
          layers.git.github = true;
          layers.debugger.enable = true;
          layers.neorg.enable = false;
          languages.markdown = true;
          languages.nix = true;
          languages.python = true;
          treesitter-languages = [ "json" "toml" "yaml" "bash" "fish" ];
          colorscheme = "papercolor";
          post.vim = ''
            autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
          '';
          formatters.isort.enable = pkgs.lib.mkForce false;
          formatters.black.enable = pkgs.lib.mkForce false;
          init.vim = ''
            function PythonModuleName()
                let relpath = fnamemodify(expand("%"), ":.:s?app/??")
                return substitute(substitute(relpath, ".py", "", ""), "\/", ".", "g")
            endfunction
          '';
          which-key.bindings = [
            {
              key = "<leader>gd";
              command = "<CMD>DiffviewOpen origin/master...HEAD<CR>";
              description = "Diff current branch";
            }
            {
              key = "<leader>fm";
              command = "<CMD>let @\\\" = PythonModuleName()<CR>";
              description = "Filename as python module";
            }
          ];

          layers.terminal.repl.favored.python = pkgs.lib.mkForce "require('iron.fts.python').ipython";
        };
        env = mach-nix.lib."${system}".mkPython {
          requirements = ''
            matplotlib
            Pillow
            google-cloud-vision==0.34.0
            pytesseract
            scikit-image
            numpy<1.23.0
            pandas==1.3.0
            flask==1.0.2
            boto3
            botocore
            scipy==1.7.3
            pytest
            pytest-html
            sentry-sdk[flask]==0.13.2
            ipython[all]
            pdbpp
            seaborn
            fastapi==0.66.0
            mongoengine
            python-Levenshtein
            pandarallel==1.5.2
            pythainlp[thai2rom]
            python-crfsuite
            uvicorn
            fastapi
            textdistance
            sqlalchemy
            pymysql
            tqdm
            layoutparser[paddledetection]
            torchvision
            pip
            torch>=1.8
            paddlepaddle
          '';
          python = "python38";
          _.pyppeteer.postInstall = ''
            rm $out/lib/python*/site-packages/LICENSE
            rm $out/lib/python*/site-packages/README.md
          '';
        };
      in
      {
        devShells.default =
          let
            nvim_pkg = spacenix.lib."${system}".spacenix-wrapper configuration;
            nvim_mod = spacenix.modules."${system}".devshell nvim_pkg;
          in
          pkgs.devshell.mkShell {
            imports = [ nvim_mod ];
            commands = [
              { package = pkgs.awscli2; }
              { package = pkgs.aws-vault; }
              { package = pkgs.pass; }
            ];
            devshell.packages = [ env ];
            env = [{ "name" = "VIRTUAL_ENV"; value = "${env}"; }];
          };
      });
}
