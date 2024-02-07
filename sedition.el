;;; sedition.el --- Vi-like Sed Commands in Emacs without Evil -*- lexical-binding:t -*-

;; Author Olivia Lucca Fraser <lucca.fraser@gmail.com>
;; Version: 0.1
;; Keywords: sed, regexp, ex, vi, vim
;; URL: https://github.com/oblivia-simplex/emacs-sedition

;;; Commentary:

;; This package lets you issue sed commands to act on the currently active
;; region or buffer, more or less like you can in Vi with ex commands like

;; and so on.  The work behind the scenes is all being done by sed, so you'll
;; need to have the sed tool installed.  (On Unixy systems this won't be an
;; issue, generally speaking.)

;;; Code:

(defvar sedition--command-history nil
  "History list for `sed/pipe-region'.")

;;;###autoload
    (defun sedition-dwim (&optional region-beginning region-end)
      "Pipe the contents of the region to the shell command sed.
When called interactively, `REGION-BEGINNING' and `REGION-END'
refer to the beginning and end points of the active region.
If no region is active, they are set to the beginning and end of
the current buffer."
      (interactive "r")
      (let* ((prompt (if (use-region-p)
    		     (format "sed (region %d-%d): " region-beginning region-end)
    		   "sed buffer: "))
    	 (start (if (use-region-p) region-beginning (point-min)))
    	 (end (if (use-region-p) region-end (point-max)))
    	 (command (read-string prompt nil 'sed--command-history))
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
    	  (t (message "sed: exited with code %d" exitcode))
    	  )
        (kill-buffer tmpbuffer)))

(provide 'sedition)
;;; sedition.el ends here
