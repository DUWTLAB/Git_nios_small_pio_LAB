@echo off

SET  top_dir=prj_q10.1


: exclude files
attrib +h %top_dir%\*.stp
attrib +h %top_dir%\*.qsf
attrib +h %top_dir%\*.qpf
attrib +h %top_dir%\*.sopc
attrib +h %top_dir%\*.sopcinfo

: delete files except exclude files
del/q /a-h %top_dir%\*.*

: delete dirs
if exist %top_dir%\db             (rd /s /q %top_dir%\db) 
if exist %top_dir%\incremental_db (rd /s /q %top_dir%\incremental_db) 
if exist %top_dir%\nios_cpu_sim   (rd /s /q %top_dir%\nios_cpu_sim) 
if exist %top_dir%\.sopc_builder  (rd /s /q %top_dir%\.sopc_builder) 


: restore exclude files
attrib -h %top_dir%\*.stp
attrib -h %top_dir%\*.qsf
attrib -h %top_dir%\*.qpf
attrib -h %top_dir%\*.sopc
attrib -h %top_dir%\*.sopcinfo


: exclude files
attrib +h %top_dir%\software\bsp\*.bsp
attrib +h %top_dir%\software\bsp\create-this-bsp

: delete files except exclude files
del/q /a-h %top_dir%\software\bsp\*.*

if exist %top_dir%\software\bsp\drivers  (rd /s /q %top_dir%\software\bsp\drivers  ) 
if exist %top_dir%\software\bsp\HAL      (rd /s /q %top_dir%\software\bsp\HAL      ) 
if exist %top_dir%\software\bsp\obj      (rd /s /q %top_dir%\software\bsp\obj      ) 

: restore exclude files

attrib -h %top_dir%\software\bsp\*.bsp
attrib -h %top_dir%\software\bsp\create-this-bsp


: exclude files
attrib +h %top_dir%\software\app\*.c
attrib +h %top_dir%\software\app\*.h
attrib +h %top_dir%\software\app\create-this-app

: delete files except exclude files
del/q /a-h %top_dir%\software\app\*.*

if exist %top_dir%\software\app\obj  (rd /s /q %top_dir%\software\app\obj  ) 

: restore exclude files
attrib -h %top_dir%\software\app\*.c
attrib -h %top_dir%\software\app\*.h
attrib -h %top_dir%\software\app\create-this-app

