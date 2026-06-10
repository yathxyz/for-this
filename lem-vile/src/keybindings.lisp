;;;; The SPC leader map -- the muscle-memory core of the Emacs config
;;;; (general.el definitions from init-evil.el), bound via vi-mode's
;;;; Leader mechanism. Loaded last so every command already exists.
;;;; App modules (apps/*.lisp) bind their own leader chords next to their
;;;; commands; everything else is centralized here.

(in-package :vile)

(defmacro define-leader-keys (keymap &body bindings)
  `(progn
     ,@(loop :for (keys command) :in bindings
             :collect `(define-key ,keymap ,(concatenate 'string "Leader " keys)
                         ,command))))

;;; --- normal state -----------------------------------------------------------

(define-leader-keys lem-vi-mode:*normal-keymap*
  ;; files / buffers
  ("f f" 'find-file)                          ; SPC f f
  ("<" 'select-buffer)                        ; SPC <
  ("Space" 'vile-project-buffers)             ; SPC SPC (consult-project-buffer)
  ("b k" 'vile-kill-current-buffer)           ; SPC b k
  ("b f" 'vile-format-buffer)                 ; SPC b f (apheleia)
  ("b m" 'lem-bookmark::bookmark-set)         ; SPC b m
  ("Return" 'lem-bookmark::bookmark-jump)     ; SPC RET

  ;; project (project.el / consult)
  ("p f" 'project-find-file)                  ; SPC p f
  ("p g" 'lem/grep:project-grep)              ; SPC p g
  ("p p" 'project-switch)                     ; SPC p p
  ("p s" 'lem-lsp-mode::lsp-document-symbol)  ; SPC p s (consult-eglot-symbols)

  ;; git (magit / majutsu dispatch)
  ("g g" 'vile-vcs-status)                    ; SPC g g
  ("g G" 'vile-legit-status)                  ; SPC g G
  ("g J" 'vile-jj-log)                        ; SPC g J

  ;; LLM (gptel)
  ("g j" 'vile-llm-send)                      ; SPC g j (gptel-send)
  ("g l" 'vile-llm-ask)                       ; SPC g l (preset/handoff menu)
  ("g L" 'vile-llm-set-model)                 ; SPC g L (gptel-menu)

  ;; notes (org-roam / org-journal / org-capture)
  ("n r f" 'vile-roam-find)                   ; SPC n r f
  ("n r i" 'vile-roam-insert)                 ; SPC n r i
  ("n r a" 'vile-roam-random)                 ; SPC n r a
  ("n r d t" 'vile-dailies-today)             ; SPC n r d t
  ("n r d d" 'vile-dailies-date)              ; SPC n r d d
  ("n j j" 'vile-journal-new-entry)           ; SPC n j j
  ("o" 'vile-capture)                         ; SPC o

  ;; compile / eval
  ("c c" 'vile-compile)                       ; SPC c c
  ("m e e" 'lem-lisp-mode:lisp-eval-last-expression) ; SPC m e e

  ;; help (helpful)
  ("h k" 'apropos-command)                    ; SPC h k (helpful-callable)
  ("h K" 'describe-key)                       ; SPC h K (helpful-key)
  ("h b" 'describe-bindings)

  ;; navigation (avy / isearch)
  ("l" 'goto-line)                            ; SPC l (avy-goto-line)
  ("a" 'vile-snipe-forward)                   ; SPC a (avy-goto-char)
  ("s" 'lem/isearch:isearch-forward-symbol))  ; SPC s (avy-goto-symbol-1)

;;; --- visual state: the subset that operates on a selection ------------------

(define-leader-keys lem-vi-mode:*visual-keymap*
  ("g j" 'vile-llm-send)
  ("g l" 'vile-llm-ask)
  ("g g" 'vile-vcs-status))

;;; --- non-leader bindings ----------------------------------------------------

;; insert state: C-c i sends to the LLM (gptel-send from insert state)
(define-key lem-vi-mode:*insert-keymap* "C-c i" 'vile-llm-send)

;; normal state: C-c c opens Claude Code (claude-code-transient)
(define-key lem-vi-mode:*normal-keymap* "C-c c" 'lem-claude-code::claude-code)

;; globals from the `use-package emacs` block
(define-key *global-keymap* "M-o" 'next-window)        ; other-window
(define-key *global-keymap* "M-j" 'vile-duplicate-line) ; duplicate-dwim
(define-key *global-keymap* "M-s g" 'lem/grep:grep)    ; M-s g grep

;; keybindings.lisp is the system's last component; reaching here means the
;; whole port loaded.
(setf *boot-ok* t)
