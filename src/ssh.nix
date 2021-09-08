{ config, pkgs, lib, ... }: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    extraConfig = ''
      IdentitiesOnly yes
      UseKeychain yes
      AddKeysToAgent yes
      PreferredAuthentications publickey,password
    '';
    matchBlocks = {
      "gitlab.com" = {
        user = "git";
        hostname = "gitlab.com";
        identitiesOnly = true;
        identityFile = "/Users/mdavezac/.ssh/gitlab_rsa";
        forwardAgent = false;
      };
      github = {
        user = "git";
        hostname = "github.com";
        identitiesOnly = true;
        forwardAgent = false;
      };
      bitbucket = {
        user = "git";
        hostname = "bitbucket.com";
        identitiesOnly = true;
        forwardAgent = false;
      };
      kageml = {
        user = "davezac";
        hostname = "kagenova.ddnsfree.com";
        identityFile = "/Users/mdavezac/.ssh/kageml_rsa";
        port = 221;
        identitiesOnly = true;
      };
      hiro = {
        user = "davezac";
        hostname = "hiroprotagonist.net";
        identityFile = "/Users/mdavezac/.ssh/kageml_rsa";
        port = 221;
        identitiesOnly = true;
      };
      deepaws = {
        user = "ubuntu";
        hostname = "ec2-34-249-71-13.eu-west-1.compute.amazonaws.com";
        identityFile = "/Users/mdavezac/.ssh/AWSmdavezac.pem";
        identitiesOnly = true;
        forwardAgent = true;
      };
      vbox = {
        user = "vagrant";
        hostname = "127.0.0.1";
        port = 2222;
      };
    };
  };
}
