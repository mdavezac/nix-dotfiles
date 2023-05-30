{
  config,
  lib,
  pkgs,
  ...
}: {
  config.workspaces.ai-pipeline = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "https://gitlab.com/kagenova/kagemove/development/data-pipeline.git";
        settings.user.email = config.emails.gitlab;
        exclude = ["/.local" "/.envrc" "/.devenv/" "/dist/" "/.vim/" "/.vscode/" "/.envrc.secrets"];
        destination = ".";
      }
    ];
    python.enable = true;
    python.version = "3.7";
    python.packager = "poetry";
    envrc = [
      ''
        use flake

        export IPYTHONDIR=$PWD/.local/ipython/
        export PULUMI_HOME=$(pwd)/.local/pulumi;
        export COMPOSE_FILE=$(pwd)/.docker/docker-compose.yml
        source_env_if_exists $PWD/.envrc.secrets
      ''
    ];
    file.".local/bin/switch_stack.fish".text = ''
      function switch_stack -a arg
          set -e SQL_PASSWORD
          set -e SQL_USERNAME
          set -e SQL_PORT
          set -e GOOGLE_APPLICATION_CREDENTIALS
          set -e COPERNIC360_HOST
          set -e PYTEST_PULUMI_STACK
          set -e AWS_REGION
          set -gx SQL_DATABASE spatial360_api
          set local_pwd "/Users/mdavezac/kagenova/ai-pipeline/"
          set stack $arg
          switch $arg
              case development
                  set gcp_config development
                  set aws_profile mdavezac-testing
                  set puldir $local_pwd/infrastructure
              case bootstrap
                  set gcp_config development
                  set stack bootstrap
                  set aws_profile development
                  set puldir $local_pwd/bootstrap
              case monitoring-development
                  set gcp_config development
                  set stack development
                  set aws_profile monitoring-development
                  set puldir $local_pwd/infrastructure
              case staging
                  set gcp_config staging
                  set aws_profile staging
                  set puldir $local_pwd/infrastructure
              case bootstrap-staging
                  set gcp_config staging
                  set aws_profile staging
                  set puldir $local_pwd/bootstrap
              case bootstrap
                  set gcp_config production
                  set aws_profile production
                  set puldir $local_pwd/infrastructure
              case bootstrap-production
                  set gcp_config production
                  set aws_profile production
                  set puldir $local_pwd/bootstrap
              case production
                  set gcp_config production
                  set aws_profile mdavezac
                  set puldir $local_pwd/infrastructure
              case local
                  set -e GOOGLE_APPLICATION_CREDENTIALS
                  set -gx PYTEST_PULUMI_STACK local
                  set -gx SQL_PASSWORD "p@ssw0rd1"
                  set -gx SQL_USERNAME root
                  set -gx SQL_PORT 3306
                  return 0
              case '*'
                  echo not a known stack $stack
                  return 1
          end
          set -gx AWS_PROFILE $aws_profile
          aws-vault exec $aws_profile -- pulumi -C $puldir stack select $stack
          if ! string match -qer "(bootstrap|monitoring).*" "$stack"
              set -gx GOOGLE_APPLICATION_CREDENTIALS $local_pwd/.local/spatial360-$gcp_config.json
              set -gx COPERNIC360_HOST (aws-vault exec $aws_profile -- pulumi stack output -C $local_pwd/infrastructure engine-url)
          end
          gcloud config configurations activate copernic360-$gcp_config
      end
    '';
  };
}
