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
           
;; ;presumably this is how the default argument bit of the cl package works
