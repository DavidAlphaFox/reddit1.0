;;;; Copyright 2018 Reddit, Inc.
;;;; 
;;;; Permission is hereby granted, free of charge, to any person obtaining a copy of
;;;; this software and associated documentation files (the "Software"), to deal in
;;;; the Software without restriction, including without limitation the rights to
;;;; use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
;;;; of the Software, and to permit persons to whom the Software is furnished to do
;;;; so, subject to the following conditions:
;;;; 
;;;; The above copyright notice and this permission notice shall be included in all
;;;; copies or substantial portions of the Software.
;;;; 
;;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;;;; SOFTWARE.

(in-package :cl-user)
(defpackage reddit.recommend
  (:use :cl)
  (:import-from :cl-ppcre
                :create-scanner
                :scan-to-strings
                :split)
  (:import-from :reddit.user-info
                :user-alias)
  (:export :decode-aliases))
(in-package :reddit.recommend)


(defparameter *email-scanner* (create-scanner "^\\w*[+-._\\w]*\\w@\\w[-._\\w]*\\w\\.\\w+$"))
(defparameter *token-scanner* (create-scanner "[,;\\s]+"))

(defun is-email (str)
  (scan-to-strings *email-scanner* str))

(defun tokens (str)
  (split *token-scanner* str))

(defun email-lst (rcpts info &optional emails expanded)
  (cond ((consp rcpts)
         (email-lst (cdr rcpts) info (email-lst (car rcpts) info emails expanded) (push (car rcpts) expanded)))
        ((is-email rcpts)
         (pushnew rcpts emails :test #'string=))
        ((not (member rcpts expanded :test #'string=))
         (email-lst (tokens (user-alias info rcpts)) info emails (push rcpts expanded)))
        (t emails)))

(defun decode-aliases (str info)
  (email-lst (tokens str) info))

(defun reformat-aliases (str)
  (format nil "~{~a~^, ~}" (delete-duplicates (tokens str) :test #'string=)))
