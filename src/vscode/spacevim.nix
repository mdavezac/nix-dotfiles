{
  leader = "<space>";
  visualModeKeyBindings = [
    {
      before = [ "<leader>" "<space>" ];
      commands = [ "workbench.action.showCommands" ];
    }
    {
      before = [ "<leader>" ";" ];
      commands = [ "editor.action.commentLine" ];
    }
    {
      before = [ "f" "d" ];
      after = [ "<Esc>" ];
    }
    {
      before = [ "<leader>" "*" ];
      commands = [ "references-view.find" ];
    }
    {
      before = [ "<leader>" "j" "=" ];
      commands = [ "editor.action.format" ];
    }
    {
      before = [ "leader" "j" "j" ];
      after = [ "leader" "leader" "s" ];
    }
    {
      before = [ "leader" "j" "l" ];
      after = [ "leader" "leader" "leader" "b" "d" "j" "k" ];
    }
    {
      before = [ "leader" "j" "w" ];
      after = [ "leader" "leader" "leader" "b" "d" "w" ];
    }
    {
      before = [ "<leader>" "s" "p" ];
      commands = [ "workbench.action.findInFiles" ];
    }
    {
      before = [ "<leader>" "x" "s" ];
      commands = [ "editor.action.sortLinesAscending" ];
    }
  ];
  normalModeKeyBindings = [
    {
      before = [ "<leader>" "<space>" ];
      commands = [ "workbench.action.showCommands" ];
    }
    {
      before = [ "<leader>" "<tab>" ];
      commands =
        [ "workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup" ];
    }
    {
      before = [ "<leader>" "*" ];
      commands = [ "references-view.find" ];
    }
    {
      before = [ "<leader>" ";" ";" ];
      commands = [ "editor.action.commentLine" ];
    }
    {
      before = [ "<leader>" "'" ];
      commands = [ "workbench.action.terminal.toggleTerminal" ];
    }
    {
      before = [ "<leader>" "/" ];
      commands = [ "workbench.action.findInFiles" ];
    }
    {
      before = [ "<leader>" "1" ];
      commands = [ "workbench.action.focusFirstEditorGroup" ];
    }
    {
      before = [ "<leader>" "2" ];
      commands = [ "workbench.action.focusSecondEditorGroup" ];
    }
    {
      before = [ "<leader>" "3" ];
      commands = [ "workbench.action.focusThirdEditorGroup" ];
    }
    {
      before = [ "<leader>" "4" ];
      commands = [ "workbench.action.focusFourthEditorGroup" ];
    }
    {
      before = [ "<leader>" "5" ];
      commands = [ "workbench.action.focusFifthEditorGroup" ];
    }
    {
      before = [ "<leader>" "6" ];
      commands = [ "workbench.action.focusSixthEditorGroup" ];
    }
    {
      before = [ "<leader>" "7" ];
      commands = [ "workbench.action.focusSeventhEditorGroup" ];
    }
    {
      before = [ "<leader>" "8" ];
      commands = [ "workbench.action.focusEighthEditorGroup" ];
    }
    {
      before = [ "<leader>" "b" "b" ];
      commands = [ "workbench.action.showAllEditors" ];
    }
    {
      before = [ "<leader>" "b" "d" ];
      commands = [ "workbench.action.closeActiveEditor" ];
    }
    {
      before = [ "<leader>" "b" "<C-d>" ];
      commands = [ "workbench.action.closeOtherEditors" ];
    }
    {
      before = [ "<leader>" "b" "n" ];
      commands = [ "workbench.action.nextEditor" ];
    }
    {
      before = [ "<leader>" "b" "p" ];
      commands = [ "workbench.action.previousEditor" ];
    }
    {
      before = [ "<leader>" "b" "s" ];
      commands = [ "workbench.action.files.newUntitledFile" ];
    }
    {
      before = [ "<leader>" "b" "u" ];
      commands = [ "workbench.action.reopenClosedEditor" ];
    }
    {
      before = [ "<leader>" "e" "l" ];
      commands = [ "workbench.actions.view.problems" ];
    }
    {
      before = [ "<leader>" "e" "n" ];
      commands = [ "editor.action.marker.next" ];
    }
    {
      before = [ "<leader>" "e" "p" ];
      commands = [ "editor.action.marker.prev" ];
    }
    {
      before = [ "<leader>" "f" "e" ];
      commands = [ "workbench.action.openGlobalSettings" ];
    }
    {
      before = [ "<leader>" "f" "f" ];
      commands = [ "workbench.action.files.openFileFolder" ];
    }
    {
      before = [ "<leader>" "f" "r" ];
      commands = [ "workbench.action.openRecent" ];
    }
    {
      before = [ "<leader>" "f" "s" ];
      commands = [ "workbench.action.files.save" ];
    }
    {
      before = [ "<leader>" "f" "S" ];
      commands = [ "workbench.action.files.saveAll" ];
    }
    {
      before = [ "<leader>" "f" "t" ];
      commands = [ "workbench.view.explorer" ];
    }
    {
      before = [ "<leader>" "f" "T" ];
      commands = [ "workbench.files.action.showActiveFileInExplorer" ];
    }
    {
      before = [ "<leader>" "f" "y" ];
      commands = [ "workbench.action.files.copyPathOfActiveFile" ];
    }
    {
      before = [ "<leader>" "g" "b" ];
      commands = [ "git.checkout" ];
    }
    {
      before = [ "<leader>" "g" "c" ];
      commands = [ "git.commit" ];
    }
    {
      before = [ "<leader>" "g" "d" ];
      commands = [ "git.deleteBranch" ];
    }
    {
      before = [ "<leader>" "g" "f" ];
      commands = [ "git.fetch" ];
    }
    {
      before = [ "<leader>" "g" "i" ];
      commands = [ "git.init" ];
    }
    {
      before = [ "<leader>" "g" "m" ];
      commands = [ "git.merge" ];
    }
    {
      before = [ "<leader>" "g" "p" ];
      commands = [ "git.publish" ];
    }
    {
      before = [ "<leader>" "g" "s" ];
      commands = [ "workbench.view.scm" ];
    }
    {
      before = [ "<leader>" "g" "S" ];
      commands = [ "git.stage" ];
    }
    {
      before = [ "<leader>" "g" "U" ];
      commands = [ "git.unstage" ];
    }
    {
      before = [ "<leader>" "h" "d" ];
      commands = [ "workbench.action.openGlobalKeybindings" ];
    }
    {
      before = [ "<leader>" "i" "s" ];
      commands = [ "editor.action.insertSnippet" ];
    }
    {
      before = [ "<leader>" "j" "=" ];
      commands = [ "editor.action.formatDocument" ];
    }
    {
      before = [ "leader" "j" "j" ];
      after = [ "leader" "leader" "s" ];
    }
    {
      before = [ "leader" "j" "l" ];
      after = [ "leader" "leader" "leader" "b" "d" "j" "k" ];
    }
    {
      before = [ "leader" "j" "w" ];
      after = [ "leader" "leader" "leader" "b" "d" "w" ];
    }
    {
      before = [ "<leader>" "l" "d" ];
      commands = [ "workbench.action.closeFolder" ];
    }
    {
      before = [ "<leader>" "p" "f" ];
      commands = [ "workbench.action.quickOpen" ];
    }
    {
      before = [ "<leader>" "p" "g" ];
      commands = [ "workbench.action.showEditorsInActiveGroup" ];
    }
    {
      before = [ "<leader>" "p" "l" ];
      commands = [ "workbench.action.files.openFolder" ];
    }
    {
      before = [ "<leader>" "p" "p" ];
      commands = [ "workbench.action.openRecent" ];
    }
    {
      before = [ "<leader>" "p" "t" ];
      commands = [ "workbench.view.explorer" ];
    }
    {
      before = [ "<leader>" "q" "f" ];
      commands = [ "workbench.action.closeWindow" ];
    }
    {
      before = [ "<leader>" "q" "q" ];
      commands = [ "workbench.action.closeWindow" ];
    }
    {
      before = [ "<leader>" "q" "r" ];
      commands = [ "workbench.action.reloadWindow" ];
    }
    {
      before = [ "<leader>" "r" "s" ];
      commands = [ "workbench.action.findInFiles" ];
    }
    {
      before = [ "<leader>" "s" "e" ];
      commands = [ "editor.action.rename" ];
    }
    {
      before = [ "<leader>" "s" "j" ];
      commands = [ "workbench.action.gotoSymbol" ];
    }
    {
      before = [ "<leader>" "s" "p" ];
      commands = [ "workbench.action.findInFiles" ];
    }
    {
      before = [ "<leader>" "s" "P" ];
      after = [ "v" "i" "w" "<leader>" "s" "p" "<Esc>" ];
    }
    {
      before = [ "<leader>" "T" "F" ];
      commands = [ "workbench.action.toggleFullScreen" ];
    }
    {
      before = [ "<leader>" "T" "m" ];
      commands = [ "workbench.action.toggleMenuBar" ];
    }
    {
      before = [ "<leader>" "T" "s" ];
      commands = [ "workbench.action.selectTheme" ];
    }
    {
      before = [ "<leader>" "T" "t" ];
      commands = [ "workbench.action.toggleActivityBarVisibility" ];
    }
    {
      before = [ "<leader>" "v" ];
      commands = [ "editor.action.smartSelect.grow" ];
    }
    {
      before = [ "<leader>" "V" ];
      commands = [ "editor.action.smartSelect.shrink" ];
    }
    {
      before = [ "<leader>" "w" "-" ];
      commands = [ "workbench.action.splitEditorDown" ];
    }
    {
      before = [ "<leader>" "w" "/" ];
      commands = [ "workbench.action.splitEditorRight" ];
    }
    {
      before = [ "<leader>" "w" "d" ];
      commands = [ "workbench.action.closeEditorsInGroup" ];
    }
    {
      before = [ "<leader>" "w" "h" ];
      commands = [ "workbench.action.focusPreviousGroup" ];
    }
    {
      before = [ "<leader>" "w" "H" ];
      commands = [ "workbench.action.moveActiveEditorGroupLeft" ];
    }
    {
      before = [ "<leader>" "w" "j" ];
      commands = [ "workbench.action.focusBelowGroup" ];
    }
    {
      before = [ "<leader>" "w" "J" ];
      commands = [ "workbench.action.moveActiveEditorGroupDown" ];
    }
    {
      before = [ "<leader>" "w" "k" ];
      commands = [ "workbench.action.focusAboveGroup" ];
    }
    {
      before = [ "<leader>" "w" "K" ];
      commands = [ "workbench.action.moveActiveEditorGroupUp" ];
    }
    {
      before = [ "<leader>" "w" "l" ];
      commands = [ "workbench.action.focusNextGroup" ];
    }
    {
      before = [ "<leader>" "w" "L" ];
      commands = [ "workbench.action.moveActiveEditorGroupRight" ];
    }
    {
      before = [ "<leader>" "w" "m" ];
      commands = [ "workbench.action.toggleEditorWidths" ];
    }
    {
      before = [ "<leader>" "w" "s" ];
      commands = [ "workbench.action.splitEditorDown" ];
    }
    {
      before = [ "<leader>" "w" "v" ];
      commands = [ "workbench.action.splitEditor" ];
    }
    {
      before = [ "<leader>" "w" "w" ];
      commands = [ "workbench.action.focusNextGroup" ];
    }
    {
      before = [ "<leader>" "w" "W" ];
      commands = [ "workbench.action.focusPreviousGroup" ];
    }
    {
      before = [ "<leader>" "x" "s" ];
      commands = [ "editor.action.sortLinesAscending" ];
    }
    {
      before = [ "<leader>" "x" "w" ];
      commands = [ "editor.action.trimTrailingWhitespace" ];
    }
  ];
  insertModeKeyBindings = [{
    before = [ "f" "d" ];
    after = [ "<Esc>" ];
  }];
  easymotion = true;
  useSystemClipboard = true;
}
