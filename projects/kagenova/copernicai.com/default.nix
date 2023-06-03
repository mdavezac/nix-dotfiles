{
  config,
  lib,
  pkgs,
  ...
}: {
  config.workspaces."copernicai.com" = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/marketing/copernicai.com.git";
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
    python.version = "3.9";
    python.packager = "poetry";
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell
        export IPYTHONDIR=$PWD/.local/ipython/
        export PULUMI_HOME=$PWD/.local/pulumi
        export GEN360_BUILD_DIR=$PWD/.local/build
        export GEM_HOME=$PWD/.local/gem

        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT

        use flake .
      ''
    ];
    file.".local/nvim.lua".text = ''
      return {
        { "NoahTheDuke/vim-just" },
      }
    '';
  };
}
