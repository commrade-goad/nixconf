((magit-am
  ("--3way"))
 (magit-blame
  ("-w"))
 (magit-commit
  ("--verbose")
  nil)
 (magit-diff
  (("--" "config.h")
   "--no-ext-diff" "--stat")
  ("--no-ext-diff" "--stat"))
 (magit-log
  ("-n256" "--graph" "--decorate"))
 (magit-merge nil)
 (magit-pull nil)
 (magit-push nil
             ("--force"))
 (magit-rebase
  ("--autostash"))
 (magit-status-jump nil))
