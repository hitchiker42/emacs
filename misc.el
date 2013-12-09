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
  (sort-regexp-fields reverse "\\(\\w+\\)" "\\1" start end))
;;move a buffer between windows
;;essentially swap two buffers between windows determined by direction
(lexical-let
    ((my-windmove-window-select 
      (lambda (dir &optional arg window)
        (let ((other-window (windmove-find-other-window dir arg window)))
          (cond ((null other-window)
                 (error "No window %s from selected window" dir))
                ((window-minibuffer-p other-window)
                 (error 
                  "Window %s from selected window is a Minibuffer window"))
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
