;;;; Project tools: compile (SPC c c), project buffer switching (SPC SPC),
;;;; duplicate-dwim (M-j).

(in-package :vile)

(define-command vile-compile () ()
  "Prompt for a shell command and stream its output into *compilation*.
Runs from the project root; the worker runs on a background thread."
  (let* ((dir (or (ignore-errors
                    (lem-core/commands/project:find-root
                     (buffer-directory (current-buffer))))
                  (ignore-errors (buffer-directory (current-buffer)))
                  (user-homedir-pathname)))
         (command (prompt-for-string (format nil "Compile [~a]: " dir)
                                     :history-symbol 'vile-compile)))
    (when (plusp (length command))
      (stream-to-buffer (list "sh" "-c" command) "*compilation*"
                        :directory dir))))

(define-command vile-project-buffers () ()
  "Switch among buffers of the current project (consult-project-buffer)."
  (let* ((root (ignore-errors
                 (namestring
                  (lem-core/commands/project:find-root
                   (buffer-directory (current-buffer))))))
         (names (loop :for b :in (buffer-list)
                      :for file := (buffer-filename b)
                      :when (and file root
                                 (alexandria:starts-with-subseq
                                  root (namestring file)))
                        :collect (buffer-name b))))
    (unless names
      (message "No file buffers in this project")
      (return-from vile-project-buffers))
    (let ((choice (prompt-for-string
                   "Project buffer: "
                   :completion-function (lambda (s) (orderless-filter s names))
                   :test-function (lambda (s) (member s names :test #'string=)))))
      (when choice
        (switch-to-buffer (get-buffer choice))))))

(define-command vile-kill-current-buffer () ()
  "Kill the current buffer without prompting (kill-current-buffer)."
  (kill-buffer (current-buffer)))

(define-command vile-duplicate-line () ()
  "Duplicate the current line below (duplicate-dwim approximation)."
  (with-point ((p (current-point)))
    (let ((text (line-string p)))
      (line-end p)
      (insert-string p (format nil "~%~a" text)))))
