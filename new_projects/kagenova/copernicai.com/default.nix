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
    python.enable = false;
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell
        export IPYTHONDIR=$PWD/.local/ipython/
        export PULUMI_HOME=$PWD/.local/pulumi
        export HATCH_DATA_DIR=$PWD/.local/hatch/data
        export HATCH_CACHE_DIR=$PWD/.local/hatch/cache
        export HATCH_CONFIG=$PWD/.local/hatch/config.toml


        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT
        mkdir -p $HATCH_CACHE_DIR
        mkdir -p $HATCH_DATA_DIR

        use flake .

        flakedir=~/personal/dotfiles/new_projects/kagenova/copernicai.com
        [ -e  .local/flake ] || ln -s $flakedir .local/flake
        source_env .local/flake

        export GEM_HOME=$PWD/.local/gem
      ''
    ];
    file.".local/hatch/config.toml".text = ''
      mode = "project"
      project = "stable360"
      shell = "fish"

      [dirs]
      project = ["/Users/mdavezac/kagenova/copernicai.com/"]
      python = "isolated"
    '';
  };
}
