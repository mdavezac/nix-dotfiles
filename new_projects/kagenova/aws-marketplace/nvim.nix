{ spacenix, configuration, pkgs, system }:
let
  nvim = spacenix.wrapper.${system} { configuration = configuration; };
  vicmd = ''
    rpc=$PRJ_DATA_DIR/nvim.rpc
    [ -e $rpc ] && ${pkgs.neovim-remote}/bin/nvr --servername $rpc -s $@ || ${nvim}/bin/nvim $@
  '';
  vi_args = [
    "${pkgs.neovim-remote}/bin/nvr"
    "--servername"
    "$PRJ_DATA_DIR/nvim.rpc"
    "-cc split"
    "--remote-wait"
    "-s"
    "$@"
  ];
in
{
  devshell.packages = [ nvim ];
  commands = builtins.map (x: { name = x; command = vicmd; }) [ "vim" "vi" ];
  env = [
    { name = "EDITOR"; value = builtins.concatStringsSep " " vi_args; }
    { name = "NVIM_LISTEN_ADDRESS"; eval = "$PRJ_DATA_DIR/nvim.rpc"; }
  ];
}
