{ config
, lib
, pkgs
, ...
}: {
  config.workspaces.cv = {
    enable = true;
    root = "personal";
    repos = [
      {
        url = "gitlab:mdavezac/cv.git";
        settings.user.email = config.emails.gitlab;
        exclude = [ "/.local" ];
        destination = ".";
      }
    ];
    envrc = [
      ''
        mkdir -p .local
        [ -e  .local/flake ] || ln -s ~/personal/dotfiles/new_projects/personal/cv .local/flake
        source_env .local/flake/.envrc
      ''
    ];
  };
}
