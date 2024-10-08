(defun c::nav ()
  (textscr)  
  (setq *home-dir* (getenv "USERPROFILE"))  
  (setq *current-dir* (if (getvar "DWGNAME")
                          (getvar "DWGPREFIX")
                          *home-dir*))  
  (princ (strcat "\nInitial directory: " *current-dir*))
  (while t
    (setq input (getstring "\nEnter command (cd, .., ls, openfile, opendir, exit): " T))
    (setq input-list (vl-string->list input " "))
    (setq command (car input-list))
    (setq arg (apply 'strcat (mapcar (function (lambda (x) (strcat x " "))) (cdr input-list))))
    (setq arg (vl-string-trim " " arg))
    (cond
      ((equal command "cd")
        (setq arg (vl-string-trim " " arg))
        (if (vl-string-search ":\\" arg)
          (setq full-path arg)
          (setq full-path (vl-filename-makepath *current-dir* arg))
        )
        (if (equal arg "~")
          (setq full-path *home-dir*)
        )

        (if (vl-directory-files full-path nil -1)
          (progn
            (setq *current-dir* full-path)
            (princ (strcat "\nCurrent directory: " *current-dir*))
          )
          (princ "\nInvalid directory")
        )
      )
      ((equal command "..")
        (setq parent-dir (vl-filename-directory *current-dir*))
        (if (and parent-dir (not (equal parent-dir "")))
          (progn
            (setq *current-dir* parent-dir)
            (princ (strcat "\nCurrent directory: " *current-dir*))
          )
          (princ "\nAlready at the root directory")
        )
      )
      ((equal command "ls")
        (if *current-dir*
          (progn
            (foreach item (vl-directory-files *current-dir* nil 0)
              (princ (strcat "\n" item))
            )
          )
          (princ "\nNo directory set")
        )
      )
      ((equal command "openfile")
        (setq full-path (vl-filename-makepath *current-dir* arg))
        (if (findfile full-path)
          (command "_.OPEN" full-path)
          (princ "\nFile not found in current directory")
        )
      )
      ((equal command "opendir")
        (startapp "explorer" *current-dir*)
      )
      ((equal command "exit")
        (princ "\nExiting navigation mode.")
        (exit)
      )
      (t (princ "\nInvalid command"))
    )
    (princ)
  )
)

(defun vl-filename-makepath (path filename)
  (if (or (= (substr path (strlen path)) "\\")
          (= (substr path (strlen path)) "/"))
      (strcat path filename)
      (strcat path "\\" filename))
)

(defun vl-string->list (str delim)
  (if (not (vl-string-search delim str))
    (list str)
    (cons (substr str 1 (vl-string-search delim str))
          (vl-string->list (substr str (+ (vl-string-search delim str) 2)) delim))
  )
)

(defun vl-string-trim (chars str)
  (vl-string-right-trim chars (vl-string-left-trim chars str))
)

(setq *home-dir* (getenv "USERPROFILE"))  
(setq *current-dir* (if (getvar "DWGNAME")
                        (getvar "DWGPREFIX")
                        *home-dir*))  
(princ (strcat "\nInitial directory: " *current-dir*))
