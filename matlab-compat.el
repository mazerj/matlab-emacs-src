;;; matlab-compat.el --- Compatibility Code
;;
;; Copyright (C) 2019 Eric Ludlam
;;
;; Author: Eric Ludlam <eludlam@osboxes>
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see https://www.gnu.org/licenses/.

;;; Commentary:
;;
;; To support a wide range of different Emacs versions, these compat
;; functions will hide away the shims needed to work cross platform.

;;; Code:

(eval-and-compile
  (if (string-match "X[Ee]macs" emacs-version)
      (progn
        (defalias 'matlab-make-overlay 'make-extent)
        (defalias 'matlab-overlay-put 'set-extent-property)
        (defalias 'matlab-overlay-get 'extent-property)
        (defalias 'matlab-delete-overlay 'delete-extent)
        (defalias 'matlab-overlay-start 'extent-start-position)
        (defalias 'matlab-overlay-end 'extent-end-position)
        (defalias 'matlab-previous-overlay-change 'previous-extent-change)
        (defalias 'matlab-next-overlay-change 'next-extent-change)
        (defalias 'matlab-overlays-at
          (lambda (pos) (when (fboundp 'extent-list) (extent-list nil pos pos))))
        (defalias 'matlab-cancel-timer 'delete-itimer)
        (defun matlab-run-with-idle-timer (secs repeat function &rest args)
          (condition-case nil
              (apply 'start-itimer
                     "matlab" function secs
                     (if repeat secs nil) t
                     t (car args)))
	  (error
	   ;; If the above doesn't work, then try this old version of
	   ;; start itimer.
           (when (fboundp 'start-itimer)
             (start-itimer "matlab" function secs (if repeat secs nil)))))
        )
    ;; Else GNU Emacs
    (defalias 'matlab-make-overlay 'make-overlay)
    (defalias 'matlab-overlay-put 'overlay-put)
    (defalias 'matlab-overlay-get 'overlay-get)
    (defalias 'matlab-delete-overlay 'delete-overlay)
    (defalias 'matlab-overlay-start 'overlay-start)
    (defalias 'matlab-overlay-end 'overlay-end)
    (defalias 'matlab-previous-overlay-change 'previous-overlay-change)
    (defalias 'matlab-next-overlay-change 'next-overlay-change)
    (defalias 'matlab-overlays-at 'overlays-at)
    (defalias 'matlab-cancel-timer 'cancel-timer)
    (defalias 'matlab-run-with-idle-timer 'run-with-idle-timer)
    ))

;;; Helper aliases to suppress compiler warnings ===============================

(eval-and-compile
  ;; `set-face-underline-p' is an obsolete function (as of 24.3); use `set-face-underline' instead.
  (cond ((fboundp 'set-face-underlined)
         (defalias 'matlab-set-face-underline 'set-face-underlined))
        (t
         (defalias 'matlab-set-face-underline 'set-face-underline-p)))

  ;; `set-face-bold-p' is an obsolete function (as of 24.4); use `set-face-bold' instead.
  (cond ((fboundp 'set-face-bold)
         (defalias 'matlab-set-face-bold 'set-face-bold))
        (t
         (defalias 'matlab-set-face-bold 'set-face-bold-p)))

  ;; `default-fill-column' is an obsolete variable (as of 23.2); use `fill-column' instead.
  (cond ((boundp 'fill-column)
         (defvaralias 'matlab-fill-column 'fill-column))
        (t
         (defvaralias 'matlab-fill-column 'default-fill-column)))

  ;; `interactive-p' is an obsolete function (as of 23.2); use `called-interactively-p' instead.
  (defun matlab-called-interactively-p-helper ()
    (called-interactively-p 'interactive))
  (cond ((fboundp 'called-interactively-p)
         (defalias 'matlab-called-interactively-p 'matlab-called-interactively-p-helper))
        (t
         (defalias 'matlab-called-interactively-p 'interactive-p)))

  ;; `toggle-read-only' is an obsolete function (as of 24.3); use `read-only-mode' instead.
  ;; (matlab-read-only-mode -1) ==> make writable
  ;; (matlab-read-only-mode 1) ==> make read-only
  (cond ((fboundp 'read-only-mode)
         (defalias 'matlab-read-only-mode 'read-only-mode))
        (t
         (defalias 'matlab-read-only-mode 'toggle-read-only)))

  (cond ((fboundp 'point-at-bol)
         (defalias 'matlab-point-at-bol 'point-at-bol)
         (defalias 'matlab-point-at-eol 'point-at-eol))
        ;; Emacs 20.4
        ((fboundp 'line-beginning-position)
         (defalias 'matlab-point-at-bol 'line-beginning-position)
         (defalias 'matlab-point-at-eol 'line-end-position))
        (t
         (defmacro matlab-point-at-bol ()
           (save-excursion (beginning-of-line) (point)))
         (defmacro matlab-point-at-eol ()
           (save-excursion (end-of-line) (point)))))
  )



(provide 'matlab-compat)

;;; matlab-compat.el ends here
