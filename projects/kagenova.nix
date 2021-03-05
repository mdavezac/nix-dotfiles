{ config, lib, pkgs, ... }:
let
  mkProject = import ./lib/project.nix "kagenova";
  emails = import ./lib/emails.nix;
  pylance_dir = (import ../machine.nix).pylance_dir;
  aws = (import ../machine.nix).aws;
  pulumi = (import ../machine.nix).pulumi;
  toTOML = path: toml : pkgs.runCommand "init.toml" {
    buildInputs = [ pkgs.remarshal ];
    preferLocalBuild = true;
  } ''
    remarshal -if json -of toml \
      < ${pkgs.writeText "${path}" (builtins.toJSON toml)} \
      > $out
  '';
  original = import ../src/starship.nix { inherit config lib pkgs; };
  starsets = original.programs.starship.settings // {
      nix_shell.disabled = true;
      package.disabled = true;
      python = {
        disabled = false;
        format = ''via [$symbol$version]($style) '';
      };
      gcloud = {
        disabled = false;
        format = "[$symbol$active]($style) ";
      };
    };

in {
  imports = (builtins.map mkProject [
    "tensossht"
    "learn"
    "website"
    "copernic360"
    "packaging"
    "ai-pipeline"
    "alignment"
    "plugin"
  ]);

  home.file.".aws/credentials".text = lib.generators.toINI { } aws;

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
      unset PYTHONPATH
      layout poetry python3.7
      extra_pip_packages pdbpp ipython jupyter rstcheck
      check_precommit
    '';
    nixshell = {
      text = ''
        buildInputs = [
          python37
          poetry
        ];
      '';
    };
  };
  # }}}

  # copernic360: {{{
  projects.kagenova.copernic360 = let 
    starship = toTOML "starship.toml" starsets;
  in {
    enable = true;
    repos.copernic360 = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/kagemove-webapi.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        pipeline/
        .vim/
        .local/
        .envrc
        TODOs.org
      '';
    };
    repos.pipeline = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/data-pipeline.git";
      dest = "pipeline";
      settings.user.email = emails.gitlab;
    };
    extraEnvrc = ''
      eval "$(lorri direnv)"
      layout poetry 3.7
      check_precommit
      export STARSHIP_CONFIG=${starship}
    '';
  };
  home.file.".config/gcloud/configurations/config_copernic360-development".text = lib.generators.toINI {} { core = {
    account = "mayeul.davezac@kagenova.com";
    project = "spatial360-development";
  };};
  home.file.".config/gcloud/configurations/config_copernic360-staging".text = lib.generators.toINI {} { core = {
    account = "mayeul.davezac@kagenova.com";
    project = "spatial360-staging";
  };};
  home.file.".config/gcloud/configurations/config_copernic360-production".text = lib.generators.toINI {} { core = {
    account = "mayeul.davezac@kagenova.com";
    project = "spatial360-production";
  };};
  # }}}

  # ai-pipeline: {{{
  projects.kagenova.ai-pipeline = {
    enable = true;
    repos.pipeline = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/data-pipeline.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        app/
        .vim/
        .local/
        .envrc
        TODOs.org
      '';
    };
    repos.app = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/kagemove-webapi.git";
      dest = "app";
      settings.user.email = emails.gitlab;
      ignore = ''
        .vim/
        .local/
        .envrc
      '';
    };
    extraEnvrc = ''
      eval "$(lorri direnv)"
      layout poetry 3.7
      check_precommit
      export AWS_REGION=eu-west-2
      export PULUMI_HOME=$(pwd)/.local/pulumi;
      [ -e TODOs.org ] || ln -s ~/org/copernic360.org TODOs.org
    '';
    coc = {
      "pyls.enable" = false;
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

  # cdt: {{{
  projects.kagenova.alignment = {
    enable = true;
    repos.learn = {
      url = "https://gitlab.com/kagenova/kagelearn/development/alignment.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        .vim/
        .local/
        .envrc
        TODOs.org
      '';
    };
    extraEnvrc = ''
      eval "$(lorri direnv)"
      layout poetry 3.7
      check_precommit
      export PULUMI_CONFIG_PASSPHRASE="${pulumi.cdt}";
      export PULUMI_HOME=$(pwd)/.local/pulumi;
      [ -e TODOs.org ] || ln -s ~/org/cdt.org TODOs.org
    '';
    coc = {
      "pyls.enable" = false;
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

  # plugin: {{{
  projects.kagenova.plugin = {
    enable = true;
    repos.plugin = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/kagemove-plugin.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        .vim/
        .local/
        .envrc
      '';
    };
    extraEnvrc = ''
      check_precommit
    '';
  };
  # }}}
}
