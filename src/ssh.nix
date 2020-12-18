{ config, pkgs, lib, ... }: {
  programs.ssh = {
    enable = true;
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
        identityFile = "/Users/mdavezac/.ssh/gitlab_ed25519";
        identitiesOnly = true;
      };
      github = {
        user = "git";
        hostname = "github.com";
        identityFile = "/Users/mdavezac/.ssh/github_ed25519";
        identitiesOnly = true;
      };
      bitbucket = {
        user = "git";
        hostname = "bitbucket.com";
        identityFile = "/Users/mdavezac/.ssh/bitbucket_ed25519";
        identitiesOnly = true;
      };
      hpc = {
        user = "mdavezac";
        hostname = "login.hpc.imperial.ac.uk";
      };
      "hpc-02" = {
        user = "mdavezac";
        hostname = "login-2.hpc.imperial.ac.uk";
      };
      "hpc-03" = {
        user = "mdavezac";
        hostname = "login-3.hpc.imperial.ac.uk";
      };
      "hpc-04" = {
        user = "mdavezac";
        hostname = "login-4.hpc.imperial.ac.uk";
      };
    };
  };
}
