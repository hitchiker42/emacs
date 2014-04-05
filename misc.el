;; -*- lexical-binding: t; -*-

(defun indent-buffer ()
  "Indent entire buffer using indent-region"
  (interactive)
  (indent-region (point-min) (point-max)))

(defun quote-region (start end &optional quote-char)
  "quote the region defined by start and end using quote-char"
  (interactive "r")
(let ((quote (if (null quote-char) ?\" quote-char))
      (start (min start end))
      (end (max start end)))
  (if (or (use-region-p)
          (not (equal start end)))
    (save-excursion
      (insert quote)
      (goto-char (1+ end))
      (insert quote)))))

(defun make-scratch (mode &optional name switch)
"create a scratch buffer with major mode mode,
if optional argument name is given the buffer will be named name
otherwise the buffer will be named *modename-scratch*, where modename is
the name of mode with any -mode suffix removed"
  (interactive "amode:\ni\np")
  (let ((name 
         (if (null name) 
             (replace-regexp-in-string "-?mode" ""
                                       (format "*%s-scratch*" mode))
           name)))
    (with-current-buffer (generate-new-buffer name)
      (funcall mode))
  (if (not (null switch))
      (switch-to-buffer name))))

(defun find-files (files)
"open multiple files at once, flatten nested lists by one level
 if need be (kludge to make this work in eshell)"
  (dolist (i files) 
    (if (listp i)
        (dolist (j i)
          (find-file j))
      (find-file i))))


(defmacro as-command (fun &rest args)
"return a fun as a command to be called interactively
mainly used to call a non interactive elisp function interactively

function is called with arguments args, interactive spec is always nil"
(if (commandp fun)
    'fun
  `(lambda () (interactive) (,fun ,@args))))
(defun re-search-line-forward (re &optional no-error count)
  (re-search-forward re (save-excursion (end-of-line)(point))
                     no-error count))
(defun re-search-line-backward (re &optional no-error count)
  (re-search-backward re (save-excursion (beginning-of-line)(point))
                     no-error count))
(defun replace-regexp-lisp (from-string to-string &optional bound)
"lisp code emulating the behavior of replace-regexp, but without
altering the mark or printing anything."
  (while (re-search-forward from-string bound t)
    (replace-match to-string nil nil)))
(defun princ-line (val)
  (insert "\n")
  (princ val (current-buffer)))
(defun display-buffer-temporarily
  (buffer-or-name &optional action frame time kill)
  (let ((display-window
         (display-buffer buffer-or-name action frame)))
    (if (not time)
        (setq time 2.5))
    (if kill
        (run-with-timer time nil 
                        (lambda (buf win) 
                          (progn (kill-buffer buf)(delete-window win)))
                        buffer-or-name display-window)
      (run-with-timer time nil #'switch-to-prev-buffer display-window))))
(defun display-buffer-temporarily-and-kill
  (buffer-or-name &optional action frame time)
  (let* ((split-height-threshold nil) 
         (split-width-threshold nil)
         (display-buffer-overriding-action
         '(display-buffer-pop-up-window )))
  (funcall #'display-buffer-temporarily
           buffer-or-name display-buffer-overriding-action frame time t)))
;;needs some work, but its almost there
;; (defvar thing-at-point-function-argument-chars "-[:alnum:]!?$%^&*\<>._="
;;   "characters allowed in a function argument, specifically a lisp argument")
;; (defvar whitespace-allowed-in-function-argument nil) ;
;; (intern "function-argument")

;; (defun end-of-function-argument ()
;;   (let ((function-argument-chars 
;;          (concat thing-at-point-function-argument-chars
;;                  (if whitespace-allowed-in-function-argument
;;                      " \t\n"
;;                    ""))))
;;     (re-search-forward (concat "\\=[" function-argument-chars "]*")
;;                        nil t)))
;; (defun beginning-of-function-argument ()
;;   (let ((function-argument-chars 
;;          (concat thing-at-point-function-argument-chars
;;                  (if whitespace-allowed-in-function-argument
;;                      " \t\n"
;;                    ""))))
;;     (re-search-backward (concat "\\=[" function-argument-chars "]*")
;;                         nil t)))
;; (defun forward-function-argument (x)       
;;        (if (< x 0) 
;;            (beginning-of-function-argument)
;;          (end-of-function-argument)))
;; (put 'function-argument 'end-op #'end-of-function-argument)
;; (put 'function-argument 'beginning-op #'beginning-of-function-argument)
;; (put 'function-argument 'forward-op #'forward-function-argument)
;; (defun transpose-function-arguments (arg &optional whitespace-allowed)
;;   (let ((whitespace-allowed-in-function-argument
;;          (if whitespace-allowed
;;              t
;;            nil)))
;;     (transpose-subr 'forward-function-argument arg)))
(defun sort-words (start end &optional reverse)
  (interactive "r\nP")
  (sort-regexp-fields reverse "\\([[:word:][:punct:]]+\\)" "\\1" start end))
;;move a buffer between windows
;;essentially swap two buffers between windows determined by direction
(let
    ((my-windmove-window-select 
      (lambda (dir &optional arg window)
        (let ((other-window (windmove-find-other-window dir arg window)))
          (cond ((null other-window)
                 (error "No window %s from selected window" dir))
                ((window-minibuffer-p other-window)
                 (error 
                  "Window %s from selected window is a Minibuffer window" dir))
                (t
                 (select-window other-window)))))))
  (defun windswap (dir)
    (let* 
        ((old-window (selected-window))
         (new-window (funcall my-windmove-window-select dir nil old-window))
         (old-buffer (window-buffer old-window))
         (new-buffer (window-buffer new-window)))
      (set-window-buffer old-window new-buffer)
      (set-window-buffer new-window old-buffer)
      (select-window new-window))))
(defun windswap-up () (interactive) (windswap 'up))
(defun windswap-down () (interactive) (windswap 'down))
(defun windswap-left () (interactive) (windswap 'left))
(defun windswap-right () (interactive) (windswap 'right))

;; (define-key global-map [?\M-P] 'windswap-up)
;; (define-key global-map [?\M-N] 'windswap-down)
;; (define-key global-map [?\M-B] 'windswap-left)
;; (define-key global-map [?\M-F] 'windswap-right)
;; not sure exactily where to put this all, but this should
;; make eshell's history work normally
;; but eshell seems hell bent on having a circular history so this
;; still needs some work
;; Ok I think I need to just rewrite the history module
(defun my-eshell-previous-input (arg)
  (interactive "*p")
  (if (> 0 arg)
      (my-eshell-next-input (abs arg))
    (if (>= 0 
            (- (mod (1- eshell-history-index)
                    (ring-length eshell-history-ring)) arg))
        (progn 
          (delete-region eshell-last-output-end (point))
          (insert-and-inherit (ring-ref eshell-history-ring 0)))
      (eshell-previous-input arg))))
(defun my-eshell-next-input (arg)
  (interactive "*p")
  (if (> 0 arg)
      (my-eshell-previous-input (abs arg))
    (if (<= (ring-length eshell-history-ring)
            (+ (mod (1- eshell-history-index)
                    (ring-length eshell-history-ring)) arg))
        (delete-region eshell-last-output-end (point))
      (eshell-next-input arg))))
(defmacro if-graphical (&rest exprs)
  `(if (display-graphic-p)
       (progn ,@exprs)))
(defmacro if-terminal (&rest exprs)
  `(if (not (display-graphic-p))
       (progn ,@exprs)))
(defalias 'if-display-graphic-p 'if-graphical)
(defun fontify-frame (frame font)
  (interactive "i\ns")
  (set-frame-parameter frame 'font font))
(defun fontify-frame-default (frame)
  (interactive "i")
  (if-graphical
      (fontify-frame frame default-font)))
(defun fontify-frame-default-11 (frame)
  (interactive "i")
  (if-graphical
      (fontify-frame frame default-font-11)))
(defun resize-frame (frame height width)
  (set-frame-parameter frame 'height height)
  (set-frame-parameter frame 'width width))
(defun resize-frame-default (frame)
  (interactive "i")
  (if-graphical
   (resize-frame frame (cdr default-frame-size) (car default-frame-size))))
(defun SciLisp-copyright (filename &optional description)
  (format 
  "/* %s
              
   Copyright (C) 2014 Tucker DiNapoli

   This file is part of SciLisp.

   SciLisp is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   SciLisp is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with SciLisp.  If not, see <http://www.gnu.org*/
" (if (null description) filename description)))
(defun split-window-quarters (&optional place buffer1 buffer2 buffer3)
  "split the current window into quarters, optionally specifiy in what window
to leave as the current window, one of :upper-left :upper-right :lower-left or 
:lower-right, the default is upper-right"
  (interactive)
  (let ((initial-buf (current-buffer )))
    (split-window nil nil t);split horosontaly
    (split-window)
    (other-window 2)
    (split-window)
    (pcase place
      (:upper-left (other-window 2))
      (:lower-right (other-window 3))
      (:lower-left (other-window 1)))
    (switch-to-buffer initial-buf)))
    
        
(define-generic-mode 'ebnf-mode
  '(("(*" . "*)"))
  '("=" "::=")
  '(("^[^ \t\n][^=]+" . font-lock-variable-name-face)
    ("#?['\"].*?['\"]" . font-lock-string-face)
    ("\\?.*\\?" . font-lock-negation-char-face)
    ("\\[\\|\\]\\|{\\|}\\|(\\|)\\||\\|,\\|;" . font-lock-type-face)
    ("[^ \t\n]" . font-lock-function-name-face))
  '("\\.ebnf\\'")
  `(,(lambda () (setq mode-name "EBNF")))
  "Major mode for EBNF metasyntax text highlighting.")

(defun zap-up-to-char (arg char)
  "Kill up to, but not including ARGth occurrence of CHAR.
Case is ignored if `case-fold-search' is non-nil in the current buffer.
Goes backward if ARG is negative; error if CHAR not found.
Ignores CHAR at point."
  (interactive "p\ncZap up to char: ")
  (let ((direction (if (>= arg 0) 1 -1)))
    (kill-region (point)
		 (progn
		   (forward-char direction)
		   (unwind-protect
		       (search-forward (char-to-string char) nil nil arg)
		     (backward-char direction))
		   (point)))))
(defun string-join (sep &rest strings)
  "concatenate strings inserting sep between each string so
(string-join \"-\" \"foo\" \"bar\" \"baz\") returns \"foo-bar-baz\""
  (mapconcat 'identity strings sep))
(defun matches-regex-p (regexp string)
  "return t if the entirety of string is matched by regexp otherwise return nil.
doesn't modify the match data"
  (save-match-data 
    (if (zerop (string-match regexp string))
        (if (eq (length string) (match-end 0))
            t)
      nil)))
;;if this proves useful I should add options for dealing with case
(defun un-camel-case (&optional string)
  "change camel case words into words seperated by underscores,
so that unCamelCase becomes un_camel_case"
  ;;Also multiple consuctive caps don't get downcased
  ;;(i.e unCAMELCase->un_CAMEL_case)
  (interactive "i")
  (if (null string)
      (save-excursion
        ;;move point to the begining of the next/current word
        (cond
         ((looking-at-p "\\<[a-zA-Z]") t)
         ((looking-at-p "\\>\\|[a-zA-Z]") (backward-word))
         ((looking-at-p " ") (forward-whitespace 1)))
        (let ((bound (prog2 (forward-word) (point) (backward-word)))
              (case-fold-search nil))
          (while (re-search-forward
                  "[a-z]\\([A-Z]\\)\\(?:\\([A-Z]+\\)\\|[a-z]\\)" bound t)
            (goto-char (match-beginning 1))
            (insert "_")
            (if (match-string 2)
                (progn
                  (goto-char (match-end 2))
                  (insert "_")))
              (insert (downcase (char-after)))
              (delete-char 1)))
        nil)))
;; (define-erc-module ring nil
;;   "Stores input in a ring so that previous commands and messages can
;; be recalled using M-p and M-n."
;;   ((add-hook 'erc-send-pre-hook 'erc-add-to-input-ring)
;;    (define-key erc-mode-map [(C-up)] 'erc-previous-command)
;;    (define-key erc-mode-map [(C-down)] 'erc-next-command))
;;   ((remove-hook 'erc-send-pre-hook 'erc-add-to-input-ring)
;;    (define-key erc-mode-map [(C-up)] 'undefined)
;;    (define-key erc-mode-map [(C-down)] 'undefined)))
(defun update-tags (&optional directory)
  (interactive "DTAGS directory: ")
  (when (null directory)
    (setq directory (file-name-directory (buffer-file-name))))
  (apply #'async-start-process "etags" "etags"
         (lambda (&rest args) (message "Finished updating TAGS")) "-R"
         (directory-files directory t "^[^#.]+")))
(defun find-file-upwards (file-to-find)
  "Recursively searches each parent directory starting from the default-directory.
looking for a file with name file-to-find.  Returns the path to it
or nil if not found."
  (cl-labels
      ((find-file-r (path)
                    (let* ((parent (file-name-directory path))
                           (possible-file (concat parent file-to-find)))
                      (cond
                       ((file-exists-p possible-file) possible-file) ; Found
                       ;; The parent of ~ is nil and the parent of / is itself.
                       ;; Thus the terminating condition for not finding the file
                       ;; accounts for both.
                       ((or (null parent) (equal parent (directory-file-name parent))) nil) ; Not found
                       (t (find-file-r (directory-file-name parent))))))) ; Continue
    (find-file-r default-directory)))
(defun update-tags-table ()
  (interactive)
  (let ((my-tags-file (find-file-upwards "TAGS")))
    (if my-tags-file
        (visit-tags-table my-tags-file)
      (update-tags (file-name-directory (buffer-file-name)))
      (visit-tags-table "TAGS"))))
(provide 'tucker-misc)
