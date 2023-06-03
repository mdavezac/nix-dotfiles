{
  config,
  lib,
  pkgs,
  ...
}: {
  config.workspaces."website" = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/marketing/website.git";
        settings.user.email = config.emails.gitlab;
        exclude = [
          "/.envrc"
          "/.local"
          "/secret.*"
        ];
        destination = ".";
      }
    ];
    python.enable = true;
    python.version = "3.7";
    python.packager = "poetry";
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell
        export IPYTHONDIR=$PWD/.local/ipython/
        export PULUMI_HOME=$PWD/.local/pulumi

        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT

        use flake .

        # [ -e  .local/flake ] || ln -s ~/personal/dotfiles/new_projects/kagenova/website .local/flake
        # source_env .local/flake/.envrc

        export GEM_HOME=$PWD/.local/gem
      ''
    ];
    file.".local/ipython/profile_default/startup/startup.ipy".text = ''
      %load_ext autoreload
      %autoreload 2
    '';
  };
}
