{
  config,
  lib,
  pkgs,
  ...
}: {
  config.workspaces.sparse-dense-tests = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/kagelearn/development/sparse-dense-tests";
        settings.user.email = config.emails.gitlab;
        exclude = ["/.local"];
        destination = ".";
      }
    ];
    envrc = [
      ''
        export IPYTHONDIR=$PWD/.local/ipython/

        use flake --impure

        export POETRY_VIRTUALENVS_PATH=$PWD/.local/poetry/venvs
        layout poetry 3.10
      ''
    ];
    file.".local/ipython/profile_default/startup/startup.ipy".text = ''
      %load_ext autoreload
      %autoreload 2
    '';
  };
}
