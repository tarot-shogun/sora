set SRC_FILE=sorachat
set DST_FILE=catsme

REM There are also replaced keywords
set SRC_KEY1=%SRC_FILE%
set DST_KEY1=%DST_FILE%

set SRC_KEY2=SoraChat
set DST_KEY2=CatsMe

Echo "Copy target"
mkdir ..\%DST_FILE%
REM Wait copy complete because copy / xcopy is asynchronous
robocopy /S /E /MIR ..\%SRC_FILE%\ ..\%DST_FILE%\

Echo "Rename directory name"
rename ..\%DST_FILE%\%SRC_FILE% %DST_FILE%
rename ..\%DST_FILE%\%SRC_FILE%.code-workspace %DST_FILE%.code-workspace
rename ..\%DST_FILE%\%DST_FILE%\%SRC_FILE%.py %DST_FILE%.py
rename ..\%DST_FILE%\tests\test_%SRC_FILE%.py test_%DST_FILE%.py

Echo "Replace contents"
replacetool.py ..\%DST_FILE% %SRC_KEY1% %DST_KEY1%
replacetool.py ..\%DST_FILE% %SRC_KEY2% %DST_KEY2%

pause
