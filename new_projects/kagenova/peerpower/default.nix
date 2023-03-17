{
  config,
  lib,
  pkgs,
  ...
}: let
  projconf = {
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

        [ -e .local/flake ] || ln -s ~/personal/dotfiles/new_projects/kagenova/peerpower .local/flake
        source_env .local/flake/.envrc

        export PGUSER=mdavezac
        export PGDATA=$PWD/.local/psql/data
        export PGHOST=$PWD/.local/psql/sockets


        export CLOUDSDK_CONFIG=$PWD/.local/gcloud
        export GOOGLE_APPLICATION_CREDENTIALS=$PWD/.local/gcloud/risk-ocr.json
      ''
    ];
  };
in {
  config.workspaces.ocr =
    projconf
    // {
      root = "kagenova/peerpower";
      repos = [
        {
          url = "github:peerpower/risk_ocr_engine.git";
          settings.user.email = config.emails.github;
          exclude = [
            "/.envrc"
            "/.local/"
            "/.direnv/"
            "/devenv"
            ".devenv"
            ".devenv.local.nix"
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
          from rocre.backend.testing.annotations import *
          from rocre.backend.annotations import *
          from rocre.backend.model.annotations import *
          from rocre.backend.annotations.utils import vertex_boundaries
        except:
          pass

        data_dir = Path("test/data")
        rng = np.random.default_rng()
      '';
    };
  config.workspaces.bsa =
    projconf
    // {
      root = "kagenova/peerpower";
      repos = [
        {
          url = "github:peerpower/risk_bank_statement_analysis_service.git";
          settings.user.email = config.emails.github;
          exclude = [
            "/.envrc"
            "/.local/"
            "/.direnv/"
            "/devenv"
            "note.md"
            "scratch.py"
            "script.py"
            "tests/data/"
            "/*.csv"
          ];
        }
      ];
      file.".local/ipython/profile_default/startup/startup.ipy".text = ''
        %load_ext autoreload
        %autoreload 2

        import numpy as np
        import pandas as pd
        from textwrap import dedent
        from pathlib import Path
        from pandarallel import pandarallel

        pandarallel.initialize(nb_workers=1)

        rng = np.random.default_rng()

        try:
          from app.grammar import *
          from app.grammar import helpers as help
          from app.grammar.kbank import helpers as khelp
          from app.services.transaction_description_extractor_kbank import extract_from_kbank
        except:
          pass

        min_partial_match = 15
        error_rate = 0.1
      '';
    };
}
