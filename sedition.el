;;; sedition.el --- Vi-like Sed Commands without Evil

;; Author Olivia Lucca Fraser <lucca.fraser@gmail.com>
;; Version: 0.1
;; Keywords: convenience, matching, tools, unix
;; URL: https://github.com/oblivia-simplex/emacs-sedition

;;; Commentary:

;; This package lets you issue sed commands to act on the currently active
;; region or buffer, more or less like you can in Vi with ex commands like
;; :%s/foo/bar/g
;; :'<,'>s/foo/bar/g
;; and so on.  The work behind the scenes is all being done by sed, so you'll
;; need to have the sed tool installed.  (On Unixy systems this won't be an
;; issue, generally speaking.)
;;
;; See the README.org at https://github.com/oblivia-simplex/emacs-sedition/
;; for more details.

;;; Code:

(defvar sedition--command-history nil
  "History list for `sed/pipe-region'.")

;;;###autoload
    (defun sedition ()
      "Pipe the contents of the region to the shell command sed.
When called interactively, `REGION-BEGINNING' and `REGION-END'
refer to the beginning and end points of the active region.
If no region is active, they are set to the beginning and end of
the current buffer."
      (interactive)
      (let* ((in-region (use-region-p))
	     (start (if in-region (region-beginning) (point-min)))
	     (end (if in-region (region-end) (point-max)))
	     (prompt (if in-region
    			 (format "sed (region %d-%d): " start end)
    		       "sed buffer: "))
    	     (command (read-string prompt nil 'sedition--command-history))
    	 ;; generate-new-buffer will create a unique name with this prefix
    	 ;; the initial space hides it from list-buffers and buffer-menu
    	 ;; commands
    	 (tmpbuffer (generate-new-buffer " *sed*"))
    	 (exitcode (call-process-region start
    					end
    					"sed"
    					nil ;; don't delete anything yet
    					tmpbuffer
    					t
    					command)))
        ;; We only want to perform any action on the region/buffer
        ;; if the command succeeded, so check the exit code here.
        (cond ((zerop exitcode)
    	   (delete-region start end)
    	   (goto-char start)
    	   (insert-buffer-substring tmpbuffer))
    	  ((= exitcode 127)
    	   (message "sed: command not found"))
    	  ((= exitcode 1)
    	   (message "sed: error in command '%s'" command))
    	  ((stringp exitcode)
    	   (message "sed: %s" exitcode))
    	  (t (message "sed: exited with code %d" exitcode)))
        (kill-buffer tmpbuffer)))

(provide 'sedition)
;;; sedition.el ends here
