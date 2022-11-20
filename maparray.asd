#+sb-core-compression
(defmethod asdf:perform ((o asdf:image-op) (c asdf:system))
  (uiop:dump-image (asdf:output-file o c) :executable t :compression t))

(defsystem maparray
  :version "1.0.0"
  :author "Bohong Huang <1281299809@qq.com>"
  :maintainer "Bohong Huang <1281299809@qq.com>"
  :license "mit"
  :description "Simple program to test the performance of array mapping"
  :homepage "https://github.com/bohonghuang/maparray"
  :build-operation program-op
  :source-control (:git "git@github.com:bohonghuang/maparray.git")
  :around-compile (lambda (next)
                    (proclaim '(optimize
                                (compilation-speed 0)
                                (safety 0)
                                (debug 0)
                                (speed 3)))
                    (funcall next))
  :components ((:file "package")
               (:file "macro" :depends-on ("package"))
               (:file "maparray" :depends-on ("macro")))
  :build-pathname "maparray"
  :entry-point "maparray:main"
  :depends-on (:asdf :trivial-garbage))
