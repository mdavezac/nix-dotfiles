{ config, lib, pkgs, ... }:
let
  mkProject = import ./lib/project.nix "kagenova";
  emails = import ./lib/emails.nix;
  pylance_dir = (import ../machine.nix).pylance_dir;
in {
  imports = builtins.map mkProject [
    "tensossht"
    "learn"
    "website"
    "move"
    "packaging"
  ];

  # tensossht: {{{
  projects.kagenova.tensossht = {
    enable = true;
    repos = let kagelearn_url = "gitlab.com/kagenova/kagelearn/development";
    in {
      tensossht = {
        url = "https://${kagelearn_url}/tensossht.git";
        dest = ".";
        settings = { user.email = emails.gitlab; };
        ignore = ''
          .vim/
          .local/
          .envrc
          .vscode/
          shell.nix
          vm/
          profiling/
          gpu/
          terraform/
        '';
      };
      terraform = {
        url = "https://${kagelearn_url}/tensossht/snippets/2012012.git";
        dest = "terraform";
        settings.user.email = emails.gitlab;
      };
    };
    nixshell = {
      text = ''
        buildInputs = [
          (python38.withPackages (p: [ p.poetry p.pip ]))
          graphviz
          google-cloud-sdk
          terraform_0_13
          terraform-providers.gitlab
          terraform-providers.google
          terraform-providers.google-beta
        ];
      '';
    };
    extraEnvrc = ''
      export TF_CPP_MIN_LOG_LEVEL=2
      layout poetry
      extra_pip_packages pdbpp ipython jupyter rstcheck
      check_precommit
      PATH_add .local/bin/
    '';
    ipython = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
      import tensorflow as tf
    '';
    vim = ''
      set textwidth=88
      set colorcolumn=89
      let g:investigate_dash_for_python =
          \ "Python3,Pandas,SciPy,NumPy,Matplotlib,pytest,tensorflow"
      let g:neomake_python_enabled_makers=['mypy']
      let g:neoformat_enabled_python = ["isort", "docformatter", "black"]
      let g:neoformat_python_docformatter.args = [
        \ '--wrap-descriptions', 88,
        \ '--wrap-summaries', 88,
        \ '-' ]
      let g:terraform_fold_sections=1
      let g:terraform_fmt_on_save=1
    '';
    coc = {
      "python.linting.enabled" = true;
      "python.linting.mypyEnabled" = false;
      "python.linting.flake8Enabled" = true;
      "python.linting.pylintEnabled" = false;
      "python.jediEnabled" = false;
      "python.formatting.provider" = "black";
      languageserver = {
        terraform = {
          command = "${pkgs.terraform-lsp}/bin/terraform-lsp";
          filetypes = [ "terraform" ];
          initializationOptions = { };
        };
      };
    };
  };
  # }}}

  # learn: {{{
  projects.kagenova.learn = {
    enable = true;
    repos.learn = {
      url = "https://gitlab.com/kagenova/kagelearn/development/kagelearn.git";
      dest = ".";
      settings.user.email = emails.gitlab;
    };
    extraEnvrc = ''
      layout poetry
      extra_pip_packages pdbpp ipython jupyter rstcheck
      check_precommit
    '';
    nixshell = {
      text = ''
        buildInputs = [
          (python38.withPackages (p: [ p.poetry p.pip ]))
        ];
      '';
    };
  };
  # }}}

  # move: {{{
  projects.kagenova.move = {
    enable = true;
    repos.learn = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/kagemove-webapi.git";
      dest = ".";
      settings.user.email = emails.gitlab;
    };
    extraEnvrc = ''
      layout poetry
      extra_pip_packages pdbpp ipython jupyter
      check_precommit
    '';
    nixshell.text = ''
      buildInputs = [
        (python38.withPackages (p: [ p.poetry p.pip ]))
        google-cloud-sdk
      ];
    '';
    coc = {
      "python.linting.enabled" = true;
      "python.linting.mypyEnabled" = false;
      "python.linting.flake8Enabled" = true;
      "python.linting.pylintEnabled" = false;
      "python.jediEnabled" = false;
      "python.formatting.provider" = "black";
      "codeLens.enable" = true;
      "diagnostic.enable" = true;
      "diagnostic.virtualText" = true;
    };
  };
  # }}}

  # website: {{{
  projects.kagenova.website = {
    enable = true;
    repos.web = {
      url = "https://gitlab.com/kagenova/marketing/website.git";
      dest = ".";
      settings.user.email = emails.gitlab;
    };
    extraEnvrc = ''
      layout python3
      packages=$(python -m pip freeze)
      for package in ipython; do
          [[ "$packages" == *"$package"* ]] \
            || python -m pip install $package
      done
    '';
    nixshell = {
      text = ''
        buildInputs = [
          (ruby.withPackages (p: with p; [bundler jekyll]))
          python38
          google-cloud-sdk
        ];
      '';
    };
    vim = ''
      set textwidth=88
      set colorcolumn=89
      let g:neomake_python_enabled_makers = ["flake8"]
      let g:neoformat_enabled_python = ["isort", "docformatter", "black"]
      let g:neoformat_python_docformatter.args = [
        \ '--wrap-descriptions', 88,
        \ '--wrap-summaries', 88,
        \ '-' ]
    '';
  };
  # }}}

  # packaging: {{{
  projects.kagenova.packaging = {
    enable = true;
    repos = {
      ssht = {
        url = "https://github.com/astro-informatics/ssht.git";
        dest = "ssht";
        settings = {
          user.email = emails.github;
          "remote \"archive\"" = {
            url = "https://github.com/astro-informatics/ssht-archive.git";
            fetch = "+refs/heads/*:refs/remotes/public/*";
          };
          "remote \"kagenova\"" = {
            url = "https://gitlab.com/kagenova/kagelearn/development/ssht.git";
            fetch = "+refs/heads/*:refs/remotes/kagenova/*";
          };
        };
      };

      so3 = {
        url = "https://github.com/astro-informatics/so3.git";
        dest = "so3";
        settings = {
          user.email = emails.github;
          "remote \"archive\"" = {
            url = "https://github.com/astro-informatics/so3-archive.git";
            fetch = "+refs/heads/*:refs/remotes/public/*";
          };
        };
      };

      s2let = {
        url = "https://github.com/astro-informatics/s2let.git";
        dest = "s2let";
        settings = {
          user.email = emails.github;
          "remote \"archive\"" = {
            url = "https://github.com/astro-informatics/s2let-archiv.git";
            fetch = "+refs/heads/*:refs/remotes/public/*";
          };
        };
      };
    };

    nixshell = {
      text = ''
        buildInputs = [
          python37
          graphviz
          doxygen
          google-cloud-sdk
          ninja
          cmake
          fftw
          curl
        ];
      '';
    };
    extraEnvrc = ''
      layout python-venv
      extra_pip_packages conan scikit-build cmakelang twine
    '';
    ipython = ''
      %load_ext autoreload
      %autoreload 2
    '';
    vim = ''
      set textwidth=88
      set colorcolumn=89
      let g:investigate_dash_for_python =
          \ "Python3,Pandas,SciPy,NumPy,Matplotlib,pytest"
      let g:neomake_python_enabled_makers=['mypy']
      let g:neoformat_enabled_python = ["isort", "docformatter", "black"]
    '';
    coc = {
      "python.linting.enabled" = true;
      "python.linting.mypyEnabled" = false;
      "python.linting.flake8Enabled" = true;
      "python.linting.pylintEnabled" = false;
      "python.jediEnabled" = false;
      "python.formatting.provider" = "black";
      languageserver = {
        pylance = {
          enable = true;
          filetypes = [ "python" ];
          module = pylance_dir;
          initializationOptions = { };
          settings = {
            "python.analysis.typeCheckingMode" = "basic";
            "python.analysis.diagnosticMode" = "openFilesOnly";
            "python.analysis.autoSearchPaths" = true;
            "python.analysis.extraPaths" = [ ];
            "python.analysis.diagnosticSeverityOverrides" = { };
            "python.analysis.useLibraryCodeForTypes" = true;
          };
        };
      };
      "clangd.path" = "/usr/local/Cellar/llvm/10.0.1_1/bin/clangd";
    };
  };
  # }}}
}
