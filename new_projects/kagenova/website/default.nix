{ config, lib, pkgs, ... }:
let
  emails = {
    gitlab = "1085775-mdavezac@users.noreply.gitlab.com";
    github = "2745737+mdavezac@users.noreply.github.com";
  };
in
{
  config.workspaces."website" = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/marketing/website.git";
        settings.user.email = emails.gitlab;
        exclude = [
          "/.envrc"
          "/.local"
          "/secret.*"
        ];
        destination = ".";
      }
    ];
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell
        export IPYTHONDIR=$PWD/.local/ipython/
        export TFHUB_CACHE_DIR=$PWD/.local/cache/tfhub

        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT

        [ -e  .local/nvim ] || ln -s ~/personal/dotfiles/new_projects/kagenova/website .local/flake
        source_env .local/flake/.envrc

        export GEM_HOME=$PWD/.local/gem
        layout python3
      ''
    ];
    file.".local/ipython/profile_default/startup/startup.ipy".text = ''
      %load_ext autoreload
      %autoreload 2
    '';
  };
}
