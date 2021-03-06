;;; asm-mode.el --- mode for editing assembler code

;; Copyright (C) 1991, 2001-2014 Free Software Foundation, Inc.

;; Author: Tucker DiNapoli
;; Original Author: Eric S. Raymond <esr@snark.thyrsus.com>
;; Keywords: tools, languages

;; This file is NOT part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; My asm mode modified from the original emacs asm mode
;; Originally was written by Eric S. Raymond <esr@snark.thyrsus.com>,
;; inspired by an earlier asm-mode by Martin Neitzel.

;; This minor mode is based on text mode.  It defines a private abbrev table
;; that can be used to save abbrevs for assembler mnemonics.  It binds just
;; five keys:
;;
;;	TAB		tab to next tab stop
;;	:		outdent preceding label, tab to tab stop
;;	comment char	place or move comment
;;			asm-comment-char specifies which character this is;
;;			you can use a different character in different
;;			Asm mode buffers.
;;
;; Code is indented to the first tab stop level.

;; This mode runs two hooks:
;;   1) An asm-mode-set-comment-hook before the part of the initialization
;; depending on asm-comment-char, and
;;   2) an asm-mode-hook at the end of initialization.

;;; Code:

(defgroup my-asm nil
  "Mode for editing assembler code."
  :link '(custom-group-link :tag "Font Lock Faces group" font-lock-faces)
  :group 'languages)

(defvar my-asm-comment-start "/*")
(defvar my-asm-comment-end "*/")
(defvar my-asm-comment-chars '(?#))

(defvar my-asm-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?\n "> b" st)
    (modify-syntax-entry ?/  ". 124b" st)
    (modify-syntax-entry ?*  ". 23" st)
    st)
  "Syntax table used while in Asm mode.")

(defvar my-asm-mode-abbrev-table nil
  "Abbrev table used while in Asm mode.")
(define-abbrev-table 'asm-mode-abbrev-table ())

(defvar my-asm-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map ":"		'asm-colon)
    (define-key map "\C-c;"	'comment-region)
    (define-key map "\C-j"	'newline)
    (define-key map "\C-m"	'newline)
    (define-key map [menu-bar asm-mode] (cons "Asm" (make-sparse-keymap)))
    map)
  "Keymap for Asm mode.")
(defvar numeric-literal
  (string-join "\\|"
  "\\(-?\\(0[bB][01]+\\|0[xX][[:xdigit:]]+\\|0[0-8]+\\|[1-9][0-9]*\\)\\)";int
  "\\(0[eEfF][+-]?\\([0-9]+\\.?[0-9]*\\|[0-9]*\\.[0-9]+\\)\\(?:[eE][+-]?[0-9]+\\)?\\)"))
(defconst asm-font-lock-keywords
  (append
   '(("^\\(\\(\\sw\\|\\s_\\)+\\)\\>:?[ \t]*\\(\\(\\sw\\|\\s_\\)+\\(\\.\\sw+\\)*\\)?"
      (1 font-lock-function-name-face) (3 font-lock-keyword-face nil t))
     ("^\\.macro[ \t]*\\(\\(\\sw\\|\\s_\\)+\\)"
      (1 font-lock-function-name-face))
     ;; label started from ".".
     ("^\\(\\.\\(\\sw\\|\\s_\\)+\\)\\>:"
      1 font-lock-function-name-face)
     ("^\\((\\sw+)\\)?\\s +\\(\\(\\.?\\sw\\|\\s_\\)+\\(\\.\\sw+\\)*\\)"
      2 font-lock-keyword-face)
     ;; directive started from ".".
     ("^\\(\\.\\(\\sw\\|\\s_\\)+\\)\\>[^:]?"
      1 font-lock-keyword-face)
     ;; %register
     ("%\\sw+" . font-lock-variable-name-face))
   cpp-font-lock-keywords)
  "Additional expressions to highlight in Assembler mode.")

;;;###autoload
(define-derived-mode my-asm-mode prog-mode "Assembly"
  "Major mode for editing x86_64 assembly code.
Features a private abbrev table and the following bindings:

\\[asm-colon]\toutdent a preceding label, tab to next tab stop.
\\[tab-to-tab-stop]\ttab to next tab stop.
\\[asm-newline]\tnewline, then tab to next tab stop.
\\[asm-comment]\tsmart placement of assembler comments.

The character used for making comments is set by the variable
`asm-comment-char' (which defaults to `?\\;').

Alternatively, you may set this variable in `asm-mode-set-comment-hook',
which is called near the beginning of mode initialization.

Turning on Asm mode runs the hook `asm-mode-hook' at the end of initialization.

Special commands:
\\{asm-mode-map}"
  (setq local-abbrev-table asm-mode-abbrev-table)
  (set (make-local-variable 'font-lock-defaults) '(asm-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'asm-indent-line)
  ;; Stay closer to the old TAB behavior (was tab-to-tab-stop).
  (set (make-local-variable 'tab-always-indent) nil)
  (electric-indent-mode -1)
  ;; Make our own local child of asm-mode-map
  ;; so we can define our own comment character.
  (use-local-map (nconc (make-sparse-keymap) asm-mode-map))
  (local-set-key (vector asm-comment-char) 'asm-comment)
  (set-syntax-table (make-syntax-table asm-mode-syntax-table))
  (dolist (comment-char my-asm-comment-chars) 
    (modify-syntax-entry comment-char "< b"))
  (set (make-local-variable 'comment-start) my-asm-comment-start)
  (set (make-local-variable 'comment-start-skip)
       "\\(//+\\|/\\*+\\)\\s *")
  (set (make-local-variable 'comment-end) my-asm-comment-end))

(defun asm-indent-line ()
  "Auto-indent the current line."
  (interactive)
  (let* ((savep (point))
	 (indent (condition-case nil
		     (save-excursion
		       (forward-line 0)
		       (skip-chars-forward " \t")
		       (if (>= (point) savep) (setq savep nil))
		       (max (asm-calculate-indentation) 0))
		   (error 0))))
    (if savep
	(save-excursion (indent-line-to indent))
      (indent-line-to indent))))

(defun asm-calculate-indentation ()
  (or
   ;; Flush labels to the left margin.
   (and (looking-at "\\(\\sw\\|\\s_\\)+:") 0)
   ;; Same thing for `;;;' comments.
   (and (looking-at "\\s<\\s<\\s<") 0)
   ;; Simple `;' comments go to the comment-column.
   (and (looking-at "\\s<\\(\\S<\\|\\'\\)") comment-column)
   ;; The rest goes at the first tab stop.
   (or (car tab-stop-list) tab-width)))

(defun asm-colon ()
  "Insert a colon; if it follows a label, delete the label's indentation."
  (interactive)
  (let ((labelp nil))
    (save-excursion
      (skip-syntax-backward "w_")
      (skip-syntax-backward " ")
      (if (setq labelp (bolp)) (delete-horizontal-space)))
    (call-interactively 'self-insert-command)
    (when labelp
      (delete-horizontal-space)
      (tab-to-tab-stop))))

(provide 'my-asm-mode)

;;; my-asm-mode.el ends here
