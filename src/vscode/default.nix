{ config, pkgs, lib, ... }: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [ vscodevim.vim bbenoist.Nix ]
      ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace
        (builtins.attrValues (import ./extensions.nix)));
    userSettings = {
      debug = {
        inlineValues = true;
        toolBarLocation = "docked";
      };
      editor = {
        fontFamily = "VictorMono Nerd Font";
        fontLigatures = true;
        fontSize = 11;
        formatOnPaste = true;
        formatOnSave = true;
        formatOnType = false;
        lineNumbers = "relative";
        minimap.enabled = false;
        multiCursorModifier = "ctrlCmd";
        wordWrapColumn = 120;
        wrappingIndent = "deepIndent";
      };
      files = {
        trimFinalNewlines = true;
        trimTrailingWhitespace = true;
      };
      telemetry = {
        enableCrashReporter = false;
        enableTelemetry = false;
      };
      terminal = {
        external.osxExec = "${pkgs.kitty}/Applications/kitty.app";
        integrated.fontSize = 11;
        integrated.scrollback = 100000;
        integrated.shell.osx = "${pkgs.fish}/bin/fish";
      };
      toggl = {

        apiKey = "b81adb6f88ec884e711a3aec04e83125";
        defaultProjectId = "106739335";
      };
      vim = {
        statusBarColorControl = true;
        statusBarColors.insert = "#5f1a1a";
        statusBarColors.normal = "#1a1a1a";
        statusBarColors.visual = "#1a0030";
        statusBarColors.visualblock = "#3a3a1a";
        statusBarColors.visualline = "#3a2a2a";
      };
      window = {
        nativeFullScreen = true;
        zoomLevel = 0;
      };
      workbench = {
        activityBar.visible = true;
        editor.enablePreview = false;
        editor.showTabs = true;
        statusBar.feedback.visible = false;
        panel.defaultLocation = "right";
      };
      vsicons.dontShowNewVersionMessage = true;
      python.dataScience.sendSelectionToInteractiveWindow = false;
      nixfmt.path = "${pkgs.nixfmt}/bin/nixfmt";
    };
  };
  home.file."Library/Application Support/Code/User/keybindings.json".source =
    ./keybindings.json;
}
