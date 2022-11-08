{ config, lib, pkgs, ... }:
let
  emails = {
    gitlab = "1085775-mdavezac@users.noreply.gitlab.com";
    github = "2745737+mdavezac@users.noreply.github.com";
  };
  config = {
    enable = true;
    python.enable = true;
    python.version = "3.10";
    python.packager = "poetry";
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell
        export IPYTHONDIR=$PWD/.local/ipython/
        export AWS_CONFIG_FILE=$PWD/.local/aws/config
        export AWS_SHARED_CREDENTIALS_FILE=$PWD/.local/aws/credentials
        export PASSWORD_STORE_DIR=$PWD/.local/passwords

        mkdir -p $(dirname $AWS_CONFIG_FILE)
        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT
        path_add PYTHONPATH $PWD/app $PWD/version2/app

        [ -e  .local/flake ] || ln -s ~/personal/dotfiles/new_projects/kagenova/peerpower .local/flake
        source_env .local/flake/.envrc

        export CLOUDSDK_CONFIG=$PWD/.local/gcloud
        export GOOGLE_APPLICATION_CREDENTIALS=$PWD/.local/gcloud/risk-ocr.json
      ''
    ];

  };
in
{
  config.workspaces.ocr = config // {
    root = "kagenova/peerpower";
    repos = [
      {
        url = "github:peerpower/risk_ocr_engine.git";
        settings.user.email = emails.github;
        exclude = [
          "/.envrc"
          "/.local/"
          "/.direnv/"
        ];
      }
    ];

    file.".local/aws/config".text = ''
      [profile peerpower-mayeul]
      region = "ap-southeast-1"
    '';

    file.".local/ipython/profile_default/startup/startup.ipy".text = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
      import pandas as pd
      import re
      from dataclasses import replace
      from pathlib import Path
      from textwrap import dedent
      from google.cloud import vision
      try:
        from backend.testing.annotations import *
        from backend.annotations import *
        from backend.model.annotations import *
        from backend.annotations.utils import vertex_boundaries
      except:
        pass

      data_dir = Path("test/data")
      rng = np.random.default_rng()
    '';
  };
  config.workspaces.bsa = config // {
    root = "kagenova/peerpower";
    repos = [
      {
        url = "github:peerpower/risk_bank_statement_analysis_service.git";
        settings.user.email = emails.github;
        exclude = [ "/.envrc" "/.local/" "/.direnv/" ];
      }
    ];
    file.".local/ipython/profile_default/startup/startup.ipy".text = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
      import pandas as pd
      from textwrap import dedent
      from pathlib import Path
      rng = np.random.default_rng()
    '';
  };
}
