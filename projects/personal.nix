{ config
, lib
, pkgs
, ...
}:
let
  mkProject = import ./lib/project.nix "personal";
  emails = import ./lib/emails.nix;
in
{
  imports = builtins.map mkProject [
    "pylada"
    "julia"
    "advent_of_code"
    "cv"
    "oni"
    "spacenix"
    "nixpkgs"
  ];
  # pylada: {{{
  projects.personal.pylada = {
    enable = true;
    repos.pylada = {
      url = "https://github.com/pylada/pylada-light";
      dest = ".";
      settings.user.email = emails.github;
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
      let g:github_upstream_issues = 1
    '';
    extraEnvrc = ''
      layout python3;
      packages=$(python -m pip freeze)
      for package in pdbpp ipython jupyter rstcheck setuptools wheel scikit-build cython numpy flake8 black mypy;
      do
          [[ "$packages" == *"$package"* ]] \
            || python -m pip install $package
      done
      export PYLADA_CONFIG_DIR="$PWD/.local/pylada"
      [ -e $PYLADA_CONFIG_DIR ] || mkdir -p $PYLADA_CONFIG_DIR
      [ -e $PYLADA_CONFIG_DIR/mpy.py ] \
        || echo "mpirun_exe = \"mpirun --oversubscribe -np {n} {program}\"" > $PYLADA_CONFIG_DIR/mpi.py
    '';
    nixshell.text = ''
      buildInputs = [
        python38
        pre-commit
        quantum-espresso
        quantum-espresso-mpi
        openmpi
        gfortran
        cmake
        ninja
      ];
    '';
  };
  # }}}

  # julia: {{{
  projects.personal.julia = {
    enable = false;
    repos.pylada = {
      url = "https://github.com/mdavezac/julia";
      dest = ".";
      settings = {
        user.email = emails.github;
        "remote \"julia\"" = {
          url = "https://github.com/JuliaLang/julia";
          fetch = "+refs/heads/*:refs/remotes/julia/*";
        };
      };
    };
    extraEnvrc = ''
      export CC=$(which gcc)
      export CXX=$(which g++)
      export FC=$(which gfortran)
    '';
    vim = ''
      set textwidth=88
      set colorcolumn=89
    '';
    nixshell.text = ''
      buildInputs = [
        gfortran
      ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
        Cocoa CoreServices
      ]);
    '';
  };
  # }}}

  # advent of code: {{{
  projects.personal.advent_of_code = {
    enable = false;
    repos.advent_of_code = {
      url = "https://github.com/mdavezac/advent_of_code.git";
      dest = ".";
      settings = {
        user.email = emails.github;
        "remote \"gitlab\"" = {
          url = "https://gitlab.com/kagenova/internal/tools-practice/advent-of-code-2020.git";
          fetch = "+refs/heads/*:refs/remotes/gitlab/*";
        };
      };
    };
    vim = ''
      set textwidth=88
      set colorcolumn=89
    '';
    nixshell.text = ''
      buildInputs = let
        moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
        nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
        #rustNightlyChannel = (nixpkgs.rustChannelOf { date = "2019-01-26"; channel = "nightly"; }).rust;
        rustStableChannel = nixpkgs.latest.rustChannels.stable.rust.override {
          extensions = [
            "rust-src"
            "rls-preview"
            "clippy-preview"
            "rustfmt-preview"
          ];
        };
      in with nixpkgs; [ rustStableChannel rls rustup cargo racket ];
    '';
    coc = {
      "rust.cfg_test" = true;
      "rust.clippy_preference" = "on";
      "rust.show_hover_context" = true;
      "rust-client.disableRustup" = true;
    };
  };
  # }}}

  # cv: {{{
  projects.personal.cv = {
    enable = false;
    repos.cv = {
      url = "https://gitlab.com/mdavezac/cv.git";
      dest = ".";
      settings.user.email = emails.gitlab;
    };
    nixshell.text = ''
      buildInputs = [ tectonic biber ];
    '';
  };
  # }}}
  # oni: {{{
  projects.personal.oni = {
    enable = false;
    repos.cv = {
      url = "https://github.com/onivim/oni2";
      dest = ".";
      settings.user.email = emails.github;
    };
    nixshell.text = ''
      buildInputs = [
         libtool gettext libpng cmake ragel
         # nodejs-16_x nodePackages.esy nodePackages.node-gyp
      ];
    '';
  };
  # }}}
  # spacenix: {{{
  projects.personal.spacenix = {
    enable = true;
    extraEnvrc = null;
    file.".setup.fish".text = ''
      gh repo clone spacevim.nix
      mv spacevim.nix/* spacevim.nix/.* .
      rmdir spacevim.nix
      git config --local user.name "Mayeul d'Avezac"
      git config --local user.email "${emails.github}"
      echo ".setup.fish" >.git/info/exclude
      echo ".envrc.extra" >>.git/info/exclude
    '';
    file.".envrc.extra".text = ''
      export fish_history="personalneovim"
      export TMUX_SESSION_NAME=personal-nvim
    '';
  };
  # }}}
  projects.personal.nixpkgs = {
    enable = false;
    extraEnvrc = ''
      source_env_if_exists $PWD/.local/nvim/envrc
      source_env_if_exists $PWD/.envrc.flake
    '';
    file.".setup.fish".text = ''
      if test ! -e ".git"
          gh repo clone nixpkgs
          mv nixpkgs/* nixpkgs/.* .
          rmdir nixpkgs
          git remote add nixpkgs https://github.com/NixOS/nixpkgs
      end
      git config --local user.name "Mayeul d'Avezac"
      git config --local user.email "${emails.github}"
      echo ".setup.fish" >.git/info/exclude
      echo ".local" >>.git/info/exclude
      echo ".envrc" >> .git/info/exclude
      echo ".envrc.extra" >>.git/info/exclude
    '';
  };
}
