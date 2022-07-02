{ config, pkgs, lib, ... }: {
  require = [ ./kagenova ./personal.nix ./retired.nix ];
  home.packages = [ pkgs.lorri pkgs.niv ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = false;
  };

  programs.fish = {
    shellAliases.tmux =
      "${pkgs.direnv}/bin/direnv exec / ${pkgs.tmux}/bin/tmux";
    interactiveShellInit = ''
      ${pkgs.direnv}/bin/direnv hook fish | source
      set -e DIRENV_DIFF
      set -e DIRENV_DIR
      set -e DIRENV_WATCHES
      function autotmux --on-variable TMUX_SESSION_NAME
        if test "$TERM_PROGRAM" != "vscode" -a -z "$EMACS" -a -z "$INSIDE_EMACS"
          if test -n "$TMUX_SESSION_NAME" #only if set
            if test -z $TMUX #not if in TMUX
              if tmux has-session -t $TMUX_SESSION_NAME
                ${pkgs.direnv}/bin/direnv exec / ${pkgs.tmux}/bin/tmux attach -t "$TMUX_SESSION_NAME"
              else
                ${pkgs.direnv}/bin/direnv exec / ${pkgs.tmux}/bin/tmux new-session -s "$TMUX_SESSION_NAME"
              end
            end
          end
        end
      end
    '';
  };

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.DIRENV_LOG_FORMAT = "";

  home.file.".config/direnv/lib/cloner.sh".text = ''
    function cloner () {
        local url=$1
        local destination=$2
        local origin=$3
        local git=${pkgs.git}/bin/git

        [ -e "$destination/.git/HEAD" ] && return 1;

        tmpdir=$(mktemp -d)
        mkdir -p $tmpdir
        trap "rm -rf $tmpdir" EXIT

        url=''${url/#github:/https:\/\/github.com\/}
        url=''${url/#ssh_github:/git@github.com:}
        url=''${url/#gitlab:/https:\/\/gitlab.com\/}
        url=''${url/#ssh_gitlab:/git@gitlab.com:}

        $git clone --no-checkout --origin=$origin $url $tmpdir
        mkdir -p $destination/.git/
        mv $tmpdir/.git/* $destination/.git/

        $git -C $destination reset --hard HEAD
    }
  '';
  home.file.".config/direnv/lib/git_settings.sh".text = ''
    function git_settings() {
        local path=$1
        local git=${pkgs.git}/bin/git
        $git -C $2 config  --local include.path $path
    }
  '';
  home.file.".config/direnv/lib/nvim_setup.sh".text = ''
    nvim_setup () {
      path=$(realpath)/.local/vim
      [[ -e $path ]] || mkdir -p $path
      [[ -e $path/shada ]] || touch $path/shada
      [[ -e $path/session.vim ]] || touch $path/session.vim
      export NVIM_ARGS="-i $path/shada -S $path/session.vim"
      export NVIM_LISTEN_ADDRESS=$path/nvr_socket
    }
  '';
  home.file.".config/direnv/lib/fixnix.sh".text = ''
    fixnix () {
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      unset SOURCE_DATE_EPOCH
    }
  '';
  home.file.".config/direnv/lib/check_precommit.sh".text = ''
    check_precommit () {
      if [ -e .pre-commit-config.yaml ] && [ ! -e .git/hooks/pre-commit ]
      then
        pre-commit install
      fi
    }
  '';
  home.file.".config/direnv/lib/layout_poetry.sh".text = ''
    function layout_poetry {
        if [[ ! -f pyproject.toml ]]; then
          log_error 'No pyproject.toml found. Use `poetry new` or `poetry init` to create one first.'
          exit 2
        fi 

        if ! command -v poetry >& /dev/null ; then
          echo "Could not find poetry"
          exit 1
        fi
        poetry env use -q ''${1:-python3}

        export VIRTUAL_ENV=$(poetry env info --path)
        export POETRY_ACTIVE=1
        PATH_add "$VIRTUAL_ENV/bin"
    }
  '';
  home.file.".config/direnv/lib/real_path.sh".text = ''
    realpath() {
        [[ $1 = /* ]] && echo "$1" || echo "$PWD/''${1#./}"
    }
  '';
  home.file.".config/direnv/lib/layout_python-venv.sh".text = ''
    layout_python-venv() {
        local python=''${1:-python3}

        [[ $# -gt 0 ]] && shift
        unset PYTHONHOME
        if [[ -n $VIRTUAL_ENV ]]; then
            VIRTUAL_ENV=$(realpath "''${VIRTUAL_ENV}")
        else
            local python_version
            python_version=$("$python" -c "import platform; print(platform.python_version())")
            if [[ -z $python_version ]]; then
                log_error "Could not detect Python version"
                return 1
            fi
            VIRTUAL_ENV=$PWD/.direnv/python-venv-$python_version
        fi
        export VIRTUAL_ENV
        if [[ ! -d $VIRTUAL_ENV ]]; then
            log_status "no venv found; creating $VIRTUAL_ENV"
            "$python" -m venv "$VIRTUAL_ENV" $@
            "$VIRTUAL_ENV/bin/python" -m pip install --upgrade pip
        fi
        PATH_add "$VIRTUAL_ENV/bin"
    }
  '';
  home.file.".config/direnv/lib/extra_pip_packages.sh".text = ''
    extra_pip_packages() {
      if [[ "$(dirname $(which python))" == "/usr/bin" ]] ; then
        echo "Will not install package to system python $(which python)"
        exit 1
      fi
      packages=$(python -m pip freeze)
      for package in $@; do
        [[ "$packages" == *"$package"* ]] || python -m pip install $package
      done
    }
  '';
}
