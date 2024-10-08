;;; highlight-parentheses.el --- highlight surrounding parentheses
;;
;; Copyright (C) 2007, 2009, 2013 Nikolaj Schumacher
;;
;; Author: Nikolaj Schumacher <bugs * nschum de>
;; Version: 1.0.2
;; Keywords: faces, matching
;; URL: http://nschum.de/src/emacs/highlight-parentheses/
;; Compatibility: GNU Emacs 22.x, GNU Emacs 23.x, GNU Emacs 24.x
;;
;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; Add the following to your .emacs file:
;; (require 'highlight-parentheses)
;;
;; Enable the mode using M-x highlight-parentheses-mode or by adding it to a
;; hook.
;;
;;; Change Log:
;;
;;    Protect against double initialization (if used in `c-mode-hook').
;;
;; 2013-03-22 (1.0.2)
;;    Fixed bug causing last color not to be displayed.
;;
;; 2009-03-19 (1.0.1)
;;    Added setter for color variables.
;;
;; 2007-07-30 (1.0)
;;    Added background highlighting and faces.
;;
;; 2007-05-15 (0.9.1)
;;    Support for defcustom.
;;
;; 2007-04-26 (0.9)
;;    Initial Release.
;;
;;; Code:

(defgroup highlight-parentheses nil
  "Highlight surrounding parentheses"
  :group 'faces
  :group 'matching)

;; Another reasonable setting would be
;; (t (:inherit 'show-paren-match))
(defface hl-paren+1
  '((t (:foreground "firebrick1")))
  "Face to highlight inner-most enclosing parentheses."
  :group 'highlight-parentheses)

(defface hl-paren+2
  '((t (:foreground "indianred1")))
  "Face to highlight 2nd inner-most enclosing parentheses."
  :group 'highlight-parentheses)

(defface hl-paren+3
  '((t (:foreground "indianred3")))
  "Face to highlight 3rd inner-most enclosing parentheses."
  :group 'highlight-parentheses)

(defface hl-paren+4
  '((t (:foreground "indianred4")))
  "Face to highlight 4th inner-most enclosing parentheses."
  :group 'highlight-parentheses)

(defvar hl-paren-faces
  '(hl-paren+1 hl-paren+2 hl-paren+3 hl-paren+4)
  "List of faces use in highlight-parentheses.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar hl-paren-overlays nil
  "This buffers currently active overlays.")
(make-variable-buffer-local 'hl-paren-overlays)

(defvar hl-paren-last-point 0
  "The last point for which parentheses were highlighted.
This is used to prevent analyzing the same context over and over.")
(make-variable-buffer-local 'hl-paren-last-point)

(defun hl-paren-highlight ()
  "Highlight the parentheses around point."
  (unless (= (point) hl-paren-last-point)
    (setq hl-paren-last-point (point))
    (let ((overlays hl-paren-overlays)
          pos1 pos2
          (pos (point)))
      (save-excursion
        (condition-case err
            (while (and (setq pos1 (cadr (syntax-ppss pos1)))
                        (cdr overlays))
              (move-overlay (pop overlays) pos1 (1+ pos1))
              (when (setq pos2 (scan-sexps pos1 1))
                (move-overlay (pop overlays) (1- pos2) pos2)
                ))
          (error nil))
        (goto-char pos))
      (mapc 'delete-overlay overlays))))

;;;###autoload
(define-minor-mode highlight-parentheses-mode
  "Minor mode to highlight the surrounding parentheses."
  nil " hl-p" nil
  (mapc 'delete-overlay hl-paren-overlays)
  (kill-local-variable 'hl-paren-overlays)
  (kill-local-variable 'hl-paren-last-point)
  (remove-hook 'post-command-hook 'hl-paren-highlight t)
  (when highlight-parentheses-mode
    (hl-paren-create-overlays)
    (add-hook 'post-command-hook 'hl-paren-highlight nil t)))

;;;###autoload
(define-globalized-minor-mode global-highlight-parentheses-mode
  highlight-parentheses-mode
  highlight-parentheses-mode)

;;; overlays ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun hl-paren-create-overlays ()
  (dolist (face hl-paren-faces)
    (dotimes (twice 2)
      (let ((o (make-overlay 0 0)))
        (overlay-put o 'face face)
        (overlay-put o 'category 'highlight-parentheses-mode)
        (push o hl-paren-overlays))))
  (setq hl-paren-overlays (nreverse hl-paren-overlays)))

(provide 'highlight-parentheses)

;;; highlight-parentheses.el ends here
