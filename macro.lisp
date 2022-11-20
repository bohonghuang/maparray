(in-package #:maparray)

(defmacro mem-array (size &optional origin offset)
  `(make-array ,size
               :element-type 'fixnum
               ,@(if origin
                     `(:displaced-to
                       ,origin
                       :displaced-index-offset ,offset))))

(defun replace-refm (tree map-name array-name offset-name)
  "Offset: symbol"
  (if (consp tree)
      (if (equal 'refm (car tree))
          (if (= (length tree) 3)
              (if (equal map-name (nth 1 tree))
                  `(aref ,array-name (the fixnum
                                          (+ ,offset-name
                                             ,(nth 2 tree))))
                  nil)
              (error (format nil "refm: ~A" tree)))
          (mapcar (lambda (tree)
                    (replace-refm tree map-name
                                  array-name offset-name))
                  tree))
      tree))

(defun replace-set-offset (tree map-name offset-name)
  (if (consp tree)
      (if (equal 'set-offset (car tree))
          (if (= (length tree) 3)
              (if (equal map-name (nth 1 tree))
                  `(setf ,offset-name ,(nth 2 tree))
                  nil)
              (error (format nil "set-offset: ~A" tree)))
          (mapcar (lambda (tree)
                    (replace-set-offset tree map-name
                                        offset-name))
                  tree))
      tree))

(defmacro with-map-array (map array offset &rest body)
  (let ((offset-name (gensym)))
    `(let ((,offset-name ,offset))
       (declare (type fixnum ,offset-name))
       ,@(mapcar (lambda (tree)
                   (replace-set-offset
                    (replace-refm tree map array offset-name)
                    map offset-name))
                 body))))
