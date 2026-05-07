;; -*- lexical-binding: t; -*-


(defconst IS-MAC     (eq system-type 'darwin))
(defconst IS-LINUX   (memq system-type '(gnu gnu/linux gnu/kfreebsd berkeley-unix)))
(defconst IS-WINDOWS (memq system-type '(cygwin windows-nt ms-dos)))

(when IS-WINDOWS
  (set-language-environment "UTF-8")
  (setopt file-name-coding-system 'cp932)
  (setopt default-process-coding-system '(utf-8-dos . japanese-cp932-dos)))


(require 'package)
(setopt package-archives '( ("gnu"    . "https://elpa.gnu.org/packages/")
                            ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                            ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)

(require 'use-package)
(setopt use-package-always-ensure t
        use-package-enable-imenu-support t)


(use-package nerd-icons)

(use-package kaolin-themes
  :config
  ;; (load-theme 'kaolin-galaxy t)    ; 今のところ常用のヤツ
  ;; (load-theme 'kaolin-bubblegum t) ; 青色基調のヤツ
  (load-theme 'kaolin-aurora t)       ; galaxyの緑版みたいな
  (kaolin-treemacs-theme))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 32
        doom-modeline-bar-width 8)
  :custom
  (doom-modeline-icon t)
  (doom-modeline-font-family "Explex Console NF 10"))
  ;; (doom-modeline-font-family "Symbols Nerd Font Mono"))

(use-package centaur-tabs
  :demand
  :config
  (centaur-tabs-mode t)
  (centaur-tabs-headline-match)
  (setq centaur-tabs-style "wave"
        centaur-tabs-height 32
        ;; centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-icons t
        centaur-tabs-icon-type 'nerd-icons
        centaur-tabs-gray-out-icons 'buffer
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "")
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))


;; 補完設定 (Company)
(use-package company
  :bind (("C-M-i" . company-complete)
         :map company-active-map
         ("M-n" . nil)
         ("M-p" . nil)
         ("C-s" . company-filter-candidates)
         ("C-n" . company-select-next)
         ("C-p" . company-select-previous)
         ("C-f" . company-complete-selection)
         :map company-search-map
         ("C-n" . company-select-next)
         ("C-p" . company-select-previous))
  :custom
  (company-idle-delay 0)
  (company-minimum-prefix-length 1)
  (company-transformers '(company-sort-by-occurrence))
  :init
  (global-company-mode t))


;;; Git関連
(use-package magit
  :bind (("C-x C-g" . magit-status))
  :config (require 'magit-extras))

(use-package diff-hl
  ;; Magitのバッファ更新前後にdiff-hlも更新
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :init
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (global-diff-hl-mode)                 ; diff-hlモードをグローバルに有効化
  (global-diff-hl-show-hunk-mouse-mode) ; マウスオーバーで変更差分 (hunk) を表示
  (diff-hl-margin-mode))                ; フリンジではなくマージン領域に差分表示


(use-package emacs
  :init
  (set-locale-environment "ja_JP.UTF-8")

  :custom
  (display-line-numbers-type 'relative)
  (kill-whole-line t)
  (indent-tabs-mode nil)
  (tab-width 2)
  (use-short-answers t)
  (make-backup-files nil)
  (backup-inhibited nil)
  (create-lockfiles nil)
  (read-process-output-max (* 1024 1024))

  :bind
  ("<f1>" . help-command)
  ("C-h" . backward-delete-char-untabify)

  :config
  (add-to-list 'default-frame-alist '(undecorated . t))
  (set-frame-parameter nil 'undecorated t)
  (global-display-line-numbers-mode t)
  (set-face-attribute 'default nil
                    :family "Moralerspace Neon HW"
                    :height 100)

  ;; ;; japanese-jisx0208, japanese-jisx0213.2004-1
  ;; (set-fontset-font t 'unicode
  ;;                   (font-spec :family "BIZ UDGothic"))

  ;; (setq face-font-rescale-alist
  ;;     '(("BIZ UDGothic" . 1.2)))

  (dolist (range '((#xE000   . #xF8FF)
                   (#xF0000  . #xFFFFF)
                   (#x100000 . #x10FFFF)))
    (set-fontset-font t range
                      (font-spec :family "Symbols Nerd Font Mono"))))


(use-package gcmh
  :hook (after-init . gcmh-mode)
  :custom
  (gcmh-verbose init-file-debug)
  (gcmh-high-cons-threshold (* 128 1024 1024)))


(use-package eat
  :bind*
  ("C-'" . toggle-eat-window)

  :config
  (setopt eat-kill-buffer-on-exit t)

  (defun toggle-eat-window ()
    (interactive)
    (if (get-buffer-window "*eat*")
        (delete-window (get-buffer-window "*eat*"))
      (progn
        (split-window-below)
        (other-window 1)
        (eat))))

  (add-hook 'kill-buffer-hook
            (lambda ()
              (when (eq major-mode 'eat-mode)
                (let ((eat-win (get-buffer-window (current-buffer))))
                  (when (and eat-win (> (length (window-list)) 1))
                    (delete-window eat-win)))))))


;;; クリップボード連携 (Wayland/wl-copy)
(setq wl-copy-process nil)
(defun wl-copy (text)
  (setq wl-copy-process (make-process :name "wl-copy"
                                      :buffer nil
                                      :command '("wl-copy" "-f" "-n")
                                      :connection-type 'pipe
                                      :noquery t))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))

(defun wl-paste ()
  (if (and wl-copy-process (process-live-p wl-copy-process))
    nil
    (shell-command-to-string "wl-paste -n | tr -d \r")))

(unless IS-WINDOWS
  (setq interprogram-cut-function 'wl-copy)
  (setq interprogram-paste-function 'wl-paste))


(defvar my/skk-custom-rules
  '(
    ;; ぎゃ行 GG系
    ("gga" nil ("ギャ" . "ぎゃ"))
    ("ggu" nil ("ギュ" . "ぎゅ"))
    ("gge" nil ("ギェ" . "ぎぇ"))
    ("ggo" nil ("ギョ" . "ぎょ"))
    ("ggz" nil ("ギャン" . "ぎゃん"))
    ("ggn" nil ("ギャン" . "ぎゃん"))
    ("ggj" nil ("ギュン" . "ぎゅん"))
    ("ggd" nil ("ギェン" . "ぎぇん"))
    ("ggl" nil ("ギョン" . "ぎょん"))
    ("ggq" nil ("ギャイ" . "ぎゃい"))
    ("ggh" nil ("ギュウ" . "ぎゅう"))
    ("ggw" nil ("ギェイ" . "ぎぇい"))
    ("ggp" nil ("ギョウ" . "ぎょう"))

    ;; びゃ行 BG系
    ("bga" nil ("ビャ" . "びゃ"))
    ("bgu" nil ("ビュ" . "びゅ"))
    ("bge" nil ("ビェ" . "びぇ"))
    ("bgo" nil ("ビョ" . "びょ"))
    ("bgz" nil ("ビャン" . "びゃん"))
    ("bgn" nil ("ビャン" . "びゃん"))
    ("bgj" nil ("ビュン" . "びゅん"))
    ("bgd" nil ("ビェン" . "びぇん"))
    ("bgl" nil ("ビョン" . "びょん"))
    ("bgq" nil ("ビャイ" . "びゃい"))
    ("bgh" nil ("ビュウ" . "びゅう"))
    ("bgw" nil ("ビェイ" . "びぇい"))
    ("bgp" nil ("ビョウ" . "びょう"))

    ;; りゃ行 RG系
    ("rga" nil ("リャ" . "りゃ"))
    ("rgu" nil ("リュ" . "りゅ"))
    ("rge" nil ("リェ" . "りぇ"))
    ("rgo" nil ("リョ" . "りょ"))
    ("rgz" nil ("リャン" . "りゃん"))
    ("rgn" nil ("リャン" . "りゃん"))
    ("rgj" nil ("リュン" . "りゅん"))
    ("rgd" nil ("リェン" . "りぇん"))
    ("rgl" nil ("リョン" . "りょん"))
    ("rgq" nil ("リャイ" . "りゃい"))
    ("rgh" nil ("リュウ" . "りゅう"))
    ("rgw" nil ("リェイ" . "りぇい"))
    ("rgp" nil ("リョウ" . "りょう"))

    ;; ji / jk の補完
    ("ji" nil ("ジ" . "じ"))
    ("jk" nil ("ジン" . "じん"))

    ;; ゕ/ゖ を xxka/xxke に (kA/kE は後述で削除)
    ("xxka" nil ("ヵ" . "ゕ"))
    ("xxke" nil ("ヶ" . "ゖ"))

    ;; x- でハイフン、c- でアンダーバー
    ("x-" nil "-")
    ("c-" nil "_")

    ;; ! ? を半角に固定
    ("!" nil "!")
    ("?" nil "?")

    ;; fm を「ふぇん」に変更 (kA/kE と同様に既存ルール削除後に追加)
    ("fm" nil ("フェン" . "ふぇん"))

    ;; 撥音拡張: Z のエイリアスとして V を追加
    ("kv" nil ("カン" . "かん"))
    ("sv" nil ("サン" . "さん"))
    ("tv" nil ("タン" . "たん"))
    ("nv" nil ("ナン" . "なん"))
    ("hv" nil ("ハン" . "はん"))
    ("mv" nil ("マン" . "まん"))
    ("yv" nil ("ヤン" . "やん"))
    ("rv" nil ("ラン" . "らん"))
    ("wv" nil ("ワン" . "わん"))
    ("gv" nil ("ガン" . "がん"))
    ("zv" nil ("ザン" . "ざん"))
    ("jv" nil ("ジャン" . "じゃん"))
    ("dv" nil ("ダン" . "だん"))
    ("bv" nil ("バン" . "ばん"))
    ("pv" nil ("パン" . "ぱん"))
    ("fv" nil ("ファン" . "ふぁん"))
    ("xv" nil ("シャン" . "しゃん"))

    ;; 撥音拡張: D のエイリアスとして M を追加
    ("km" nil ("ケン" . "けん"))
    ("sm" nil ("セン" . "せん"))
    ("tm" nil ("テン" . "てん"))
    ("nm" nil ("ネン" . "ねん"))
    ("gm" nil ("ゲン" . "げん"))
    ("zm" nil ("ゼン" . "ぜん"))
    ("dm" nil ("デン" . "でん"))
    ("bm" nil ("ベン" . "べん"))
    ("pm" nil ("ペン" . "ぺん"))
    ("rm" nil ("レン" . "れん"))
    ("hm" nil ("ヘン" . "へん"))
    ("mm" nil ("メン" . "めん"))

    ;; V + M エイリアス (えん)
    ("vz" nil ("アン" . "あん"))
    ("vn" nil ("アン" . "あん"))
    ("vv" nil ("アン" . "あん"))
    ("vk" nil ("イン" . "いん"))
    ("vj" nil ("ウン" . "うん"))
    ("vd" nil ("エン" . "えん"))
    ("vm" nil ("エン" . "えん"))
    ("vl" nil ("オン" . "おん"))))

(use-package ddskk
  :bind ("C-x C-j" . skk-mode)
  :custom
  (skk-large-jisyo
    (if (eq system-type 'windows-nt)
      "~/.emacs.d/skk-get-jisyo/SKK-JISYO.L"      ; Windows用
      "~/.nix-profile/share/skk/SKK-JISYO.L"))      ; Nix/Linux用
  (skk-egg-like-newline t)
  (skk-show-annotation t)
  (skk-share-private-jisyo t)
  (skk-use-azik t)
  (skk-azik-keyboard-type 'en)
  :config
      (add-hook 'skk-azik-load-hook
            (setq skk-rom-kana-rule-list my/skk-custom-rules)))

;;     (lambda ()
;;       (setq skk-rom-kana-rule-list
;;         (cl-remove-if (lambda (rule)
;;                         (member (car rule) '("kv" "jv" "dv" "nv" "pv" "mv" "yv"
;;                                              "sm" "zm" "dm" "fm" "kA" "kE"
;;                                              "vz" "vn" "vk" "vd" "vl")))
;;                       skk-rom-kana-rule-list))
;;
;;       (dolist (rule my/skk-custom-rules)
;;         (add-to-list 'skk-rom-kana-rule-list rule)))))


(use-package dashboard
  :config
  (setq inhibit-startup-message t)
  (setq dashboard-center-content t)          ; 横方向に中央揃え
  (setq dashboard-vertically-center-content t) ; 縦方向にも中央揃え
  (setq dashboard-startup-banner 'logo)   ; ロゴ表示（'official, 数字, ファイルパスも可）
  (setq dashboard-center-content t)       ; コンテンツを中央揃え
  (setq dashboard-items '((recents  . 5)  ; 最近開いたファイル（5件）
                           (bookmarks . 5) ; ブックマーク
                           (projects . 5)  ; projectile のプロジェクト
                           (agenda . 5)    ; org-agenda
                           (registers . 5))) ; レジスタ
  (dashboard-setup-startup-hook))


;;; Vertico/Orderless/Consultの設定
;; --- 1. 履歴の保存設定 (recentf) ---
(recentf-mode 1)
(setq recentf-max-saved-items 2000)

;; --- 2. Vertico (一覧表示のUI) ---
(use-package vertico
  :init
  (vertico-mode))

;; --- 3. Orderless (高度な絞り込み) ---
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; --- 4. Consult (履歴検索とプレビュー) ---
(use-package consult
  :bind (; 履歴からファイルを開く (今回のメイン機能)
         ("C-c r" . consult-recent-file)
         ; バッファ切り替え (プレビュー付き)
         ("C-x b" . consult-buffer)
         ; 行検索 (C-s の強化版)
         ("M-s l" . consult-line))
  :config
  ; プレビューを即座に表示する設定
  (setq consult-preview-key 'any))


;;; org-modeの設定
(use-package org
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)      ;; アジェンダを開く
         ("C-c c" . org-capture)     ;; 素早くメモやタスクを記録
         :map org-mode-map
         ("C-c w" . my/org-copy-markup-content))

  :config
  ;; タスクの状態を定義
  (setq org-cycle-separator-lines 1)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "UNIV(u)" "|" "DONE(d)" "CANCEL(c)")))
  (setq org-todo-keyword-faces
        '(("UNIV" . (:foreground "cyan" :weight bold))))
  ;; アジェンダの対象にするファイル
  (setq org-agenda-files '("~/documents/org-docs/todo.org"))

  ;; orgでインラインの中身だけコピーするヤツ
  (defun my/org-copy-markup-content ()
    (interactive)
    (let* ((element (org-element-context))
           (type (org-element-type element)))
      (if (memq type '(code verbatim))
          (let ((value (org-element-property :value element)))
            (kill-new value)                  ;; Emacsのkill ringにも入れる
            (unless IS-WINDOWS
              (wl-copy value))                ;; システムクリップボードにも送る
            (message "Copied: %s" value))
        (call-interactively #'kill-ring-save))))

  :custom
  (org-hide-emphasis-markers t)
  (org-link-descriptive t))

(use-package org-modern
  :custom
  (org-modern-keyword nil) ;; Headerの修飾を無効に
  (org-modern-table nil)   ;; Tableの修飾を無効に
  (org-modern-star 'replace)
  (org-modern-replace-stars "")
  ;; (org-modern-replace-stars "◉○◈◇✳")
  :config
  (global-org-modern-mode)
  (dolist (face '(org-modern-label
                  org-modern-date-active
                  org-modern-date-inactive
                  org-modern-time-active
                  org-modern-time-inactive
                  org-modern-tag
                  org-modern-priority))
    (set-face-attribute face nil :height 1.0))
  (setq org-modern-todo-faces
      '(("UNIV"      . (:background "#ff5a00" :foreground "#e5e5e5" :weight bold)))))

;;; CJKでテーブルが崩れてしまう問題への対処
(use-package valign
  :hook
  (org-mode . valign-mode))

;;; リンクなどにカーソルをあてた場合に実体が見えるように
(use-package org-appear
  :hook
  (org-mode . org-appear-mode)
  :custom
  (org-appear-autoemphasis t) ;; 基本的な太字などの要素の実体を表示
  (org-appear-autolinks t))   ;; 追加でリンクの実体を表示

(org-babel-do-load-languages
 'org-babel-load-languages
 '((shell . t)))  ; nixはshell経由で実行

(add-to-list 'org-src-lang-modes '("nix" . nix-ts))

(defun urls-cleanup-string (str)
  "文字列STRに含まれるYouTube/X/TwitchのURLを整形して返す。"
  (let ((yt-re (rx "http" (opt "s") "://www.youtube.com/"
                   (or (seq "live/" (group (one-or-more (not (any "&? \n]")))))
                       (seq "watch?v=" (group (one-or-more (not (any "&? \n]"))))))
                   (opt (minimal-match (zero-or-more any)) (any "?&") "t="
                        (group (one-or-more (not (any "& \n]")))))
                   (zero-or-more (not (any " \n]")))))
        (x-re (rx (group "http" (opt "s") "://" (or "x" "twitter") ".com/"
                         (one-or-more (not (any "/ \n]"))) "/status/" (one-or-more digit))
                  (zero-or-more (not (any " \n]")))))
        (tw-re (rx "http" (opt "s") "://www.twitch.tv/"
                   (or (seq "videos/" (group (one-or-more digit)))
                       (seq (one-or-more (not (any "/ \n]"))) "/video/" (group (one-or-more digit))))
                   ;; "?" の後に "&区切りで t= が出るまで読み飛ばす" 形式に変更
                   (opt "?" (zero-or-more (seq (one-or-more (not (any "=& \n]"))) "="
                                               (zero-or-more (not (any "& \n]"))) "&"))
                        "t=" (group (one-or-more (not (any "& \n]")))))
                   (zero-or-more (not (any " \n]"))))))
    (cond
     ((string-match yt-re str)
      (let ((id (or (match-string 1 str) (match-string 2 str)))
            (time (match-string 3 str)))
        (if time
            (format "https://youtu.be/%s?t=%s" id time)
          (format "https://youtu.be/%s" id))))
     ((string-match x-re str) (match-string 1 str))
     ((string-match tw-re str)
      (let ((id (or (match-string 1 str) (match-string 2 str)))
            (time (match-string 3 str)))
        (if time
            (format "https://www.twitch.tv/videos/%s?t=%s" id time)
          (format "https://www.twitch.tv/videos/%s" id))))
     (t str))))

(defun urls-cleanup ()
  "選択範囲またはバッファ全体のURLを一括整形する。"
  (interactive)
  (let ((beg (if (use-region-p) (region-beginning) (point-min)))
        (end (copy-marker (if (use-region-p) (region-end) (point-max)))))
    (save-excursion
      (goto-char beg)
      (let ((combined-re (rx (or (seq "http" (opt "s") "://www.youtube.com/" (or "live/" "watch?v="))
                                 (seq "http" (opt "s") "://" (or "x" "twitter") ".com/")
                                 ;; /videos/ と /CHANNEL/video/ の両方をキャッチ
                                 (seq "http" (opt "s") "://www.twitch.tv/"
                                      (or "videos/"
                                          (seq (one-or-more (not (any "/ \n]"))) "/video/"))))
                             (one-or-more (not (any " \n]"))))))
        (while (re-search-forward combined-re end t)
          (replace-match (urls-cleanup-string (match-string 0)) t t))))
    (set-marker end nil)
    (message "URLs cleaned!")))

(advice-add 'insert-for-yank :filter-args
            (lambda (args)
              (cons (urls-cleanup-string (car args)) (cdr args))))


(use-package vundo
  :bind ("C-x u" . vundo))


(use-package windmove
  :ensure nil  ;; 組み込みなのでnilでOK
  :bind
  (("S-<up>"    . windmove-up)
   ("S-<down>"  . windmove-down)
   ("S-<left>"  . windmove-left)
   ("S-<right>" . windmove-right)))


(use-package whitespace
  :ensure nil
  :hook (after-init . global-whitespace-mode)
  :custom
  (whitespace-style '(face
                      trailing
                      tabs
                      spaces
                      empty
                      space-mark
                      tab-mark))

  (whitespace-display-mappings
   '((space-mark ?\u3000 [?\u25a1])
     ;; WARNING: the mapping below has a problem.
     ;; When a TAB occupies exactly one column, it will display the
     ;; character ?\xBB at that column followed by a TAB which goes to
     ;; the next TAB column.
     ;; If this is a problem for you, please, comment the line below.
     (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))

  (whitespace-space-regexp "\\(\u3000+\\)")

  (whitespace-trailing-regexp "\\([ \u00A0]+\\)$")

  (whitespace-action '(auto-cleanup)))


(use-package dirvish
  :init
  (dirvish-override-dired-mode) ;; DirvishでDiredを置き換え
  :custom
  (dirvish-quick-access-entries
   '(("h" "~/" "Home")
     ("d" "~/Downloads/" "Downloads")
     ("p" "~/projects/" "Projects")))
  :config
  (dirvish-peek-mode)   ;; ファイルプレビューを有効化
  :bind
  (("C-c f" . dirvish)  ;; Dirvishを起動
   :map dirvish-mode-map
   ("a"   . dirvish-quick-access)
   ("f"   . dirvish-file-info-menu)
   ("y"   . dirvish-yank-menu)
   ("N"   . dirvish-narrow)
   ("^"   . dirvish-history-last)
   ("h"   . dirvish-history-jump)
   ("s"   . dirvish-quicksort)
   ("v"   . dirvish-vc-menu)
   ("TAB" . dirvish-subtree-toggle)
   ("M-f" . dirvish-history-go-forward)
   ("M-b" . dirvish-history-go-backward)
   ("M-l" . dirvish-ls-switches-menu)
   ("M-m" . dirvish-mark-menu)
   ("M-t" . dirvish-layout-toggle)
   ("M-s" . dirvish-setup-menu)
   ("M-e" . dirvish-emerge-menu)
   ("M-j" . dirvish-fd-jump)))


;;; tree-sitterの構文ハイライト
;; 先にnix shell nixpkgs#gccでコンパイル準備をしておく
(setq treesit-language-source-alist
  '((nix . ("https://github.com/nix-community/tree-sitter-nix"))))

(use-package nix-ts-mode
  :mode "\\.nix\\'"
  :init
  (setq treesit-font-lock-level 4))


(use-package hydra)


(use-package multiple-cursors)
(defhydra hydra-multiple-cursors (:hint nil)
  "
 Up^^             Down^^           Miscellaneous           % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]   Next     [_n_]   Next     [_l_] Edit lines  [_0_] Insert numbers
 [_P_]   Skip     [_N_]   Skip     [_a_] Mark all    [_A_] Insert letters
 [_M-p_] Unmark   [_M-n_] Unmark   [_s_] Search      [_q_] Quit
 [_|_] Align with input CHAR     [Click] Cursor at point"
  ("l" mc/edit-lines :exit t)
  ("a" mc/mark-all-like-this :exit t)
  ("n" mc/mark-next-like-this)
  ("N" mc/skip-to-next-like-this)
  ("M-n" mc/unmark-next-like-this)
  ("p" mc/mark-previous-like-this)
  ("P" mc/skip-to-previous-like-this)
  ("M-p" mc/unmark-previous-like-this)
  ("|" mc/vertical-align)
  ("s" mc/mark-all-in-region-regexp :exit t)
  ("0" mc/insert-numbers :exit t)
  ("A" mc/insert-letters :exit t)
  ("<mouse-1>" mc/add-cursor-on-click)
  ;; Help with click recognition in this hydra
  ("<down-mouse-1>" ignore)
  ("<drag-mouse-1>" ignore)
  ("q" nil))
(global-set-key (kbd "C-c m") 'hydra-multiple-cursors/body)


(defun sort-and-delete-duplicate-lines (beg end)
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-max))))
  (sort-lines nil beg end)
  (delete-duplicate-lines beg end nil t))


(when (file-exists-p "/mnt/c/Windows/System32/cmd.exe")
  (setq browse-url-browser-function
        (lambda (url &rest args)
          (let ((escaped-url (replace-regexp-in-string "&" "^&" url)))
            (call-process "/mnt/c/Windows/System32/cmd.exe" nil 0 nil
                          "/c" "start" "" escaped-url)))))


(provide 'init)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files nil)
 '(package-selected-packages
   '(ample-theme base16-theme centaur-tabs company consult darkokai-theme
                 dashboard ddskk diff-hl dirvish doom-modeline eat
                 flymake hydra kaolin-themes magit modus-themes
                 multiple-cursors nix-ts-mode orderless org-appear
                 org-modern org-superstar timu-rouge-theme use-package
                 valign vertico-posframe vundo)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
