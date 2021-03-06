;;;  -*- lexical-binding: t; -*-

;; %CopyrightBegin%
;;
;; Copyright Kjell Winblad (http://winsh.me, kjellwinblad@gmail.com)
;; 2019. All Rights Reserved.
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
;;
;; %CopyrightEnd%


(require 'yaemep)


(defun yaemep-help ()
  "Show YAEMEP help"
  (interactive)
  (with-output-to-temp-buffer "*YAEMEP Help*"
    (princ
     (with-temp-buffer
       (insert-file-contents
        (concat (file-name-as-directory (file-name-directory
                                         (locate-file "yaemep.el" load-path)))
                "README.md"))
       (buffer-string)))))

(defun yaemep-menu-error-info ()
  "Explain why YAMEP does not work"
  (interactive)
    (with-output-to-temp-buffer "*YAEMEP Error! why?*"
    (princ
     (format "

YAEMEP will not work because the following command cannot run
correctly (it should print \"OK\"):

escript %s check

The reason for this is probably that you do not have the escript
program in any of your search paths for programs. Please make
sure that escript program is installed and that the directory
where it is located is in your search path variable. The escript
program is typically installed together with Erlang."
             (yaemep-get-support-escript-path)))))


(defun yaemep-doc-error-info ()
  "Explain why goto documentation does not work"
  (interactive)
    (with-output-to-temp-buffer "*YAEMEP Erlang Doc Broken*"
    (princ
     (format "

This function is broken in your version of Emacs
erlang-mode. Please upgrade to version 2.8.3 (20191023.843) or
later:

https://melpa.org/#/erlang"))))

(defun yaemep-goto-func ()
  (interactive)
  (let (prev-invoke-mode imenu-use-popup-menu)
    (require 'imenu)
    (setq-default imenu-use-popup-menu nil)
    (call-interactively #'imenu)
    (setq-default imenu-use-popup-menu prev-invoke-mode)))


;;;###autoload
(define-minor-mode yaemep-extra-erlang-menu-mode
  "Add an extra Emacs menu with useful stuff"
  :lighter " yaemep-menu"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c C-f") 'yaemep-goto-func)
            map))

;;;###autoload

(add-hook 'erlang-mode-hook 'yaemep-extra-erlang-menu-mode)


(defun yaemep-rebar3-compile-project ()
  (interactive)
  (compile (format "cd \"%s\" && rebar3 compile" (yaemep-project-dir))))

(defun yaemep-make-project ()
  (interactive)
  (compile (format "cd \"%s\" && make" (yaemep-project-dir))))

(defun yaemep-mix-compile-project ()
  (interactive)
  (compile (format "cd \"%s\" && mix compile" (yaemep-project-dir))))


(defun yaemep-extra-erlang-menu-mode-toggle ()
  (if yaemep-extra-erlang-menu-mode
      (progn
        ;; Creating a new menu pane in the menu bar to the right of “Tools” menu
        (define-key-after
          yaemep-extra-erlang-menu-mode-map
          [menu-bar yaemep-menu]
          (cons "Erlang YAEMEP" (make-sparse-keymap "Erlang YAEMEP"))
          'tools )

        (if (yaemep-check-support-escript "the yamep menu")
            (progn

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yaemep-mix-compile]
                '("Project: mix compile" . yaemep-mix-compile-project))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yaemep-rebar3-compile]
                '("Project: rebar3 compile" . yaemep-rebar3-compile-project))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yaemep-make]
                '("Project: make" . yaemep-make-project))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu sep5]
                '(menu-item "--"))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yamep-generate-etags]
                '("Project: Generate TAGS" . yaemep-project-etags-update))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu sep6]
                '(menu-item "--"))

              (if (boundp 'erlang-version)
                  (if (string< erlang-version "2.8.3")
                      (define-key
                        yaemep-extra-erlang-menu-mode-map
                        [menu-bar yaemep-menu yaemep-goto-erlang-man]
                        '("Documentation for Erlang/OTP Function Under Point" . yaemep-doc-error-info))
                    (define-key
                      yaemep-extra-erlang-menu-mode-map
                      [menu-bar yaemep-menu yaemep-goto-erlang-man]
                      '("Documentation for Erlang/OTP Function Under Point" . erlang-man-function-no-prompt))))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu sep7]
                '(menu-item "--"))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yaemep-goto-fun-mod]
                '("Go to Function in Current Module" . yaemep-goto-func))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu sep4]
                '(menu-item "--"))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yaemep-goto-thing-at-point-other-frame]
                (if (fboundp 'xref-find-definitions-other-frame)
                    '("Other Frame Go to Thing at Point" . xref-find-definitions-other-frame)
                  '("Other Frame Go to Thing at Point" . find-tag-other-frame)))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yaemep-goto-thing-at-point-other-window]
                (if (fboundp 'xref-find-definitions-other-window)
                    '("Other Buffer Go to Thing at Point" . xref-find-definitions-other-window)
                  '("Other Buffer Go to Thing at Point" . find-tag-other-window)))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yaemep-goto-thing-at-point]
                (if (fboundp 'xref-pop-marker-stack)
                    '("Go Back After Go to Thing at Point" . xref-pop-marker-stack)
                  '("Go Back After Go to Thing at Point" . pop-tag-mark)))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yaemep-goto-thing-at-point-go-back]
                (if (fboundp 'xref-find-definitions)
                    '("Go to Thing at Point" . xref-find-definitions)
                  '("Go to Thing at Point" . find-tag)))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu sep3]
                '(menu-item "--"))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu yaemep-complete]
                '("Completion At Point" . yaemep-completion))

              (define-key
                yaemep-extra-erlang-menu-mode-map
                [menu-bar yaemep-menu sep1]
                '(menu-item "--")))

          (progn
            (define-key
              yaemep-extra-erlang-menu-mode-map
              [menu-bar yaemep-menu yaemep-menu-error-why]
              '("Error! Why?" . yaemep-menu-error-info))))


        (define-key
          yaemep-extra-erlang-menu-mode-map
          [menu-bar yaemep-menu yaemep-help]
          '("Help" . yaemep-help)))
    (progn
      )))

(add-hook 'yaemep-extra-erlang-menu-mode-hook
          'yaemep-extra-erlang-menu-mode-toggle)

(provide 'yaemep-extra-erlang-menu-mode)
