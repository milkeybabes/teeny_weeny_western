@ echo off
:LOOP
if not exist %TEMP%\$shell$.bat goto NODEL
del %TEMP%\$shell$.bat
:NODEL
cr2.exe %1 %2 %3 %4 %5 %6 %7 %8 %9
if not ERRORLEVEL == 6502 goto END
call %TEMP%\$shell$.bat
goto :LOOP
:END
