{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
  utils = (pkgs.callPackage (import ../lib/utils.nix) {});
in
{
  imports = builtins.map mkProject [ "packaging" "pyssht" ];

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

    file."packaging.code-workspace".source = utils.toPrettyJSON {
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
        "cmakeFormat.exePath" = "${pkgs.cmake-format}/bin/cmake-format";
        "cmake.cmakePath" = "${pkgs.cmake}/bin/cmake";
        "cmake.ctestPath" = "${pkgs.cmake}/bin/ctest";
        "workbench.colorTheme" = "Community Material Theme Darker High Contrast";
      };
    };

    nixshell = {
      text = ''
        buildInputs = let
          buildtools = pkgs.buildEnv {
              name = "Build Tools";
              paths = with niv; [
                cmake ninja curl black doxygen
              ];
              pathsToLink = [ "/share" "/bin" ];
            };
        in [
          python3
          ninja
          fftw
          buildtools
        ];
      '';
    };
    extraEnvrc = ''
      layout python3
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

  projects.kagenova.pyssht = {
    enable = true;
    repos = {
      ssht = {
        url = "https://github.com/astro-informatics/ssht.git";
        dest = ".";
        ignore = ''
          pyssht.code-workspace
          pyrightconfig.json
          .vscode/
          shell.nix
          .envrc
          .local/
        '';
      };
    };

    file."pyssht.code-workspace".source = utils.toPrettyJSON {
      folders = [ { path = "."; } ];
      settings = {
        "python.venvFolders" = [ ''''${workspaceFolder}/.direnv/'' ];
        "python.formatting.provider" = "black";
        "cmake.generator " = "${pkgs.ninja}/bin/ninja";
        "cmakeFormat.exePath" = "${pkgs.cmake-format}/bin/cmake-format";
        "cmake.cmakePath" = "${pkgs.cmake}/bin/cmake";
        "cmake.ctestPath" = "${pkgs.cmake}/bin/ctest";
        "workbench.colorTheme" = "Community Material Theme Darker High Contrast";
      };
    };
    file."pyrightconfig.json".source = utils.toPrettyJSON {
      venvPath = ".direnv/";
    };

    nixshell = {
      text = ''
        buildInputs = let
          buildtools = pkgs.buildEnv {
              name = "Build Tools";
              paths = with niv; [
                cmake ninja curl black doxygen
              ];
              pathsToLink = [ "/share" "/bin" ];
            };
        in [
          python3
          ninja
          fftw
          buildtools
        ];
      '';
    };
    extraEnvrc = ''
      layout python3
    '';
    ipython = ''
      %load_ext autoreload
      %autoreload 2
    '';
  };
}
