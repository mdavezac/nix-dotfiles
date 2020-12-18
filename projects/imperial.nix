{ config, lib, pkgs, ... }:
let
  mkProject = import ./lib/project.nix "imperial";
  emails = import ./lib/emails.nix;
  pylance_dir = (import ../machine.nix).pylance_dir;
in {
  imports =
    builtins.map mkProject [ "muse" "strainmap" "joss" "evosim" "grad_course" ];

  # muse: {{{
  projects.imperial.muse = {
    enable = true;
    repos.muse = {
      url = "https://github.com/SGIModel/StarMuse";
      dest = ".";
      origin = "sgi";
      settings = {
        user.email = emails.github;
        "remote \"imperial\"" = {
          url = "https://github.com/ImperialCollegeLondon/StarMuse";
          fetch = "+refs/heads/*:refs/remotes/imperial/*";
        };
        "remote \"public\"" = {
          url = "https://github.com/SGIModel/SGIModelPublic";
          fetch = "+refs/heads/*:refs/remotes/public/*";
        };
      };
    };
    ipython = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
      import xarray as xr
      import pandas as pd
      from muse import examples
    '';
    vim = ''
      set textwidth=88
      set colorcolumn=89
      let g:neomake_python_enabled_makers = []
      let g:neoformat_enabled_python = ["isort", "docformatter", "black"]
      let g:neoformat_python_docformatter.args = [
        \ '--wrap-descriptions', 88,
        \ '--wrap-summaries', 88,
        \ '-' ]
      let g:github_upstream_issues = 1
    '';
    vim-spell = ''
      timeslices
      :py:meth:
      :py:func:
      func
      py
    '';
    extraEnvrc = ''
      layout python3
      check_precommit
      packages=$(python -m pip freeze)
      for package in pdbpp ipython jupyter rstcheck; do
          [[ "$packages" == *"$package"* ]] \
            || python -m pip install $package
      done
      python -m pip show StarMuse > /dev/null \
        || python -m pip install -e ".[dev,docs,private_sgi_model,excel]"
    '';
    nixshell.text = ''
      buildInputs = [ python37 pandoc ];
    '';
    coc = {
      "python.linting.enabled" = true;
      "python.linting.mypyEnabled" = true;
      "python.linting.flake8Enabled" = true;
      "python.linting.pylintEnabled" = false;
      "python.jediEnabled" = false;
      "python.venvPath" = "$" + "{workspaceFolder}/.direnv";
      "python.formatting.provider" = "black";
    };
  };
  # }}}

  # strainmap: {{{
  projects.imperial.strainmap = {
    enable = true;
    repos.muse = {
      url = "https://github.com/ImperialCollegeLondon/strainmap";
      dest = ".";
      settings.user.email = emails.github;
    };
    ipython = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
    '';
    vim = ''
      set textwidth=88
      set colorcolumn=89
      let g:neomake_python_enabled_makers = ["flake8", "mypy"]
      let g:neoformat_enabled_python = ["isort", "docformatter", "black"]
      let g:neoformat_python_docformatter.args = [
        \ '--wrap-descriptions', 88,
        \ '--wrap-summaries', 88,
        \ '-' ]
      let g:github_upstream_issues = 1
    '';
    extraEnvrc = ''
      layout python3
      check_precommit
      packages=$(python -m pip freeze)
      for package in pdbpp ipython; do
          [[ "$packages" == *"$package"* ]] \
            || python -m pip install $package
      done
      python -m pip show strainmap > /dev/null \
        || python -m pip install -e .
    '';
    nixshell.text = ''
      buildInputs = [ python38Packages.tkinter python38 ];
    '';

    coc = {
      "python.linting.enabled" = true;
      "python.linting.mypyEnabled" = true;
      "python.linting.flake8Enabled" = true;
      "python.linting.pylintEnabled" = false;
      "python.jediEnabled" = false;
      "python.venvPath" = "$" + "{workspaceFolder}/.direnv";
      "python.formatting.provider" = "black";
    };
  };
  # }}}

  # joss: {{{
  projects.imperial.joss = {
    enable = true;
    repos.muse = {
      url = "https://github.com/MikeHeiber/Excimontec";
      dest = "Excimontec";
      settings.user.email = emails.github;
    };
    nixshell.text = ''
      buildInputs = [
        gccStdenv
        (openmpi.overrideAttrs(oldAttrs: rec {
          preferLocalBuild=true;
          stdenv=gccStdenv;
        }))
        gnumake
        (python38.withPackages (p: with p; [pygments]))
      ];
    '';
  };
  # }}}

  # evosim: {{{
  projects.imperial.evosim = {
    enable = true;
    repos.evosim = {
      url = "https://github.com/ImperialCollegeLondon/EvoSim";
      dest = ".";
      settings.user.email = emails.github;
      ignore = ''
        archive/
        .vim/
        .local/
        .envrc
        shell.nix
        .vscode/
        hydra/
      '';
    };
    ipython = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
      import pandas as pd
      import evosim

      pd.options.display.precision = 2
      pd.options.display.max_categories = 8
      pd.options.display.max_rows = 0
      pd.options.display.max_columns = 0
      pd.options.mode.chained_assignment = "raise"
      np.set_printoptions(linewidth=88)
    '';
    vim = ''
      set textwidth=88
      set colorcolumn=89
      let g:neomake_python_enabled_makers = ["mypy"]
      let g:neoformat_enabled_python = ["isort", "docformatter", "black"]
      let g:neoformat_python_docformatter.args = [
        \ '--wrap-descriptions', 88,
        \ '--wrap-summaries', 88,
        \ '-' ]
      let g:jupytext_fmt = 'script'
    '';
    extraEnvrc = ''
      layout poetry
      extra_pip_packages pdbpp rstcheck pytest-randomly
      check_precommit
    '';
    vim-spell = ''
      EvoSim
      github
      mod
      YAML
      :py:meth:
      :py:func:
      :py:class:
      :py:mod:
    '';
    nixshell.text = ''
      buildInputs = [ 
          (python38.withPackages (p: [ p.poetry p.pip ]))
          pandoc
      ];
    '';
    coc = {
      "python.linting.enabled" = true;
      "python.linting.mypyEnabled" = true;
      "python.linting.flake8Enabled" = true;
      "python.linting.pylintEnabled" = false;
      "python.jediEnabled" = false;
      "python.venvPath" = "$" + "{workspaceFolder}/.direnv";
      "python.formatting.provider" = "black";
    };
  };
  # }}}

  # grad_course: {{{
  projects.imperial.grad_course = {
    enable = true;
    repos.evosim = {
      url =
        "https://github.com/ImperialCollegeLondon/grad_school_software_engineering_course";
      dest = ".";
      settings.user.email = emails.github;
      ignore = ''
        .vim/
        .local/
        .envrc
        shell.nix
      '';
    };
    vim = ''
      set textwidth=88
      set colorcolumn=89
      let g:neomake_python_enabled_makers = []
      let g:neoformat_enabled_python = ["isort", "docformatter", "black"]
      let g:neoformat_python_docformatter.args = [
        \ '--wrap-descriptions', 88,
        \ '--wrap-summaries', 88,
        \ '-' ]
    '';
    extraEnvrc = ''
      PATH_add $(pwd)/.local/bin/
      check_precommit
    '';
    nixshell.text = ''
      buildInputs = [jekyll];
    '';
    coc = {
      "python.linting.enabled" = true;
      "python.linting.mypyEnabled" = true;
      "python.linting.flake8Enabled" = true;
      "python.linting.pylintEnabled" = false;
      "python.jediEnabled" = false;
      "python.venvPath" = "$" + "{workspaceFolder}/.direnv";
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
    };
  };

  home.file."imperial/grad_course/.local/bin/code" = {
    executable = true;
    text = ''
      #!/bin/bash

      function script_dir {
          echo "$(cd "$(dirname "''${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
      }

      ${pkgs.vscode}/bin/code \
          --user-data-dir $(script_dir)/../vscode/data  \
          --extensions-dir $(script_dir)/../vscode/extensions \
          "$@"
    '';
  };
  # }}}
}
