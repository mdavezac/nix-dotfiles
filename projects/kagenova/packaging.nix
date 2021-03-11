{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
in
{
  imports = builtins.map mkProject [ "packaging" ];

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

      conan-center-index = {
        url = "https://github.com/mdavezac/conan-center-index.git";
        dest = "conan-center-index";
        settings.user.email = emails.github;
      };
    };

    file."packaging.code-workspace".text = builtins.toJSON {
      folders = [
        { path = "ssht"; }
        { path = "so3"; }
        { path = "s2let"; }
        { path = "conan-center-index"; }
      ];
      settings = {
        "python.venvFolders" = [ "/Users/mdavezac/kagenova/packaging/.direnv/" ];
        "python.formatting.provider" = "black";
        "cmake.generator " = "${pkgs.ninja}/bin/ninja";
      };
    };

    nixshell = {
      text = ''
        buildInputs = [
          gobjectIntrospection
          gtk3
          (python37.withPackages(ps : with ps; [ matplotlib pygobject3 ipython pip scikit-build cython numpy]))
          black
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
      export PIP_PREFIX=$(pwd)/.local/pip_packages
      export PYTHONPATH="$PIP_PREFIX/lib/python3.7/site-packages:$PYTHONPATH:$PWD/ssht/src/"
      export PATH="$PIP_PREFIX/bin:$PATH"
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
  };
}
