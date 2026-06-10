;;;; Git/VCS: magit -> legit, plus the custom jj/git smart dispatch
;;;; (vile-vcs-status) and git-gutter, mirroring init-evil.el.

(in-package :vile)

(defun jj-root ()
  (find-up (or (ignore-errors (buffer-directory (current-buffer)))
               (uiop:getcwd))
           ".jj"))

(define-command vile-jj-log () ()
  "Jujutsu status + log in a buffer (majutsu-lite)."
  (let ((root (jj-root)))
    (unless root
      (message "Not inside a jj repository")
      (return-from vile-jj-log))
    (stream-to-buffer
     (list "sh" "-c" "jj st --color=never; echo; jj log --color=never -n 30")
     "*vile-jj*"
     :directory root)))

(define-command vile-legit-status () ()
  "Open the legit status window (magit-status equivalent)."
  (uiop:symbol-call :lem/legit :legit-status))

(define-command vile-vcs-status () ()
  "Smart VCS dispatch: jj repo -> jj log view, otherwise legit (git)."
  (if (jj-root)
      (vile-jj-log)
      (vile-legit-status)))

;; Gutter diff indicators (git-gutter-mode on prog buffers in Emacs;
;; Lem's implementation is a global mode). Enabled after init: its
;; enable-hook walks existing buffers/windows.
(add-hook *after-init-hook*
          (lambda ()
            (ignore-errors
              (uiop:symbol-call :lem-git-gutter :git-gutter-mode t))))
