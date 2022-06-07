{ config, lib, ... }: {
  options.home = lib.mkOption {
    type = lib.types.submodule {
      options.file = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options.content = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
        });
        default = { };
      };
    };
    default = { };
  };
}
