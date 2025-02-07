(in-package #:maparray)

(declaim (inline make-arraymap arraymap-a arraymap-offset))
(defstruct arraymap
  (a * :type (simple-array fixnum (*)))
  (offset 0 :type fixnum))

(defconstant +array-length+ (* 1024 1024 4))

(defun map-array-displace ()
  (let ((a (mem-array (the fixnum +array-length+))))
    (dotimes (i (the fixnum (truncate (length a) 4)))
      (let ((map (mem-array 4 a (the fixnum (* i 4)))))
        (dotimes (i 4)
          (setf (aref map i) i))))
    (mem-array 20 a 562)))

(defun map-array-cons ()
  (let* ((a (mem-array (the fixnum (the fixnum +array-length+))))
         (map (cons a 0)))
    (declare (type (cons (simple-array fixnum (*)) fixnum) map))
    (dotimes (i (the fixnum (truncate (length a) 4)))
      (setf (cdr map) (the fixnum (* i 4)))
      (dotimes (i 4)
        (setf (aref (car map) (+ (the fixnum (cdr map)) i)) i)))
    (mem-array 20 a 562)))

(defun map-array-struct-alloc ()
  (let* ((a (mem-array (the fixnum (the fixnum +array-length+)))))
    (dotimes (i (the fixnum (truncate (length a) 4)))
      (let ((map #+ecl (si:make-structure 'arraymap a (the fixnum (* i 4)))
                 #-ecl (make-arraymap :a a :offset (the fixnum (* i 4)))))
        (declare (type arraymap map)
                 (dynamic-extent map))
        (dotimes (i 4)
          (setf (aref #+ecl (si:structure-ref map 'arraymap 0) #-ecl (arraymap-a map)
                      (+ (the fixnum #+ecl (si:structure-ref map 'arraymap 1) #-ecl (arraymap-offset map)) i))
                i))))
    (mem-array 20 a 562)))

(defun map-array-struct-setf ()
  (let* ((a (mem-array (the fixnum (the fixnum +array-length+))))
         (map #+ecl (si:make-structure 'arraymap a 0)
              #-ecl (make-arraymap :a a :offset 0)))
    (declare (type arraymap map)
             (dynamic-extent map))
    (dotimes (i (the fixnum (truncate (length a) 4)))
      (setf (arraymap-offset map) (the fixnum (* i 4)))
      (dotimes (i 4)
        (setf (aref #+ecl (si:structure-ref map 'arraymap 0) #-ecl (arraymap-a map)
                    (+ (the fixnum #+ecl (si:structure-ref map 'arraymap 1) #-ecl (arraymap-offset map)) i))
              i)))
    (mem-array 20 a 562)))

(defun map-array-macro ()
  (let* ((a (mem-array (the fixnum (the fixnum +array-length+)))))
    (with-map-array map a 0
      (dotimes (i (the fixnum (truncate (length a) 4)))
        (set-offset map (the fixnum (* 4 i)))
        (dotimes (j 4)
          (setf (refm map j) j))))
    (mem-array 20 a 562)))

(defun map-array-offset ()
  (let ((a (mem-array (the fixnum (the fixnum +array-length+)))))
    (dotimes (i (length a))
      (setf (aref a i) (mod i 4)))
    (mem-array 20 a 562)))

(defun main ()
  (tg:gc :full t)
  (format t "~%~%(map-array-displace)~%")
  (trivial-benchmark:with-timing (100)
    (map-array-displace))

  (tg:gc :full t)
  (format t "~%~%(map-array-cons)~%")
  (trivial-benchmark:with-timing (100)
    (map-array-cons))

  (tg:gc :full t)
  (format t "~%~%(map-array-struct-alloc)~%")
  (trivial-benchmark:with-timing (100)
    (map-array-struct-alloc))

  (tg:gc :full t)
  (format t "~%~%(map-array-struct-setf)~%")
  (trivial-benchmark:with-timing (100)
    (map-array-struct-setf))

  (tg:gc :full t)
  (format t "~%~%(map-array-macro)~%")
  (trivial-benchmark:with-timing (100)
    (map-array-macro))

  (tg:gc :full t)
  (format t "~%~%(map-array-offset)~%")
  (trivial-benchmark:with-timing (100)
    (map-array-offset)))
