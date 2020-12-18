{ config, pkgs, lib, ... }:
let
  mypkgs = import ../packages { inherit pkgs; };
  config = import ./config.nix pkgs;
  github_token = (import  ../machine.nix).github_token;
  toml = pkgs.runCommand "init.toml" {
    buildInputs = [ pkgs.remarshal ];
    preferLocalBuild = true;
  } ''
    remarshal -if json -of toml \
      < ${pkgs.writeText "spacevim.json" (builtins.toJSON config)} \
      > $out
  '';
  spell = ''
    MCA
    broadcasted
    TOML
  '';
  spell_binary = pkgs.runCommand "en.utf-8.add.spl" {
    buildInputs = [ pkgs.neovim-unwrapped ];
    preferLocalBuild = true;
  } ''
    cat > en.utf-8.add <<EOF
    ${spell}
    EOF
    ${pkgs.neovim-unwrapped}/bin/nvim -es -n -i shada NONE --headless \
        --cmd "mkspell en.utf-8.add" --cmd qall
    cp en.utf-8.add.spl $out
  '';
in {
  home.packages = [
    pkgs.universal-ctags
    pkgs.nodejs
    pkgs.yarn
    pkgs.cscope
    pkgs.neovim-remote
    pkgs.fzf
  ];

  home.file.".Spacevim.d/init.toml".source = "${toml}";
  home.file.".Spacevim.d/spell/en.utf-8.add".text = "${spell}";
  home.file.".Spacevim.d/spell/en.utf-8.add.spl".source = "${spell_binary}";
  home.file.".Spacevim.d/autoload/localcustomconfig.vim".text =
    (builtins.readFile (pkgs.substituteAll {
      src = ./localconfig.vim;
      docformatter = "${mypkgs.docformatter}/bin/docformatter";
      black = "${pkgs.python38Packages.black}/bin/black";
      nixfmt = "${pkgs.nixfmt}/bin/nixfmt";
      flake8 = "${pkgs.python38Packages.flake8}/bin/flake8";
      mypy = "${pkgs.mypy}/bin/mypy";
      cscope = "${pkgs.cscope}/bin/cscope";
      isort = "${pkgs.python38Packages.isort}/bin/isort";
      ctags = "${pkgs.universal-ctags}/bin/ctags";
      github_token = github_token;
    }));

  programs.neovim = {
    enable = true;
    extraConfig = ''
      source ${mypkgs.spacevim_src}/init.vim
    '';
    extraPython3Packages = (ps: with ps; [ pynvim msgpack ]);
    withPython = false;
    withPython3 = true;
    withRuby = true;
  };
  programs.fish.functions.nvim = ''
    if string length -q -- $NVIM_ARGS
      command nvim (echo $NVIM_ARGS | string split " ") $argv;
    else
      command nvim $argv;
    end
  '';
}
