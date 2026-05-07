;; -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum)

(push '(fullscreen . maximized) default-frame-alist)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)

(provide 'early-init)
;;; early-init.el ends here
