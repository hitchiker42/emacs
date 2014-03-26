;;-*-emacs-lisp-*-
;;;My emacs lisp init file, Everything execept for custom set vars/faces
(add-to-list 'load-path "/home/tucker/.emacs.d")
(add-to-list 'load-path "/home/tucker/.emacs.d/my-elisp")
(setq custom-file "/home/tucker/.emacs.d/custom.elc")
(load custom-file)
(load "misc.elc")
(package-initialize ())
(setq inferior-lisp-program "/home/tucker/usr/bin/sbcl")
(load "/home/tucker/quicklisp/slime-helper.el")
(defalias 'yes-or-no-p 'y-or-n-p)
(defalias 'elisp-mode 'emacs-lisp-mode)
(defalias 'eshell-new 'multi-eshell)
(defalias 'perl-mode 'cperl-mode)
;;require packages
(dolist (package 
'(auto-complete rainbow-delimiters w3m-autoloads wind-swap
  mlton auto-async-byte-compile uniquify julia-mode constants))
  (require package))
(global-rainbow-delimiters-mode)
(global-auto-complete-mode)
(icicle-mode)
(column-number-mode)
(windmove-default-keybindings)
(toggle-diredp-find-file-reuse-dir 1)
(menu-bar-showhide-tool-bar-menu-customize-disable)
(menu-bar-no-scroll-bar)
(setq-default indent-tabs-mode nil)
(setq
 ;;not sure if this works
 multi-eshell-shell-function '(eshell)
 icicle-TAB/S-TAB-only-completes-flag t
 org-replace-disputed-keys t
 x-select-enable-clipboard t
 x-select-enable-primary t
 confirm-kill-emacs #'y-or-n-p 
 emacs-lisp-mode-hook '(turn-on-eldoc-mode enable-auto-async-byte-compile-mode)
 ;;This regexp should ignore all backup Files
 auto-async-byte-compile-exclude-files-regexp ".*~$\|^#.*#$"
 apropos-do-all t
 scroll-conservatively 10000
 browse-kill-ring-quit-action 'save-and-restore
 iswitchb-default-method 'maybe-frame
 iconify-or-deiconify-frame nil
 auto-window-vscroll nil)
;;;Automode stuff
(cl-flet ((temp (x) (add-to-list 'auto-mode-alist x)))
  (mapcar #'temp '(("\\.fun\\'" . sml-mode)
                   ("\\.mlb\\'" . sml-mode)
                   ("PKGBUILD" . pkgbuild-mode)
                   ("/\\..*rc\\'" . conf-unix-mode)
                   ("/\\.?bash" . sh-mode)
                   ("\\.jl\\'" . julia-mode))))

;;;Keys
;;regexp stuff
(define-key global-map [?\C-c ?r] 'replace-regexp)
(define-key global-map [?\C-s] 'isearch-forward-regexp)
(define-key global-map [?\C-r] 'isearch-backward-regexp)
(define-key global-map [?\C-z] 'nil)
(define-key global-map [?\C-c ?q ?r] 'query-replace-regexp)
(define-key global-map [?\C-\M-s] 'isearch-forward)
(define-key global-map [?\C-\M-r] 'isearch-backward)
(define-key global-map [?\C-c ?\C-r ?s]  'replace-string)
(define-key global-map [?\C-x ?\C-g] 'keyboard-quit)
;(define-key global-map "\M-/" 'hippie-expand)
(define-key global-map '[C-tab] 'hippie-expand)
(define-key global-map [?\C-c ?u] 'insert-char)
;;eval map, not sure why I could never get this to work before
(define-prefix-command 'eval-map)
(define-key global-map [?\C-c ?e] 'eval-map)
(define-key eval-map [?b] 'eval-buffer)
(define-key eval-map [?e] 'eval-expression)
(define-key eval-map [?f] 'eval-defun)
(define-key eval-map [?j] (as-command eval-last-sexp-1 t))
(define-key eval-map [?r] 'eval-region)
(define-key eval-map [?s] 'eval-last-sexp)
;;reverting buffers is useful, changing coding systems not so much
(define-key ctl-x-map '[?\r ?r] 'revert-buffer)
(define-key ctl-x-map '[?\C-b] 'ibuffer)

(define-prefix-command 'nested-help-map)
(define-key help-map [?h] 'nested-help-map)
(define-key nested-help-map [?r]
  (lambda () (interactive) (info "(elisp) Syntax of Regexps")))
(define-key nested-help-map [?h] 'view-hello-file)
;;prefix keys ESC(esc-map),C-h(help-map),C-c(mode-specific-map)
;;C-x(ctl-x-map),C-x RET(mule-keymap),C-x 4/5(ctl-4-map,ctl-5-map)
;;C-x 6 (2C-mode-map),C-x v(vc-prefix-map),M-g(goto-map),M-s(search-map)
;;M-o(facemenu-map), C-x @,C-x a i,C-x ESC & ESC ESC(unamed keymaps)
;;C-x ESC
;; (keymap
;;  (backtab . icicle-complete-keys)
;;  (58 . repeat-complex-command); :
;;  (27 . repeat-complex-command));ESC
;;;M-s(search-map)
;; (keymap
;;  (backtab . icicle-complete-keys)
;;  (46 . isearch-forward-symbol-at-point) ;.
;;  (95 . isearch-forward-symbol) ;_
;;  (119 . isearch-forward-word) ;w
;;  (104 keymap ;h
;;       (backtab . icicle-complete-keys)
;;       (119 . hi-lock-write-interactive-patterns);w
;;       (102 . hi-lock-find-patterns);f
;;       (117 . unhighlight-regexp);u
;;       (46 . highlight-symbol-at-point);.
;;       (108 . highlight-lines-matching-regexp);l
;;       (112 . highlight-phrase);p
;;       (114 . highlight-regexp));r
;;  (111 . occur))
;;;M-g(goto-map)
;; (keymap
;;  (backtab . icicle-complete-keys)
;;  (9 . move-to-column);tab
;;  (112 . previous-error);p
;;  (110 . next-error);n
;;  (27 keymap ;;ESC/Meta/Alt
;;      (backtab . icicle-complete-keys)
;;      (112 . previous-error);p
;;      (110 . next-error);n
;;      (103 . goto-line));g
;;  (103 . goto-line);(M-)g
;;  (99 . goto-char));c
;; \M-p and \M-n are unbound in the global keymap

;;;My map, f2 as prefix key
(require 'my-banish)
(define-prefix-command 'f2-map)
(define-key global-map [f2] 'f2-map)
(define-key global-map [?\M-p] 'f2-map)
(define-key f2-map [?a] 'beginning-of-line-text)
(define-key f2-map [?b] 'my-banish-mouse);send mouse to bottom right corner
(define-key f2-map [?c] 'comment-region)
(define-key f2-map [?e] 'multi-eshell)
(define-key f2-map [?f] 'fill-region)
(define-key f2-map [?i] 'indent-region)
(define-key f2-map [?n] ;echo filname of current buffer
  '(lambda () (interactive) (message (buffer-file-name))))
(define-key f2-map [?p] 'list-packages)
(define-key f2-map [?s] 'sort-lines)
(define-key f2-map [?u] 'uncomment-region)
(define-key f2-map [?w] 'whitespace-cleanup)
(define-key f2-map [?y] 'browse-kill-ring)
(define-key f2-map [?.] 'org-time-stamp)

(define-prefix-command 'f3-map)
(define-key global-map [f3] 'f3-map)
(define-key global-map [?\M-n] 'f3-map)
(define-key f3-map [?u] 'insert-char)
;;overide any bindings for M-p so I can use it
(defvar my-keys-mode-map (make-keymap) "my-keys-minor-mode keymap.")
(setq my-keys-mode-map (make-keymap))
(define-key my-keys-mode-map [?\M-p] 'f2-map)
(define-key my-keys-mode-map [?\M-n] 'f3-map)
(define-minor-mode my-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t :lighter "" :keymap my-keys-mode-map)
(define-global-minor-mode my-keys-global-minor-mode my-keys-minor-mode
  my-keys-minor-mode)
(my-keys-global-minor-mode 1)
;;;Set theme path based on files in elpa directory
(require 'dash)
(require 's)
(-each
 (-map
  (lambda (item)
    (format "~/.emacs.d/elpa/%s" item))
  (-filter
   (lambda (item) (s-contains? "theme" item))
   (directory-files "~/.emacs.d/elpa/")))
 (lambda (item)
   (add-to-list 'custom-theme-load-path item)))
(load-theme 'zenburn t)

;;;Maxima
 (add-to-list 'load-path
              "/home/tucker/usr/share/maxima/branch_5_30_base_188_ga88b18b/emacs/")
 (autoload 'maxima-mode "maxima" "Maxima mode" t)
 (autoload 'imaxima "imaxima" "Frontend for maxima with Image support" t)
 (autoload 'maxima "maxima" "Maxima interaction" t)
 (autoload 'imath-mode "imathn" "Imath mode for math formula input" t)
 (setq imaxima-use-maxima-mode-flag t
       maxima-command "/home/tucker/usr/bin/maxima")


;;; Backup files
;; Put them in one nice place if possible
(if (file-directory-p "~/.backup")
    (setq backup-directory-alist '(("." . "~/.backup")))
  (message "Directory does not exist: ~/.backup"))
(setq backup-by-copying t    ; Don't delink hardlinks
      delete-old-versions t  ; Clean up the backups
      version-control t      ; Use version numbers on backups,
      kept-new-versions 3    ; keep some new versions
      kept-old-versions 2)   ; and some old ones
;;;Doremi
(eval-after-load "doremi-cmd"
  '(progn
     (unless (fboundp 'doremi-prefix)
       (defalias 'doremi-prefix (make-sparse-keymap))
       (defvar doremi-map (symbol-function 'doremi-prefix)
         "Keymap for Do Re Mi commands."))
     (define-key global-map [?\C-x ?t]  'doremi-prefix)
     (define-key doremi-map [?b] 'doremi-buffers+) ;Buffer
     (define-key doremi-map [?g] 'doremi-global-marks+) ;Global mark
     (define-key doremi-map [?h] 'doremi-frame-height+)
     (define-key doremi-map [?m] 'doremi-marks+) ;Mark
     (define-key doremi-map [?r] 'doremi-bookmarks+) ;'r' for Reading books
     (define-key doremi-map [?s] 'doremi-color-themes+) ;'s' for color Schemes
     (define-key doremi-map [?u] 'doremi-frame-configs+)   ; "Undo"
     (define-key doremi-map [?w] 'doremi-window-height+) ;Window
     (define-key doremi-map [?x] 'doremi-frame-horizontally+)
     (define-key doremi-map [?y] 'doremi-frame-vertically+)))
(require 'doremi)
(require 'doremi-cmd)
(require 'doremi-frm)
;;;Org Stuff
(setq org-todo-keywords
      '((sequence "TODO" "|" "DONE")
        (sequence "|" "CANCELED")
        (sequence "OPT" "|" "OPT(DONE)")
        (sequence "OPT(CANCELED)")))
;;(add-to-list 'org-src-lang-modes '("sml" . sml-mode))
;;Enable/Disable commands
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'overwrite-mode 'disabled t)
(put 'narrow-to-region 'disabled nil)
;;Iswitchb
(load "my-iswitchb.elc")
(iswitchb-mode)
;replaecment for package-desc-vers
;(funcall (if (fboundp 'package-desc-version)
;             'package--ac-desc-version
;           'package-desc-vers)
;         (cdr package)) 
(setq auto-insert-alist
 '((("SciLisp/src/.+\\.\\([hc]\\)\\'" . "SciLisp C File") .
    (lambda ()
      (insert (SciLisp-copyright (file-name-nondirectory buffer-file-name)))))
   (("\\.\\(sh\\|bash\\)\\'" . "Shell Script") .
    (lambda ()
      (insert (format "#!/bin/bash"))))))
(defadvice glasses-mode (before mode-specific-glasses
                                (&optional arg sep) activate compile)
  (unless (or
           (and (or (null arg)
                    (eq arg 'toggle))
                glasses-mode)
           (and (numberp arg) (> 0 arg)))
    (setq sep
          (if (null sep)
              (if (string-match "lisp\\|clojure\\|scheme" (symbol-name major-mode))
                  "-"
                "_")
            sep))
    (make-local-variable 'glasses-separator)
    (setq glasses-separator sep)
    (make-local-variable 'glasses-original-separator)
    (setq glasses-original-separator sep)
    (glasses-set-overlay-properties)))
          
