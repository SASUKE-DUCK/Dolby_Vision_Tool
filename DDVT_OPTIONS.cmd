@echo off & setlocal
mode con cols=122 lines=57
TITLE DDVT Options [DonaldFaQ] v0.47 beta

rem --- Hardcoded settings. Can be changed manually ---
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe

rem --- Hardcoded settings. Cannot be changed ---
set WAIT="%sfkpath%" sleep
set GREEN="%sfkpath%" color green
set RED="%sfkpath%" color red
set YELLOW="%sfkpath%" color yellow
set WHITE="%sfkpath%" color white
set CYAN="%sfkpath%" color cyan
set MAGENTA="%sfkpath%" color magenta
set GREY="%sfkpath%" color grey

:MAINMENU
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool OPTIONS
%WHITE%
echo                                         ====================================
echo.
%WHITE%
echo.
echo.
echo  == OPTIONS MENU ========================================================================================================
echo.
echo 1. Create Shell Extensions
echo 2. Delete Shell Extensions
echo.
echo E. Exit
echo.
%GREEN%
echo Change Settings or press [E] to Exit^!
CHOICE /C 12E /N /M "Select a Letter 1,2,[E]xit"
	
if "%Errorlevel%"=="3" goto EXIT
if "%Errorlevel%"=="2" (
	reg delete "HKCR\*\Shell\DDVT Demuxer" /f>nul 2>&1
	reg delete "HKCR\*\Shell\DDVT Injector" /f>nul 2>&1
	reg delete "HKCR\*\Shell\MenuDDVT" /f>nul 2>&1
	echo.
	%GREEN%
	echo Registry strings deleted.
	%WAIT% 1000
	goto MAINMENU	
)
if "%Errorlevel%"=="1" (
	reg delete "HKCR\*\Shell\DDVT Demuxer" /f>nul 2>&1
	reg delete "HKCR\*\Shell\DDVT Injector" /f>nul 2>&1
	reg delete "HKCR\*\Shell\MenuDDVT" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /ve /d "DDVT Tool" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /v "Icon" /t REG_SZ /d "\"%~dp0tools\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /v "ExtendedSubCommandsKey" /t REG_SZ /d "\"%~dp0tools\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /v "ExtendedSubCommandsKey" /t REG_SZ /d "*\Shell\MenuDDVT\ContextMenu" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /v "Position" /t REG_SZ /d "Top" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\01DEMUXER" /ve /d "DEMUXER" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\01DEMUXER" /v "Icon" /t REG_SZ /d "\"%~dp0tools\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\01DEMUXER\command" /ve /d "\"%~dp0DDVT_DEMUXER.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\02INJECTOR" /ve /d "INJECTOR" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\02INJECTOR" /v "Icon" /t REG_SZ /d "\"%~dp0tools\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\02INJECTOR\command" /ve /d "\"%~dp0DDVT_INJECTOR.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\03REMOVER" /ve /d "REMOVER" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\03REMOVER" /v "Icon" /t REG_SZ /d "\"%~dp0tools\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\03REMOVER\command" /ve /d "\"%~dp0DDVT_REMOVER.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\04FRAMEINFO" /ve /d "FRAMEINFO" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\04FRAMEINFO" /v "Icon" /t REG_SZ /d "\"%~dp0tools\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\04FRAMEINFO\command" /ve /d "\"%~dp0DDVT_FRAMEINFO.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\05MKVTOMP4" /ve /d "MKVTOMP4" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\05MKVTOMP4" /v "Icon" /t REG_SZ /d "\"%~dp0tools\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\05MKVTOMP4\command" /ve /d "\"%~dp0DDVT_MKVTOMP4.cmd\" ""%%1""" /f>nul 2>&1	
	echo.
	%GREEN%	
	echo Registry strings set.
	%WAIT% 1000
	goto MAINMENU
)

:colortxt
setlocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
:colorPrint Color  Str  [/n]
setlocal
set "s=%~2"
call :colorPrintVar %1 s %3
exit /b

:colorPrintVar  Color  StrVar  [/n]
if not defined DEL call :initColorPrint
setlocal enableDelayedExpansion
pushd .
':
cd \
set "s=!%~2!"
:: The single blank line within the following IN() clause is critical - DO NOT REMOVE
for %%n in (^"^

^") do (
  set "s=!s:\=%%~n\%%~n!"
  set "s=!s:/=%%~n/%%~n!"
  set "s=!s::=%%~n:%%~n!"
)
for /f delims^=^ eol^= %%s in ("!s!") do (
  if "!" equ "" setlocal disableDelayedExpansion
  if %%s==\ (
    findstr /a:%~1 "." "\'" nul
    <nul set /p "=%DEL%%DEL%%DEL%"
  ) else if %%s==/ (
    findstr /a:%~1 "." "/.\'" nul
    <nul set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%"
  ) else (
    >colorPrint.txt (echo %%s\..\')
    findstr /a:%~1 /f:colorPrint.txt "."
    <nul set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%"
  )
)
if /i "%~3"=="/n" echo(
popd
exit /b


:initColorPrint
for /f %%A in ('"prompt $H&for %%B in (1) do rem"') do set "DEL=%%A %%A"
<nul >"%temp%\'" set /p "=."
subst ': "%temp%" >nul
exit /b


:cleanupColorPrint
2>nul del "%temp%\'"
2>nul del "%temp%\colorPrint.txt"
>nul subst ': /d
exit /b

:EXIT
%WHITE%
echo.
echo  == EXIT ================================================================================================================
echo.
exit