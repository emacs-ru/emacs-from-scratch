;;; init.el --- Emacs from scratch config -*- lexical-binding: t; -*-
;;; Commentary:
;;; Настройки Emacs для тех, кто не знает с чего начать.

;;; Code:


;; Использовать клавиши y и n для подтверждения команд. По умолчанию
;; нужно ввести yes или no и нажать Enter.
(defalias 'yes-or-no-p 'y-or-n-p)

;; Укажите нужный размер шрифта, если этот слишком большой или
;; маленький.
(defconst init-el-font-height 16 "Размер шрифта по умолчанию.")

;; Некоторые настройки можно сделать с помощью `customize'. Чтобы не
;; замусоривать `init.el', будем хранить их в файле `custom.el`.
(require 'custom)
(setopt custom-file
        (expand-file-name
         (convert-standard-filename "custom.el")
         user-emacs-directory))


;; Загрузим настройки, сделанные через `customize', сразу, чтобы они
;; не переопределяли параметры из `init.el'.
(when (file-exists-p custom-file)
  (load custom-file))


(defun init-el-set-font-height ()
  "Установка размера шрифта.
Размер шрифта устанавливается в типографских пунктах, а значит, должен
быть в 10 раз больше чем указано в `init-el-font-height'."
  (set-face-attribute 'default nil :height (* init-el-font-height 10)))


(defun init-el-set-font (font-family)
  "Эта функция устанавливает семейство шрифтов FONT-FAMILY как основное.
Настройки задаются в формате X Logical Font Description Conventions,
XLFD: https://www.x.org/releases/X11R7.7/doc/xorg-docs/xlfd/xlfd.html"
  (set-frame-font (format "-*-%s-normal-normal-normal-*-%d-*-*-*-m-0-iso10646-1"
                          font-family
                          init-el-font-height)
                  nil ;; Не сохранять установленный ранее размер
                  t   ;; Применить ко всем фреймам
                  t)  ;; Игнорировать настройки, сделанные через `customize'
  (set-face-attribute
   'default ;; Font Face по умолчанию
   nil      ;; Применить ко всем фреймам
   ;; Атрибуты шрифта
   :height (* init-el-font-height 10)
   :family font-family))


;; Настройки, специфичные для графического режима
(defun setup-gui-settings (&optional frame-name)
  "Параметры шрифта во фрейме FRAME-NAME."
  ;; Мы точно в GUI?
  (when (display-graphic-p frame-name)
    ;; Кешируем список семейств шрифтов
    (let ((font-families (font-family-list)))
      ;; Выбираем шрифт по умолчанию.
      ;; Впишите на первое место своё любимое семейство шрифтов.
      ;; Только убедитесь, что оно установлено в вашей системе.
      (let ((preferred-font-family (cond ((member "Lilex" font-families) "Lilex")
                                         ((member "SauceCodePro NFP" font-families) "SauceCodePro NFP")
                                         ((member "FiraCode Nerd Font Mono" font-families) "FiraCode Nerd Font Mono")
                                         ((member "Fira Code" font-families) "Fira Code")
                                         ((member "DejaVu Sans Mono Nerd" font-families) "DejaVu Sans Mono Nerd")
                                         ((member "DejaVu Sans Mono" font-families) "DejaVu Sans Mono")
                                         ((member "Source Code Pro" font-families) "Source Code Pro")
                                         ((member "Consolas" font-families) "Consolas")
                                         ('t nil))))
        ;; Шрифт по умолчанию доступен в системе?
        (when preferred-font-family
          (progn
            (message (format "Семейство шрифтов по умолчанию: %s" preferred-font-family))
            ;; Используем желаемый шрифт для оформления текста во всех
            ;; буферах.
            (init-el-set-font preferred-font-family)))))))

;; Настройка шрифтов для обычного режима
(add-hook 'after-init-hook (lambda ()(setup-gui-settings (selected-frame))))

;; Настройка шрифтов при работе в режиме сервера
(add-hook 'server-after-make-frame-hook (lambda ()(setup-gui-settings (selected-frame))))

;; Настройка шрифтов в новых фреймах в любом режиме
(add-to-list 'after-make-frame-functions 'setup-gui-settings)

;; Отображать шрифты красиво, используя Font Face's
(global-font-lock-mode t)


;; Определение пути к каталогу с исходным кодом
;; Исходный код может понадобиться для просмотра документации
;; некоторых функций и переменных.
;; Впрочем, это не обязательно.
(when (string-equal system-type "gnu/linux")
  (message "Используется ОС на базе GNU/Linux")
  (defvar init-el-emacs-source-path "Путь к каталогу с исходным кодом Emacs")
  (setq init-el-emacs-source-path
        (format "/usr/share/emacs/%d.%d/src/"
                emacs-major-version
                emacs-minor-version))
  (if (file-exists-p init-el-emacs-source-path)
      ;; Каталог существует
      (if (directory-empty-p init-el-emacs-source-path)
          ;; Каталог пуст
          (message (format "Каталог %s пуст." init-el-emacs-source-path))
        ;; Каталог не пуст
        (progn
          (setopt source-directory init-el-emacs-source-path)
          (message (format "Исходный код обнаружен в каталоге %s" init-el-emacs-source-path))))
    ;; Каталог не существует
    (message (format "Каталог %s не существует." init-el-emacs-source-path))))

(setopt
 completion-ignore-case t ;; Игнорировать регистр при автодополнении
 create-lockfiles nil ;; Не создавать lock-файлы
 cursor-in-non-selected-windows nil ;; Отключить курсор в неактивных окнах
 cursor-type 'bar ;; Курсор в виде вертикальной черты
 default-input-method "russian-computer" ;; Метод ввода по умолчанию
 default-transient-input-method "russian-computer" ;; Временный метод ввода
 delete-by-moving-to-trash t ;; Удалять файлы в Корзину
 gc-cons-threshold (* 2 gc-cons-threshold) ;; Увеличить размер памяти для сборщика мусора
 highlight-nonselected-windows nil ;; Не подсвечивать неактивные окна
 inhibit-compacting-font-caches t ;; Не сжимать шрифты в памяти
 inhibit-startup-screen t ;; Не показывать приветственный экран
 initial-scratch-message nil ;; Пустой буфер *scratch*
 load-prefer-newer t ;; Если есть файл elc, но el новее, загрузить el-файл.
 major-mode 'text-mode ;; Текстовый режим для новых буферов по умолчанию.
 read-answer-short t ;; Быстрый ввод ответов на вопросы (не аналог yes-or-no-p
 read-file-name-completion-ignore-case t ;; Игнорировать регистр при вводе имён файлов
 read-process-output-max (* 1024 1024) ;; Увеличим чанк чтения для LSP: по умолчанию 65535
 redisplay-skip-fontification-on-input t ;; Не обновлять буфер, если происходит ввод
 ring-bell-function 'ignore ;; Отключить звуковое сопровождение событий
 show-trailing-whitespace t ;; Подсветка висячих пробелов
 standard-indent 4 ;; Отступ по умолчанию — 4 пробела
 tab-always-indent 'complete ;; Если можно — выровнять текст, иначе — автодополнение.
 use-dialog-box nil ;; Диалоговые окна ОС не нужны
 use-short-answers t ;; Краткие ответы вместо длинных
 user-full-name "TODO: вписать своё имя" ;; Имя пользователя
 user-mail-address "TODO: вписать свой email" ;; Адрес электронной почты
 vc-follow-symlinks t ;; Переходить по ссылкам без лишних вопросов
 visible-bell t) ;; Мигать буфером при переходе в него


(defun init-kill-scratch ()
  "Закрыть буфер *scratch* при запуске редактора или подключении клиента."
  (when (get-buffer "*scratch*")
    (kill-buffer "*scratch*")))
;; Закрываем буфер *scratch* при инициализации в обычном режиме
(add-hook 'after-init-hook 'init-kill-scratch)
;; Закрываем буфер *scratch* при подключении к серверу Emacs
(add-hook 'server-after-make-frame-hook 'init-kill-scratch)

(when (fboundp 'menu-bar-mode)
  (setopt menu-bar-mode nil)) ;; Выключить отображение меню

(when (fboundp 'scroll-bar-mode)
  (setopt scroll-bar-mode nil)) ;; Отключить полосы прокрутки

(when (fboundp 'tool-bar-mode)
  (setopt tool-bar-mode nil)) ;; Выключить отображение панели инструментов

(when (fboundp 'tooltip-mode)
  (tooltip-mode nil)) ;; Отключить вывод всплывающих подсказок в GUI


;; Отключим некоторые привязки клавиш по умолчанию
(require 'keymap)
(keymap-global-unset "M-,")     ;; Такие маркеры не нужны
(keymap-global-unset "C-z")     ;; Такой Ctrl+Z нам не нужен
(keymap-global-unset "C-x C-z") ;; `suspend-emacs' тоже не нужен
(keymap-global-unset "C-x C-p") ;; `mark-page' не нужна, часто конфликтует с Projectile

;; Включим переключение буферов по Ctrl+PgUp и Ctrl+PgDn
(keymap-global-unset "C-<next>")  ;; Ни разу не видел, что это было нужно
(keymap-global-unset "C-<prior>") ;; Это сочетание тоже не нужно.
(keymap-global-set "C-<next>" 'next-buffer)
(keymap-global-set "C-<prior>" 'previous-buffer)

;; Закрыть буфер по нажатию [C-x k]
(keymap-global-set "C-x k" (lambda() (interactive) (kill-buffer (current-buffer))))


;; 📦 PACKAGE
;; Этот встроенный пакет отвечает за управление другими пакетами.
(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(package-initialize)

(setopt package-archive-priorities
        '(("gnu" . 40)
          ("nongnu" . 30)
          ("melpa-stable" . 20)
          ("melpa" . 10)))

(defun init-el-check-archive-contents ()
  "Проверим состояние кеша пакетов. Если его нет, то обновим его."
  (unless package-archive-contents
    (package-refresh-contents)))

(init-el-check-archive-contents)

;; Этот пакет решает проблему проверки цифровых подписей пакетов.
(unless (package-installed-p 'gnu-elpa-keyring-update)
  (progn
    (message "Обновление ключей для проверки цифровой подписи.")
    (package-install 'gnu-elpa-keyring-update t)))

;; Пакет `use-package' должен быть установлен, но на всякий случай
;; проверим
(unless (package-installed-p 'use-package)
  (package-install 'use-package t))

(require 'use-package)


;; 📦 ANSI-COLOR
;; Этот пакет отвечает за вывод текста в некоторых информационных
;; буферах.
(use-package ansi-color
  :custom
  (ansi-color-for-compilation-mode t "Расцветка буфера *compile*")
  :hook
  (compilation-filter . ansi-color-compilation-filter))


;; 📦 AUTOREVERT
;; Встроенный пакет.
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Auto-Revert.html
;; Автоматическое обновление буферов.
;; По умолчанию `global-auto-revert-mode' работает только с файловыми
;; буферами, но мы заставим его обновлять и содержимое буферов Dired.
(use-package autorevert
  :custom
  (auto-revert-check-vc-info t "Автоматически обновлять статусную строку")
  (global-auto-revert-non-file-buffers t "Автообновление не только файловых буферов.")
  :config
  (global-auto-revert-mode t)
  :hook
  (dired-mode . auto-revert-mode))


;; 📦 CALENDAR
;; Пакет для работы с календарём.
(use-package calendar
  :custom
  (calendar-week-start-day 1 "Начнём неделю с понедельника"))


;; 📦 COMPILE
;; Этот пакет отвечает за содержимое буфера *compilation*.
(use-package compile
  :custom
  (compilation-scroll-output t "Включим автопрокрутку текста"))


;; 📦 CONF-MODE
;; Пакет для редактирования конфигурационных файлов INI/CONF.
(use-package conf-mode
  :mode
  ("\\.env\\'"
   "\\.flake8\\'"
   "\\.pylintrc\\'"))


;; 📦 CUSTOM
;; Пакет для управления настройками.
(use-package custom
  :custom
  (custom-safe-themes t "Все темы считаем безопасными"))


;; 📦 DELSEL
;; Пакет для управления выделенным текстом (регионами).
;; По умолчанию Emacs не удаляет выделенный текст при вводе нового
;; текста, а при нажатиях клавиш Del и BackSpace удаляет только один
;; знак. Но мы это исправим.
(use-package delsel
  :config
  (delete-selection-mode t)) ;; Удалять ВЕСЬ выделенный фрагмент


;; 📦 DESKTOP
;; Сохранение состояния Emacs между сессиями.
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Saving-Emacs-Sessions.html
(use-package desktop
  :custom
  (desktop-dirname user-emacs-directory "Каталог для хранения файла .desktop")
  (desktop-load-locked-desktop t "Загрузка файла .desktop даже если он заблокирован")
  (desktop-restore-frames t "Восстанавливать фреймы")
  (desktop-save t "Сохранять список открытых буферов, файлов и т. д. без лишних вопросов")
  :config
  (desktop-save-mode t)
  ;; Сохраняем рабочий стол при закрытии фрейма
  (add-to-list 'delete-frame-functions 'desktop-save)
  ;; Не сохраняем буферы Dired
  (add-to-list 'desktop-modes-not-to-save 'dired-mode)
  :hook
  ;; Загружаем состояние при запуске в обычном режиме
  (after-init . desktop-read)
  ;; Загружаем состояние при запуске в режиме сервера
  (server-after-make-frame . desktop-read)
  ;; Сохраняем настройки при завершении работы
  (kill-emacs . (lambda () (desktop-save user-emacs-directory t)))
  (server-done . desktop-save))


;; 📦 DIRED
;; Файловый менеджер
(use-package dired
  :custom
  (dired-free-space 'separate "Информация о занятом и свободном месте в отдельной строке")
  (dired-kill-when-opening-new-dired-buffer t "Удалять буфер при переходе в другой каталог")
  ;; Дополнительные параметры вызова утилиты ls.
  (dired-listing-switches "-l --human-readable --all --group-directories-first --dired")
  (dired-recursive-deletes 'always "Не задавать лишних вопросов при удалении не-пустых каталогов")
  :init
  ;; По умолчанию будем показывать только имена. Чтобы увидеть всё,
  ;; нажмите [C-(]
  (add-hook 'dired-mode-hook 'dired-hide-details-mode))


;; 📦 DISPLAY-LINE-NUMBERS-MODE
;; Отображение номеров строк.
(use-package display-line-numbers
  :hook
  ((c-mode
    conf-mode
    emacs-lisp-mode
    html-mode) . display-line-numbers-mode))


;; 📦 ELECTRIC-INDENT MODE
;; Автоматическая вставка отступов при переходе на новую строку.
;; Добавляйте режимы осторожно.
(use-package electric
  :hook
  ((emacs-lisp-mode) . electric-indent-local-mode))


;; 📦 ELEC-PAIR MODE
;; Автоматически вставляет при вводе одной скобки или кавычки парную
;; ей. Если выделен регион, то в скобки обрамляется он.
(use-package elec-pair
  :config
  ;; Локализуем список парных символов
  (add-to-list 'electric-pair-pairs '(?\( . ?\))) ;; ()
  (add-to-list 'electric-pair-pairs '(?\[ . ?\])) ;; []
  (add-to-list 'electric-pair-pairs '(?{ . ?}))   ;; {}
  (add-to-list 'electric-pair-pairs '(?« . ?»))   ;; «»
  (add-to-list 'electric-pair-pairs '(?‘ . ’?))   ;; ‘’
  (add-to-list 'electric-pair-pairs '(?‚ . ‘?))   ;; ‚‘
  (add-to-list 'electric-pair-pairs '(?“ . ”?))   ;; “”)
  :hook
  ((conf-mode
    emacs-lisp-data-mode
    emacs-lisp-mode
    lisp-data-mode
    nxml-mode
    org-mode
    ruby-mode
    tex-mode) . electric-pair-local-mode))


;; 📦 FACE-REMAP
;; Настройки отображения шрифтов в графическом режиме.
(use-package face-remap
  :custom
  ;; Изменим шаг увеличения масштаба: будем добавлять или убирать по
  ;; 10%. По умолчанию — 20.
  (setq text-scale-mode-step 1.1 "Шаг увеличения масштаба"))


;; 📦 FILES
;; Это встроенный пакет для управления файлами
(use-package files
  :custom
  (delete-old-versions t "Удалять старые резервные копии файлов без лишних вопросов")
  (enable-local-eval t "Разрешить вызов `eval' в `.dir-locals.el'")
  (enable-local-variables :all "Считать все переменные из файлов `.dir-locals.el' безопасными")
  (large-file-warning-threshold (* 100 1024 1024) "Предупреждение при открытии файлов больше 100 МБ (по умолчанию — 10 МБ)")
  (make-backup-files nil "Резервные копии не нужны, у нас есть Git")
  (require-final-newline t "Требовать новую строку в конце файлов")
  (save-abbrevs 'silently "Сохранять аббревиатуры без лишних вопросов"))


;; 📦 FILL-COLUMN
;; Отображение рекомендуемой границы символов.
(use-package display-fill-column-indicator
  :hook
  ((emacs-lisp-mode) . display-fill-column-indicator-mode))


;; 📦 FLYMAKE
;; Встроенный пакет для работы со статическими анализаторами.
(use-package flymake
  :bind (:map emacs-lisp-mode-map
              ;; Перейти к следующей ошибке
              ("M-n" . flymake-goto-next-error)
              ;; Перейти к предыдущей ошибке
              ("M-p" . flymake-goto-prev-error))
  :hook ((emacs-mode
          wisent-grammar-mode) . flymake-mode))


;; 📦 FLYSPELL-MODE
;; Встроенный пакет.
;; Проверка орфографии с помощью словарей.
;; Использовать пакет только в том случае, когда дело происходит в
;; Linux и Hunspell, Aspell и Nuspell доступны.
(when (string-equal system-type "gnu/linux")
  (use-package flyspell
    :custom
    ;; Выбираем желаемую утилиту для проверки орфографии
    (ispell-program-name (cond ((file-executable-p "/usr/bin/hunspell") "hunspell")
                               ((file-executable-p "/usr/bin/aspell") "aspell")
                               ((file-executable-p "/usr/bin/nuspell") "nuspell")
                               ;; Ничего не установлено
                               (t nil)))
    :hook
    ((text-mode . flyspell-mode)
     (emacs-lisp-mode . flyspell-prog-mode))))


;; 📦 FRAME
;; Встроенный пакет.
;; Управление фреймами.
(use-package frame
  :custom
  (window-divider-default-places 't "Разделители окон со всех сторон (по умолчанию только справа)")
  (window-divider-default-right-width 3  "Ширина в пикселях для линии-разделителя окон")
  (frame-resize-pixelwise t "Размер фреймов изменять по пикселям а не по символам")
  :bind
  (:map global-map
        ("C-x O" . previous-window-any-frame) ;; Перейти в предыдущее окно
        ;; Перейти в следующее окно
        ("C-x o" . next-window-any-frame)
        ("M-o" . next-window-any-frame)))


;; 📦 GOTO-ADDRESS-MODE
;; Подсвечивает ссылки и позволяет переходить по ним с помощью [C-c RET].
;; Возможны варианты (зависит от основного режима).
(use-package goto-addr
  :hook
  ((emacs-lisp-mode
    html-mode
    rst-mode) . goto-address-mode))


;; 📦 IBUFFER
;; Встроенный пакет для удобной работы с буферами.
;; По нажатию F2 выводит список открытых буферов.
(use-package ibuffer
  :custom
  (ibuffer-formats '((mark      ;; Отметка
                      modified  ;; Буфер изменён?
                      read-only ;; Только чтение?
                      locked    ;; Заблокирован?
                      " "
                      (name 35 45 :left :elide) ;; Имя буфера: от 30 до 40 знаков
                      " "
                      (mode 8 -1 :left)         ;; Активный режим: от 8 знаков по умолчанию, при необходимости увеличить
                      " "
                      filename-and-process)     ;; Имя файла и процесс
                     ;; Сокращённый формат
                     (mark      ;; Отметка?
                      " "
                      (name 35 -1) ;; Имя буфера: 32 знака, при необходимости — расширить на сколько нужно
                      " "
                      filename)))  ;; Имя файла
  (ibuffer-default-sorting-mode 'filename/process "Сортировать файлы по имени / процессу")
  (ibuffer-display-summary nil "Не показывать строку ИТОГО")
  (ibuffer-eliding-string "…" "Если строка не уместилась, показать этот символ")
  (ibuffer-expert t "Не запрашивать подтверждение для опасных операций")
  (ibuffer-shrink-to-minimum-size t "Минимальный размер буфера по умолчанию")
  (ibuffer-truncate-lines nil "Не обкусывать длинные строки")
  (ibuffer-use-other-window t "Открывать буфер *Ibuffer* в отдельном окне")
  :init
  ;; Теперь при нажатии [C-x C-b] будет не просто список буферов, а
  ;; IBuffer.
  (defalias 'list-buffers 'ibuffer "Замена стандартной функции на ibuffer."))


;; 📦 MINIBUFFER
;; Встроенный пакет для управления поведением минибуфера.
(use-package minibuffer
  :custom
  (completions-detailed t "Подробные подсказки в минибуфере"))


;; 📦 PAREN
;; Управление парными скобками.
(use-package paren
  :config
  (show-paren-mode t)) ;; Подсвечивать парные скобки


;; 📦 PIXEL-SCROLL
;; Плавная прокрутка текста. Доступна не везде.
(when (package-installed-p 'pixel-scroll)
  (use-package pixel-scroll
    :config
    (pixel-scroll-mode t)
    (pixel-scroll-precision-mode)))


;; 📦 RECENTF-MODE
;; Запоминание списка последних открытых файлов.
(use-package recentf
  :custom
  (recentf-max-saved-items 100 "Помнить последние 100 файлов")
  (recentf-save-file (locate-user-emacs-file "recentf") "Хранить список в файле .emacs.d/recentf")
  :config (recentf-mode t))


;; 📦 REPEAT-MODE
;; Этот пакет упрощает ввод некоторых команд.
(use-package repeat
  :config
  (repeat-mode t)
  :hook
  (text-mode . repeat-mode))


;; 📦 RST-MODE
;; Встроенный пакет для редактирования reStructutedText
;; https://www.writethedocs.org/guide/writing/reStructuredText/
(use-package rst
  :custom
  (rst-default-indent 3)
  (rst-indent-comment 3)
  (rst-indent-field 3)
  (rst-indent-literal-minimized 3)
  (rst-indent-width 3)
  ;; На сайте docutils написано, что правильно вот так:
  (rst-preferred-adornments '((?# over-and-under 1)
                              (?* over-and-under 1)
                              (?= simple 0)
                              (?- simple 0)
                              (?^ simple 0)
                              (?\" simple 0)))
  (rst-toc-indent 3))


;; 📦 RUBY-TS-MODE
;; Встроенный пакет для работы с Ruby.
(use-package ruby-ts-mode
  :mode
  ("\\.rb\\'"
   "Vagrantfile\\'"))


;; 📦 RUST-MODE
;; https://github.com/rust-lang/rust-mode
;; Поддержка языка Rust: https://rust-lang.org/
(use-package rust-mode
  :mode ("\\.rs\\'" . rust-mode)
  :custom
  (rust-format-on-save t "Автоматическое форматирование буфера при сохранении.")
  :config
  (add-hook 'rust-mode-hook (lambda () (setq indent-tabs-mode nil))))


;; 📦 SAVEPLACE
;; Встроенный пакет.
;; Запоминание позиции курсора в посещённых файлах.
(use-package saveplace
  :custom
  (save-place-forget-unreadable-files t "Не запоминать положение в нечитаемых файлах.")
  :config
  (save-place-mode t))


;; 📦 SAVEHIST
;; Встроенный пакет для запоминания истории команд
(use-package savehist
  :hook
  (server-done . savehist-save)
  (kill-emacs . savehist-save)
  :config
  (add-to-list 'delete-frame-functions 'savehist-save)
  (savehist-mode t))


;; 📦 SHELL-SCRIPT-MODE
;; Пакет для работы со скриптами Shell.
(use-package sh-script
  :mode
  ("\\.bash_aliases\\'" . sh-mode)
  ("\\.bashrc\\'" . sh-mode)
  ("\\.envrc\\'" . sh-mode)
  ("\\.profile\\'" . sh-mode)
  ("\\.sh\\'" . sh-mode))


;; 📦 SHELL-MODE
;; Оболочка командной строки внутри Emacs
(use-package shell
  :custom
  (shell-kill-buffer-on-exit t "Закрыть буфер, если работа завершена."))


;; 📦 SIMPLE
;; Разные настройки управления элементарным редактированием текста.
(use-package simple
  :custom
  (backward-delete-char-untabify-method 'hungry "Удалять все символы выравнивания при нажатии [Backspace]")
  (blink-matching-paren t "Мигать, когда скобки парные")
  (indent-tabs-mode nil "Отключить `indent-tabs-mode'.")
  (kill-do-not-save-duplicates t "Не добавлять строку в kill-ring, если там уже есть такая же")
  (save-interprogram-paste-before-kill t "Сохранять данные в kill ring перед попаданием нового фрагмента")
  (size-indication-mode nil "Не показывать размера буфера в mode-line")
  (suggest-key-bindings t "Показывать подсказку клавиатурной комбинации для команды")
  :config
  (keymap-global-unset "<insert>" t) ;; Режим перезаписи не нужен
  (disable-command 'overwrite-mode)
  :bind
  (:map global-map
        ("C-z" . undo)) ;; Отмена на Ctrl+Z
  :hook
  (compilation-mode . visual-line-mode)
  (markdown-mode . visual-line-mode)
  (messages-buffer-mode . visual-line-mode)
  (text-mode . visual-line-mode))


;; 📦 UNIQUIFY
;; Встроенный пакет.
;; Используется для поддержания уникальности названий буферов, путей и т. д.
(use-package uniquify
  :custom
  (uniquify-buffer-name-style 'forward "Показывать каталог перед именем файла, если буферы одинаковые (по умолчанию имя<каталог>)")
  (uniquify-separator "/" "Разделять буферы с похожими именами, используя /"))


;; 📦 WHITESPACE MODE
;; Отображение невидимых символов.
;; Выключите или закомментируйте, если не используете.
(use-package whitespace
  :custom
  (whitespace-display-mappings ;; Отображение нечитаемых символов
   '((space-mark   ?\    [?\xB7]     [?.])        ;; Пробел
     (space-mark   ?\xA0 [?\xA4]     [?_])        ;; Неразрывный пробел
     (newline-mark ?\n   [?¶ ?\n]    [?$ ?\n])    ;; Конец строки
     (tab-mark     ?\t   [?\xBB ?\t] [?\\ ?\t]))) ;; TAB
  (whitespace-line-column 1000 "По умолчанию подсвечиваются длинные строки. Не надо этого делать.")
  :hook
  ((emacs-lisp-mode
    sh-mode
    sql-mode
    tex-mode) . whitespace-mode))


;; 📦 WHICH-KEY MODE
;; https://elpa.gnu.org/packages/which-key.html
;; Показывает подсказки к сочетаниям клавиш.
(use-package which-key
  :ensure t ;; В новых версиях Emacs этот пакет встроенный
  :custom
  (which-key-compute-remaps t "Выводить актуальные сочетания клавиш, а не «как должно быть»")
  (which-key-dont-use-unicode nil "Используем Unicode")
  (which-key-idle-delay 2 "Задержка появления подсказки")
  (which-key-idle-secondary-delay 0.05 "Ещё одна задержка появления подсказки")
  (which-key-lighter nil "Справимся и так, не надо ничего показывать в строке статуса.")
  (which-key-separator " → " "Разделитель сочетаний и команд")
  (which-key-show-major-mode t "То же самое что и [C-h m], но в формате which-key")
  :config
  (which-key-mode t))


;; 📦 WINDMOVE
;; Перемещение между окнами Emacs.
;;
;; Ctrl + → — окно справа от текущего
;; Ctrl + ← — окно слева от текущего
;; Ctrl + ↓ — окно снизу от текущего
;; Ctrl + ↑ — окно сверху от текущего
(use-package windmove
  :config
  (windmove-default-keybindings 'ctrl)
  (windmove-swap-states-default-keybindings 'meta)
  (windmove-mode t))


;; 📦 WINDOW
;;
;; Переключение между буферами как между вкладками в браузере:
;;
;; Ctrl + TAB         — предыдущий буфер
;; Ctrl + Shift + Tab — следующий буфер
(use-package window
  :custom
  (window-resize-pixelwise t "Делить окна по пикселям, а не по символам.")
  :bind
  (:map global-map
        ("C-S-<iso-lefttab>" . next-buffer)
        ("C-<tab>" . previous-buffer)))


;; 📦 XML
;; Встроенный пакет для работы с диалектами XML
(use-package xml
  :custom
  (nxml-attribute-indent 4 "Выравнивание атрибутов")
  (nxml-auto-insert-xml-declaration-flag nil "Не вставлять декларацию")
  (nxml-bind-meta-tab-to-complete-flag t "Использовать TAB для завершения ввода")
  (nxml-child-indent 4 "Выравнивание дочерних элементов")
  (nxml-slash-auto-complete-flag t "Закрывать теги по вводу /")
  :mode
  ("\\.pom\\'"
   "\\.xml\\'"))

(load-theme 'deeper-blue)

(provide 'init.el)
;;; init.el ends here
(put 'overwrite-mode 'disabled t)
