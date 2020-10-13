(setq website-name "cl-2020")

(setq website-preview-port 4701)

(setq website-sources (expand-file-name "~/Sites/cl-2020/"))
;; (setq website-dest (concat (file-name-as-directory website-sources) "_site/"))
(setq website-dest website-sources)

(setq website-deploy "adolfo@ict4g.net:/srv/http/datascientia_education/cl-2020")

(setq content (concat website-name "-content"))
  (setq assets (concat website-name "-assets"))

  (setq website-menu
        '((nil                  . "CL-2020")
          ("welcome.html"       . "Welcome")
          ("news.html"          . "News")
          ("instructions.html"  . "Instructions")
          ("calendar.html"      . "Calendar and Material")
          ("syllabus.html"      . "Syllabus")
          ("exam.html"          . "Examination and Grading")
          ("q-and-a.html"       . "Questions and Answers")
          ("opportunities.html" . "Collaboration Opportunities")
          ("contacts.html"      . "Contacts")))

  (defun cl-2020-preamble (x)
         (apply 'concat
                (mapcar (lambda (x) (if (car x)
                                        (concat "<a href=\"" (car x) "\">" (cdr x) "</a>")
                                      (concat "<span class=\"title\">" (cdr x) "</span>")))
                        website-menu)))

  (setq project-specification
        `((,website-name
           ;; :components (,content ,assets))
           :components (,content ))

          (,content
           :base-directory ,website-sources
           :publishing-directory ,website-dest
           :publishing-function org-html-publish-to-html
           :base-extension "org"
           :exclude "\\(.git\\|_site\\|^_.*\\|.*~\\)"
           :recursive t

           :html-doctype "html5"
           :section-numbers nil
           :with-toc nil
           :with-broken-links nil
           :html-head-include-default-style nil
           :html-head-include-scripts nil

           :html-head "<link rel=\"stylesheet\" href=\"assets/css/main.css\">"
           :html-preamble cl-2020-preamble
           :html-postamble "<p class=\"date\">Last modification: %C</p>
<p class=\"date\">Created on: %d</p>"
           )

          ;; (,assets
          ;;  :base-directory ,website-sources
          ;;  :publishing-directory ,website-dest
          ;;  :publishing-function org-publish-attachment
          ;;  :base-extension "pdf\\|mp4\\|woff\\|ttf\\|txt\\|css\\|js\\|png\\|svg\\|jpg\\|gif\\|xml\\|atom\\|gz"
          ;;  :exclude "\\(.git\\|_site\\|^_.*\\|.*~\\)"
          ;;  :recursive t
          ;;  )
           ))

(let ( (components (mapcar (lambda (x) (car x)) project-specification)) )
  (mapcar 
     (lambda (x) (setq org-publish-project-alist (assoc-delete-all x org-publish-project-alist)))
     components))

(setq org-publish-project-alist (append project-specification org-publish-project-alist))

(if (not (boundp (quote website-spec-alist)))
  (setq website-spec-alist nil))

(setq website-spec-alist
      (cons (cons website-name `(:port ,website-preview-port :dir ,website-dest :deploy-dir ,website-deploy))
            website-spec-alist))

(require 'elnode nil t)

(defalias 'website-build 'org-publish)

(defun website-server-start ()
  "Ask for a project name and start previewing it"
  (interactive)
  (let* ( (project-name (completing-read "Website to start previewing: " (mapcar (lambda (x) (car x)) website-spec-alist))) )
    (website-server-start-ll project-name)))

(defun website-server-start-ll (project-name)
  "Start previewing a project whose name is passed as argument"
  (let ( (port (plist-get (cdr (assoc project-name website-spec-alist)) :port))
         (dir (plist-get (cdr (assoc project-name website-spec-alist)) :dir)) )
    (progn
      (elnode-start 
       (elnode-webserver-handler-maker dir)
       :port port 
       :host "localhost")
      (message "Started serving directory %s on port %s" dir port))))

(defun website-server-stop ()
  "Stop previewing a project"
  (interactive)
  (let* ( (project-name (completing-read "Website to stop previewing: " (mapcar (lambda (x) (car x)) website-spec-alist))) )
    (website-server-stop-ll project-name)))

(defun website-server-stop-ll (project-name)
  "Stop previewing a project passed as argument"
  (let ( (port (plist-get (cdr (assoc project-name website-spec-alist)) :port)) )
    (elnode-stop port)))

(defun website-deploy ()
  (interactive)
  (let* ( (webserver (completing-read "Website to deploy: " (mapcar (lambda (x) (car x)) website-spec-alist)))
          (local-dir (plist-get (cdr (assoc webserver website-spec-alist)) :dir))
          (deploy-dir (plist-get (cdr (assoc webserver website-spec-alist)) :deploy-dir))
          (buffer (get-buffer-create (concat "*rsync-buffer for " webserver "*"))) )
    (if deploy-dir
        (progn
          (display-buffer buffer)
          (start-process "process-name"
                         buffer
                         "/usr/bin/rsync"
                         "-crvz"
                         "--exclude=*~"
                         "--exclude=*.org"
                         "--exclude=.gitignore"
                         "--exclude=.git"
                         "--exclude=_*"
                         "--delete"
                         "--delete-excluded"
                         (file-name-as-directory local-dir) ; add a final slash (otherwise local-dir might be created on the server instead)
                         deploy-dir))
          (message "No deployment command specified for %s" webserver))))
