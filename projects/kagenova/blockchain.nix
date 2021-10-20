{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
in
{
  imports = builtins.map mkProject [ "blockchain" "pandp" ];

  projects.kagenova.blockchain = {
    enable = true;
    repos.ethereumbook = {
      url = "https://github.com/ethereumbook/ethereumbook.git";
      dest = "book";
      settings.user.email = emails.github;
    };
    repos.website = {
      url = "https://gitlab.com/kagenova/marketing/autonomous-painter-website.git";
      dest = "website";
      settings.user.email = emails.gitlab;
    };
    repos.hardhat = {
      url = "https://gitlab.com/kagenova/hacks/kagenft.git";
      dest = "hardhat";
      settings.user.email = emails.gitlab;
    };
    extraEnvrc = ''
      eval "$(lorri direnv)"
    '';
    file."shell.nix".text = ''
      let
        sources = import /Users/mdavezac/kagenova/blockchain/opensea/nix/sources.nix;
        niv = import sources.nixpkgs {};
      in
      niv.mkShell {
        project = "blockchain-opensea";
        buildInputs = [ niv.nodejs-12_x niv.python39 niv.nodePackages.node2nix ];
      }
    '';
    file."website/.envrc".text = ''
      eval "$(lorri direnv)"
      layout python3
      export PULUMI_HOME=$(realpath $(pwd)/../.local/pulumi);
      export AWS_SHARED_CREDENTIALS_FILE=$(realpath $(pwd)/../.local/aws/credentials)
      export AWS_PROFILE="development"
      export AWS_REGION="eu-west-2"
    '';
  };

  # pando: {{{
  projects.kagenova.pando = {
    enable = true;
    repos.web = {
      url = "https://gitlab.com/kagenova/marketing/project-pando-website.git";
      dest = ".";
      settings.user.email = emails.gitlab;
    };
    extraEnvrc = ''
      export AWS_PROFILE="development"
      export AWS_REGION="eu-west-2"
    '';
    nixshell = {
      text = ''
        buildInputs = [
          pkgs.nodejs-12_x
          awscli2
        ];
      '';
    };
  };
  # }}}
}
