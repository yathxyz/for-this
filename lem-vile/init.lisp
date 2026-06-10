;;;; Entry point, loaded from ~/.config/lem/init.lisp.
;;;; Loads the VILE system and records boot status so the TUI test harness
;;;; can assert on it from `lem --eval`.

(in-package :lem-user)

(defvar *vile-root*
  (uiop:pathname-directory-pathname *load-truename*))

(defvar *vile-boot-error* nil
  "NIL on a clean boot, otherwise the load-time error message.")

(handler-case
    (progn
      (asdf:load-asd (merge-pathnames "vile.asd" *vile-root*))
      (asdf:load-system "vile"))
  (error (e)
    (setf *vile-boot-error* (princ-to-string e))
    (ignore-errors (message "VILE failed to load: ~a" e))))
