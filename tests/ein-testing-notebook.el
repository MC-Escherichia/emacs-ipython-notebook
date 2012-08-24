;;; ein-testing-notebook.el --- Testing utilities for notebook module

;; Copyright (C) 2012 Takafumi Arakaki

;; Author: Takafumi Arakaki <aka.tkf at gmail.com>

;; This file is NOT part of GNU Emacs.

;; ein-testing-notebook.el is free software: you can redistribute it
;; and/or modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation, either version 3 of
;; the License, or (at your option) any later version.

;; ein-testing-notebook.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ein-testing-notebook.el.
;; If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'ein-notebook)

(defun ein:testing-notebook-from-json (json-string &optional notebook-id)
  (unless notebook-id (setq notebook-id "NOTEBOOK-ID"))
  (flet ((pop-to-buffer (buf) buf)
         (ein:notebook-start-kernel (notebook)))
    (let ((notebook (ein:notebook-new "DUMMY-URL" notebook-id)))
      (setf (ein:$notebook-kernel notebook)
            (ein:kernel-new 8888 "/kernels" (ein:$notebook-events notebook)))
      (ein:notebook-request-open-callback
       notebook :data (ein:json-read-from-string json-string))
      (ein:notebook-buffer notebook))))

(defun ein:testing-notebook-make-data (cells &optional name)
  (unless name (setq name "Dummy Name"))
  `((metadata . ((name . ,name)))
    (nbformat . 2)
    (name . ,name)
    (worksheets . [((cells . ,(apply #'vector cells)))])))

(defun ein:testing-notebook-make-new (&optional name notebook-id)
  "Make new notebook.  One empty cell is inserted automatically."
  (ein:testing-notebook-from-json
   (json-encode (ein:testing-notebook-make-data nil name)) notebook-id))

(defun ein:testing-notebook-make-empty (&optional name notebook-id)
  "Make empty notebook and return its buffer.
Automatically inserted cell for new notebook is deleted."
  (let ((buffer (ein:testing-notebook-make-new name notebook-id)))
    (with-current-buffer buffer
      (call-interactively #'ein:worksheet-delete-cell))
    buffer))

(defmacro ein:testing-with-one-cell (cell-type &rest body)
  "Insert new cell of CELL-TYPE in a clean notebook and execute BODY.
The new cell is bound to a variable `cell'."
  (declare (indent 1))
  `(with-current-buffer (ein:testing-notebook-make-empty)
     (let ((cell (ein:worksheet-insert-cell-below ein:%worksheet%
                                                  ,cell-type nil t)))
       ,@body)))

(provide 'ein-testing-notebook)

;;; ein-testing-notebook.el ends here
