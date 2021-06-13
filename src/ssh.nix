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
      gitlab = {
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
      deepaws = {
        user = "ubuntu";
        hostname = "ec2-3-8-99-1.eu-west-2.compute.amazonaws.com";
        identityFile = "/Users/mdavezac/.ssh/AWSDeepLearning.pem";
        identitiesOnly = true;
        forwardAgent = false;
      };
      };
    };
  };
}
