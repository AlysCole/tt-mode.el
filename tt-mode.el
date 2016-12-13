;;; tt-mode.el --- Syntax highlighting for tintin files.

;; Author: Alyssa Alvarez <alyscole@yandex.com>
;; Maintainer: Alyssa Alvarez <alyscole@yandex.com>
;; Created: December 9, 2016

;; Version: 0.1
;; Package-Requires: ((Emacs "24"))
;; Keywords: tintin, languages

;;; Commentary:
;; tt-mode.el is a simple major mode script for the scripting language TINTIN,
;; which is used in various MUD clients.

;;; Code:
(defvar tt-mode-hook nil)

(defvar tt-mode-map nil
  "Keymap for the `tt-mode'.")

(progn
  (setq tt-mode-map (make-keymap))
  (define-key tt-mode-map (kbd "C-j") 'newline-and-indent))

(add-to-list 'auto-mode-alist
             '("\\.tin\\'" . tt-mode)
             '("\\.tt\\'" . tt-mode))

;;; Syntax highlighting
(defvar tt-font-lock-keywords
  (list
   ;; Comments
   '("\\(#\\(?:N\\(?:OP\\|op\\|[Oo]\\)\\|nop?\\) *\\({.+}\\|.+\\)\;?\\)" . font-lock-comment-face)
   ;; Variable names
   '("\\([$%&]\\{1,2\\}[a-zA-Z_0-9?\.+*][a-zA-Z0-9_]*\\)" . font-lock-variable-name-face)
   ;; Variable definitions
   '("\\(?:#[Vv]\\(?:[Aa]\\|[Aa][Rr]\\|[Aa][Rr][Ii]\\|[Aa][Rr][Ii][Aa]\\|[Aa][Rr][Ii][Aa][Bb]\\|[Aa][Rr][Ii][Aa][Bb][Ll]\\|[Aa][Rr][Ii][Aa][Bb][Ll][Ee]\\)?\\) +\\([a-zA-Z_][a-zA-Z0-9_]*\\|{[a-zA-Z_][a-zA-Z0-9_ ]*}\\)\\(?: [\t\n ]\\| \\)\\([ \t]*{.+}\\|.+\\)"
     (1 font-lock-variable-name-face)
     (2 font-lock-string-face))
   ;; User function names
   '("\\(@[a-zA-Z_][a-zA-Z0-9_]*\\)" . font-lock-function-name-face)
   ;; Function definitions
   '("#[Ff][Uu]\\(?:[Nn]\\|[Nn][Cc]\\|[Nn][Cc][Tt]\\|[Nn][Cc][Tt][Ii]\\|[Nn][Cc][Tt][Ii][Oo]\\|[Nn][Cc][Tt][Ii][Oo][Nn]\\)?[ \t\n]+\\([a-zA-Z_][a-zA-Z0-9_]*\\|{[a-zA-Z_][a-zA-Z0-9_]*}\\)\\([ \t\n]\\| .?\\)"
     (1 font-lock-function-name-face))
   ;; Conditionals
   '("#\\([Ii][Ff]\\|[Ee][Ll][Ss][Ee]\\([Ii][Ff]\\)?\\|[Ss][Ww][Ii][Tt][Cc][Hh]\\|[Cc][Aa][Ss][Ee]\\)" . font-lock-keyword-face)
   ;; Commands
   '("\\(#[a-zA-Z]+\\)" . font-lock-keyword-face)
   ;; Color expressions
   '("\\(<\\([0-9]\\{3\\}\\|[a-fA-F]\\{3\\}\\|[gG][0-9]\\{2\\}\\)>\\)" . font-lock-comment-face)
   ;; Escape codes
   '("\\(\\\\\\([a-z]\\|[a-z]7[BD]\\)\\)" . font-lock-comment-face))
  "Default syntax highlighting for TinTin++ major mode.")

;;; Indentation

(defun tt-indent-line ()
  "Indent current line as TinTin++ code."
  (interactive)
  (beginning-of-line)
  ;; Check if at the beginning of file
  (if (bobp)
      ;; Indent to 0
      (indent-line-to 0)
    (let ((not-indented t) cur-indent)
      ;; Check if at the end of a block
      (if (looking-at "^[ \t]*};?")
          (progn
            (save-mark-and-excursion
             ;; Set indentation to previous line's minus tab-width
              (forward-line -1)
              (setq cur-indent (- (current-indentation) tab-width))
              (if (< cur-indent 0)
                  (setq cur-indent 0))))
        (save-mark-and-excursion
          (while not-indented
            (forward-line -1)
            ;; Check if the previous line is the end of a block
            (if (looking-at "^[ \t]*[};]")
                (progn
                  ;; Copy indentation of previous line
                  (setq cur-indent (current-indentation))
                  (setq not-indented nil))
              ;; Check if the previous line is a command
              (if (looking-at "^[ \t]*#?.*;$")
                  (progn
                    ;; Copy indentation over
                    (setq cur-indent (current-indentation))
                    (setq not-indented nil))
                ;; If the previous line is the beginning of a block
                (if (looking-at ".*{$")
                    (progn
                      ;; Set indentation to previous line's plus tab-width
                      (setq cur-indent (+ (current-indentation) tab-width))
                      (setq not-indented nil))
                  ;; End if we reach the beginning of buffer
                  (if (bobp)
                      (setq not-indented nil))))))))
      (if cur-indent
          (progn
            (indent-line-to cur-indent))
        (progn
          (indent-line-to 0)))))
  )

;;; Syntax table

(defvar tt-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?# "w" st)
    (modify-syntax-entry ?\; "." st)
    (modify-syntax-entry ?\" "w" st)
    (modify-syntax-entry ?{ "(}" st)
    (modify-syntax-entry ?} "){" st)
    st)
  "Syntax table for TinTin++ major mode.")

;;;### autoload
(defun tt-mode ()
  "Major mode for TinTin++ scripts."
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table tt-mode-syntax-table)
  (use-local-map tt-mode-map)
  (setq-local font-lock-defaults '(tt-font-lock-keywords))
  (setq-local indent-line-function 'tt-indent-line)
  (setq major-mode 'tt-mode)
  (setq mode-name "TinTin++")
  (run-hooks 'tt-mode-hook))


(provide 'tt-mode)

;;; tt-mode.el ends here
