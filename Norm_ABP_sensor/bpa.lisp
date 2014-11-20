;;;; bp artifact DBN testing/working code
;;;; Norm Aleks 2007-06-05
;;;; edited 2008-07-02 to remove 11-blood-draws stuff, which is now in its own directory
;;;; $Header: /Users/norm/icu/models/bpa/lisp/RCS/bpa.lisp,v 1.4 2008/07/05 13:20:34 norm Exp $

;;;; To use:  edit the defparameter line below, load aima.lisp, load this file.
;;;; Then, try (bpa-run 1 100).

;;;; ------------------------------------------------------------------------------------------
;;;; None of this will work any more because I've taken the pgsql "Mick" database off this Mac.
;;;; ------------------------------------------------------------------------------------------


(defparameter *bp-model-dir* "/Users/norm/icu/models/bpa")

(defparameter *bpa*
  (load-bn (format NIL "~A/~A" *bp-model-dir* "lisp/bpa.dbn")))


;;; DATABASE READ-WRITE WRAPPER
;;; Norm 2007-07-16

;;; before using this section

(require :asdf)
(asdf:oos 'asdf:load-op :postmodern) 
(use-package :postmodern)
(connect-toplevel "icu" "norm" "" "localhost") 
(query (:select "We" "are" "connected"))

;;; use ~/icu/vis/dbgraph.lisp to graph the data you get (and see more notes there)

(defun evlist-by-name (dbn nodenames nodevalues)
  (unless (= (length nodenames) (length nodevalues))
    (error "need to supply one value per node name"))
  (loop FOR node IN (dbn-var-names dbn)
     FOR pos = (position node nodenames)
     COLLECT
       (if pos
	   (nth pos nodevalues)
	   NIL)))


(defun db-cleaned (datum)
  "NIL is replaced with :null and floats are output as strings with limited precision"
  (if (or (null datum) (float-nan-p datum))
      :null
      (format NIL "~,3F" datum)))


;;; pf-bp-dp should be more general but I got stuck in how to use doquery
;;; with an arbitary number of selected fields, and went the easy way.
;;; With CL-SQL it should be more doable but that also looked like too much
;;; work at the moment.

(defun pf-bp-dp (dbn &key (N 1000) ptid start end 
		 (type 1) (site-label "unspecified artery")
		 (ev-nodes '(observed-sys-bp observed-mean-bp observed-dia-bp))
		 (inferred-nodes '(true-sys-bp true-mean-bp true-dia-bp
                                   bag-pressure zero-pressure-time-fraction
                                   bag-pressure-time-fraction)))
  (let* ((site (query (:select 'id :from 'sites :where (:= 'label site-label)) :single))
         (query (sql 
                 (:order-by 
                  (:select 'time 'sys 'mean 'dia
                           :from 'bp-data
                           :where (:and (:= 'site site)
                                        (:= 'type type)
                                        (:= 'ptid ptid) 
                                        (:<= start 'time) 
                                        (:<= 'time end)))
                  'time)))
         results)
    (pf-init dbn :n N :queries inferred-nodes)
    (doquery query (time sys mean dia)
      (let ((result (pf-step (evlist-by-name dbn ev-nodes (list sys mean dia)))))
        (push time result)
        (push result results)
	(format t "~S~%" result)))
    (loop FOR result IN results DO
         (query (:insert-into 'bp-filtered :set
                              'ptid ptid
                              'time (first result)
                              'site site
                              'type type
                              'sys     (db-cleaned (first  (second result)))
                              'mean    (db-cleaned (first  (third result)))
                              'dia     (db-cleaned (first  (fourth result)))
                              'sys-sd  (db-cleaned (second (second result)))
                              'mean-sd (db-cleaned (second (third result)))
                              'dia-sd  (db-cleaned (second (fourth result))))))))
	

;;; to test, 
;;; (pf-bp-dp *dbn* :N 100 :ptid 1 :start (encode-timestamp 2006 2 26) :end (encode-timestamp 2006 2 26 1))
;;; ABP data for patient 1 are present for 2/21/2006 to end of 3/26 (so use 3/27/2006)


(defun long-run (&optional (N 25000))
  (loop FOR d FROM 21 TO 28 DO
       (pf-bp-dp *bpa* :N N :ptid 1 
                 :start (encode-timestamp 2006 2 d)
                 :end   (encode-timestamp 2006 2 d 23 59 59)))
  (loop FOR d FROM 1 TO 26 DO
       (pf-bp-dp *bpa* :N N :ptid 1 
                 :start (encode-timestamp 2006 3 d)
                 :end   (encode-timestamp 2006 3 d 23 59 59))))
  