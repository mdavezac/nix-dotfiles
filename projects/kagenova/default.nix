{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
  pulumi = (import ../../machine.nix).pulumi;
  toTOML = path: toml: pkgs.runCommand "init.toml"
    {
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

in
{
  imports = (
    builtins.map mkProject [
      "tensossht"
      "learn"
      "website"
      "alignment"
    ] ++ [ ./packaging.nix ./copernic360.nix ./move.nix ]
  );

  # tensossht: {{{
  projects.kagenova.tensossht = {
    enable = true;
    repos =
      let
        kagelearn_url = "gitlab.com/kagenova/kagelearn/development";
      in
        {
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
    extraEnvrc = ''
      eval "$(lorri direnv)"
      export TF_CPP_MIN_LOG_LEVEL=2
      export POETRY_VIRTUALENVS_PATH=$(pwd)/.local/venvs
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
          initializationOptions = {};
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
      export POETRY_VIRTUALENVS_PATH=$(pwd)/.local/venvs
      eval "$(lorri direnv)"
      layout poetry python3.6
      extra_pip_packages pdbpp ipython jupyter rstcheck
      check_precommit
    '';
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
}
