(setq website-name "ml-2020")

(setq website-preview-port 4701)

(setq website-sources (expand-file-name "~/Sites/ml-2020"))
(setq slash (if (equal (substring website-sources -2 -1) "/") "" "/"))
(setq website-dest (concat website-sources slash "_site"))

(setq website-deploy "adolfo@ict4g.net:/srv/http/datascientia_education/ml-2020")

(setq content (concat website-name "-content"))
  (setq assets (concat website-name "-assets"))

  (setq project-specification
        `((,website-name
           :components (,content ,assets))

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
           :html-postamble "<p class=\"date\">Last modification: %C</p>
<p class=\"date\">Created on: %d</p>"
           )

          (,assets
           :base-directory ,website-sources
           :publishing-directory ,website-dest
           :publishing-function org-publish-attachment
           :base-extension "woff\\|ttf\\|txt\\|css\\|js\\|png\\|svg\\|jpg\\|gif\\|xml\\|atom\\|gz"
           :exclude "\\(.git\\|_site\\|^_.*\\|.*~\\)"
           :recursive t
           )
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

(defun website-server-start ()
  (interactive)
  (let* ( (webserver (completing-read "Website to start previewing: " (mapcar (lambda (x) (car x)) website-spec-alist)))
          (port (plist-get (cdr (assoc webserver website-spec-alist)) :port))
          (dir (plist-get (cdr (assoc webserver website-spec-alist)) :dir)) )
    (progn
      (elnode-start 
       (elnode-webserver-handler-maker dir)
       :port port 
       :host "localhost")
      (message "Started serving directory %s on port %s" dir port))))

(defun website-server-stop ()
  (interactive)
  (let* ( (webserver (completing-read "Website to stop previewing: " (mapcar (lambda (x) (car x)) website-spec-alist)))
          (port (plist-get (cdr (assoc webserver website-spec-alist)) :port)) )
       (elnode-stop port)))

(defun website-deploy ()
  (interactive)
  (let* ( (webserver (completing-read "Website to deploy: " (mapcar (lambda (x) (car x)) website-spec-alist)))
          (local-dir (plist-get (cdr (assoc webserver website-spec-alist)) :dir))
          (deploy-dir (plist-get (cdr (assoc webserver website-spec-alist)) :deploy-dir)) )
    (if deploy-dir
        (start-process "process-name"
                       (get-buffer-create (concat "*rsync-buffer for " webserver "*"))
                       "/usr/bin/rsync"
                       "-crvz"
                       "--exclude=*~"
                       "--exclude=.git"
                       "--exclude=_*"
                       "--delete"
                       "--delete-excluded"
                       local-dir
                       deploy-dir)
      (message "No deployment command specified for %s" webserver))))
