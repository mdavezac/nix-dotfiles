group: project:
{ config, pkgs, lib, ... }:
let
  cfg =
    lib.foldl (a: b: builtins.getAttr b a) config.projects [ group project ];

  gitMod = lib.types.submodule {
    options = {
      url = lib.mkOption { type = lib.types.str; };
      dest = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };
      origin = lib.mkOption {
        type = lib.types.str;
        default = "origin";
      };
      ignore = lib.mkOption {
        type = lib.types.str;
        default = ''
          .vim/
          .local/
          .envrc
          shell.nix
        '';
      };
    };
  };

  ops = {
    enable = lib.mkEnableOption "${group} project: ${project}";
    repos = lib.mkOption {
      type = lib.types.attrsOf gitMod;
      default = {};
    };
    workspace = lib.mkOption {
      type = lib.types.submodule {
        options = {
          prefix = lib.mkOption {
            type = lib.types.str;
            default = "${group}";
          };
          subfolder = lib.mkOption {
            type = lib.types.str;
            default = "${project}";
          };
        };
      };

      default = {};
    };

    extraEnvrc = lib.mkOption {
      description = "Extra stuff to append to envrc";
      type = lib.types.nullOr lib.types.str;
      default = "";
    };

    nixshell = lib.mkOption {
      description = "content of shell.nix";
      type = lib.types.submodule {
        options = {
          text = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          shell = lib.mkOption {
            type = lib.types.str;
            default = "mkShell";
          };
        };
      };
      default = {};
    };

    vim = lib.mkOption {
      description = "content of .vim/init.vim";
      type = lib.types.str;
      default = "";
    };

    file = lib.mkOption {
      description = "Add files to project root";
      type = lib.types.attrs;
      default = {};
    };

    vim-spell = lib.mkOption {
      description = "content of vim spell file";
      type = lib.types.str;
      default = "";
    };

    ipython = lib.mkOption {
      description = "content of ipython startup";
      type = lib.types.str;
      default = "";
    };

    coc = lib.mkOption {
      description = "Content of coc settings";
      type = lib.types.attrs;
      default = {};
    };
  };

  nixshellFile = (import ./nixshell.nix).file;
  isNixshellEnabled = (import ./nixshell.nix).isEnabled;
  envrcFunc = import ./envrc.nix;
  formattedCoc = text:
    (
      pkgs.runCommand "file.json" { buildInputs = [ pkgs.jq ]; }
        "cat ${pkgs.writeText "file.json" text} | ${pkgs.jq}/bin/jq > $out"
    );
in
{
  options.projects = lib.setAttrByPath [ group project ] ops;
  config = let
    path = cfg.workspace.prefix + "/" + cfg.workspace.subfolder;
  in
    lib.mkIf cfg.enable (
      lib.mkMerge [
        (
          lib.mkIf (!builtins.isNull cfg.extraEnvrc) {
            home.file."${path}/.envrc".text = envrcFunc {
              project = [ group project ];
              config = cfg;
              lib = lib;
              pkgs = pkgs;
            };
          }
        )
        (
          lib.mkIf (isNixshellEnabled cfg.nixshell) {
            home.file."${path}/shell.nix".source = builtins.toString (
              nixshellFile {
                project = project;
                config = cfg.nixshell;
                lib = lib;
                pkgs = pkgs;
                path = path;
              }
            );
          }
        )
        (
          lib.mkIf (lib.stringLength cfg.vim > 0) {
            home.file."${path}/.vim/init.vim".text = cfg.vim
            + (
              if (lib.stringLength cfg.vim-spell > 0) then
                "set spellfile=~/${path}/.vim/vimspell-custom.utf-8.add,~/${path}/.vim/vimspell.utf-8.add"
              else
                ""
            );
          }
        )
        (
          lib.mkIf (lib.stringLength cfg.vim-spell > 0) {
            home.file."${path}/.vim/vimspell.utf-8.add".text = cfg.vim-spell;
          }
        )
        (
          lib.mkIf (lib.stringLength cfg.ipython > 0) {
            home.file = {
              "${path}/.local/ipython/profile_default/startup/startup.ipy".text =
                cfg.ipython;
            };
          }
        )
        (
          lib.mkIf ((builtins.length (lib.attrValues cfg.coc)) > 0) {
            home.file."${path}/.vim/coc-settings.json".source =
              builtins.toString (formattedCoc (builtins.toJSON cfg.coc));
          }
        )
        (
          lib.mkIf ((builtins.length (lib.attrValues cfg.file)) > 0) {
            home.file = (
              lib.mapAttrs'
                (name: value: lib.nameValuePair ("${path}/${name}") (value)) cfg.file
            );
          }
        )
      ]
    );
}
