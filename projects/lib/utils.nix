{ pkgs, config, lib, ... }:
rec {
  toTOML = path: toml: pkgs.runCommand "init.toml"
    {
      buildInputs = [ pkgs.remarshal ];
      preferLocalBuild = true;
    } ''
    remarshal -if json -of toml \
      < ${pkgs.writeText "${path}" (builtins.toJSON toml)} \
      > $out
  '';
  starship_conf = extras: let
    original = import ../../src/starship.nix { inherit config lib pkgs; };
  in
    (toTOML "starship.TOML" original.programs.starship.settings // extras);

  toPrettyJSON = input: pkgs.runCommand "output.json"
    {
      buildInputs = [ pkgs.jq ];
      preferLocalBuild = true;
    } ''
    jq < ${pkgs.writeText "stuff.json" (builtins.toJSON input)} > $out
  '';
}
