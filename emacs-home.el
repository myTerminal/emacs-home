;;; emacs-home.el --- A home-screen for Emacs -*- lexical-binding: t; -*-

;; This file is not part of Emacs

;; Author: Mohammed Ismail Ansari <team.terminal@gmail.com>
;; Version: 1.0
;; Keywords: convenience, shortcuts
;; Maintainer: Mohammed Ismail Ansari <team.terminal@gmail.com>
;; Created: 2017/06/24
;; Package-Requires: ((emacs "24") (cl-lib "0.5")))
;; Description: A home-screen for Emacs
;; URL: http://ismail.teamfluxion.com
;; Compatibility: Emacs24


;; COPYRIGHT NOTICE
;;
;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2 of the License, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
;; for more details.
;;

;;; Install:

;; Put this file on your Emacs-Lisp load path and add the following to your
;; ~/.emacs startup file
;;
;;     (require 'emacs-home)
;;
;; Currently *emacs-home* supports the following widgets:
;;
;; 1. Date and Time
;; 2. Work-day progress
;; 3. Favorite files
;; 4. Favorite functions
;;
;; Set a key-binding to open the configuration menu that displays all configured
;; configurations.
;;
;;     (global-set-key (kbd "C-;") 'emacs-home-show)
;;
;; By default, only the date-time widget is shown. One needs to set a few
;; variables to see the rest of the widgets.
;;
;; To see the work-day progress widget, set the day start and end times. These
;; need to be set with numeric values in the format *hhmm*. Refer to the below
;; example.
;;
;;     (emacs-home-set-day-start-time 0800)
;;     (emacs-home-set-day-end-time 1700)
;;
;; If the current time is between the above two times, a progress bar is shown.
;;
;; To see the favorite files widget, use a snippet as shown below.
;;
;;     (emacs-home-set-favorite-files (list '("t" "~/to-do.org")
;;                                        '("i" "~/Documents/work.md")))
;;
;; To see the favorite functions widget, use a snippet as shown below.
;;
;;     (emacs-home-set-favorite-functions (list '("s" snake)
;;                                            '("c" calc)))
;;
;; While on the home screen, pressing `g` updates it and `q` closes it.
;;

;;; Commentary:

;;     You can use *emacs-home* as a home-screen to place shortcuts and view
;;     useful information about your day.
;;
;;  Overview of features:
;;
;;     o   Quickly open up a screen with useful information and shortcuts
;;

;;; Code:

(require 'cl-lib)

(defvar emacs-home--buffer-name
  " *emacs-home*")

(defvar emacs-home--refresh-timer
  nil)

(defvar emacs-home--data-day-start-time
  nil)

(defvar emacs-home--data-day-end-time
  nil)

(defvar emacs-home--data-favorite-files
  nil)

(defvar emacs-home--data-favorite-functions
  nil)

;;;###autoload
(defun emacs-home-set-day-start-time (time)
  (setq emacs-home--data-day-start-time
        time))

;;;###autoload
(defun emacs-home-set-day-end-time (time)
  (setq emacs-home--data-day-end-time
        time))

;;;###autoload
(defun emacs-home-set-favorite-files (files)
  (setq emacs-home--data-favorite-files
        files))

;;;###autoload
(defun emacs-home-set-favorite-functions (functions)
  (setq emacs-home--data-favorite-functions
        functions))

;;;###autoload
(defun emacs-home-show ()
  "Shows emacs home."
  (interactive)
  (cl-flet* ((print-date-and-time ()
                                  (insert (concat (propertize (format-time-string "%A, %d %B %Y")
                                                              'face
                                                              '(:height 2.0))
                                                  "\n\n"))
                                  (insert (concat (propertize (format-time-string "%H:%M:%S")
                                                              'face
                                                              '(:height 4.0 :inverse-video t))
                                                  "\n\n")))
             (get-day-progress ()
                               (let ((start-minutes (+ (* 60
                                                          (truncate (/ emacs-home--data-day-start-time
                                                                       100)))
                                                       (mod emacs-home--data-day-start-time
                                                            100)))
                                     (end-minutes (+ (* 60
                                                        (truncate (/ emacs-home--data-day-end-time
                                                                     100)))
                                                     (mod emacs-home--data-day-end-time
                                                          100)))
                                     (ellapsed-minutes (+ (* 60
                                                             (string-to-number (format-time-string "%H")))
                                                          (string-to-number (format-time-string "%M")))))
                                 (cond ((and (> end-minutes
                                                start-minutes)
                                             (>= ellapsed-minutes
                                                 start-minutes)
                                             (<= ellapsed-minutes
                                                 end-minutes)) (/ (* (- ellapsed-minutes
                                                                        start-minutes)
                                                 1.0)
                                             (- end-minutes
                                                start-minutes)))
                                       (t nil))))
             (print-day-progress ()
                                 (cond ((not (or (null emacs-home--data-day-start-time)
                                                 (null emacs-home--data-day-end-time)))
                                        (let ((day-progress-ratio (get-day-progress)))
                                          (insert (concat (make-string (window-width)
                                                                       ?*)
                                                          "\n"))
                                          (insert (concat (propertize (cond ((not (null day-progress-ratio))
                                                                             (make-string (truncate (* (window-width)
                                                                                                       day-progress-ratio))
                                                                                          ?*))
                                                                            (t "Outside working hours"))
                                                                      'face
                                                                      '(:inverse-video t))
                                                          "\n"))
                                          (insert (concat (make-string (window-width)
                                                                       ?*)
                                                          "\n"))))))
             (get-displayable-symbol (item)
                                     (cond ((symbolp item) (symbol-name item))
                                           (t item)))
             (display-controls-binding (object)
                                       (insert (concat (propertize (concat " "
                                                                           (nth 0
                                                                                object)
                                                                           " ")
                                                                   'face
                                                                   '(:height 1.5 :box t))
                                                       " "
                                                       (propertize (get-displayable-symbol (cadr object))
                                                                   'face
                                                                   '(:height 1.5))
                                                       "\n")))
             (print-favorite-files ()
                                   (cond ((not (null emacs-home--data-favorite-files))
                                          (progn
                                            (insert (concat "\n"
                                                            (propertize "Favorite files:" 'face '(:height 2.0 :underline t))
                                                            "\n\n"))
                                            (mapc #'display-controls-binding
                                                  emacs-home--data-favorite-files)))))
             (print-favorite-functions ()
                                       (cond ((not (null emacs-home--data-favorite-functions))
                                              (progn
                                                (insert (concat "\n"
                                                                (propertize "Favorite functions:" 'face '(:height 2.0 :underline t))
                                                                "\n\n"))
                                                (mapc #'display-controls-binding
                                                      emacs-home--data-favorite-functions)))))
             (apply-other-commands-bindings ()
                                            (local-set-key (kbd "g")
                                                           'home-redraw)
                                            (local-set-key (kbd "q")
                                                           (lambda ()
                                                             (interactive)
                                                             (home-hide))))
             (apply-favorite-file-binding (object)
                                          (local-set-key (kbd (car object))
                                                         (lambda ()
                                                           (interactive)
                                                           (home-hide)
                                                           (find-file (cadr object)))))
             (apply-favorite-files-bindings ()
                                           (mapc (lambda (object)
                                                   (funcall #'apply-favorite-file-binding
                                                            object))
                                                 emacs-home--data-favorite-files))
             (apply-favorite-function-binding (object)
                                              (local-set-key (kbd (car object))
                                                             (lambda ()
                                                               (interactive)
                                                               (home-hide)
                                                               (funcall (cadr object)))))
             (apply-favorite-functions-bindings ()
                                                (mapc (lambda (object)
                                                        (funcall #'apply-favorite-function-binding
                                                                 object))
                                                      emacs-home--data-favorite-functions))
             (render-controls ()
                              (with-current-buffer (get-buffer-create emacs-home--buffer-name)
                                (print-date-and-time)
                                (print-day-progress)
                                (print-favorite-files)
                                (print-favorite-functions)
                                (emacs-home-mode)
                                (apply-other-commands-bindings)
                                (apply-favorite-files-bindings)
                                (apply-favorite-functions-bindings)))
             (stop-timer ()
                         (cancel-timer emacs-home--refresh-timer))
             (home-hide ()
                        (let ((my-window (get-buffer-window (get-buffer-create emacs-home--buffer-name))))
                          (stop-timer)
                          (cond ((windowp my-window)
                                 (kill-buffer (get-buffer-create emacs-home--buffer-name))))))
             (home-redraw ()
                          (interactive)
                          (cond ((get-buffer emacs-home--buffer-name)
                                 (progn (with-current-buffer (get-buffer-create emacs-home--buffer-name)
                                          (fundamental-mode)
                                          (read-only-mode -1)
                                          (erase-buffer))
                                        (render-controls)))
                                (t (stop-timer)))))
  (cond ((get-buffer emacs-home--buffer-name) (home-hide))
        (t (let ((my-buffer (get-buffer-create emacs-home--buffer-name)))
             (set-window-buffer (get-buffer-window)
                                my-buffer)
             (render-controls)
             (setq emacs-home--refresh-timer
                   (run-with-timer 1
                                   1
                                   #'home-redraw)))))))

(define-derived-mode emacs-home-mode
  special-mode
  "emacs-home"
  :abbrev-table nil
  :syntax-table nil
  (setq cursor-type nil))

(provide 'emacs-home)

;;; emacs-home.el ends here
