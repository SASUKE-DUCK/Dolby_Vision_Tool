@echo off & setlocal
mode con cols=122 lines=57
TITLE DDVT FRAMEINFO [DonaldFaQ] v0.47 beta

rem --- Hardcoded settings. Can be changed manually ---
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "MKVEXTRACTpath=%~dp0tools\mkvextract.exe" rem Path to mkvextract.exe
set "MKVMERGEpath=%~dp0tools\mkvmerge.exe" rem Path to mkvmerge.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "HDR10Plus_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe
set "HDR10PFILE=%~dp1HDR10Plus.json"
set "RPUFILE=%~dp1RPU.bin"

rem --- Hardcoded settings. Cannot be changed ---
set MP4Extract=FALSE
set MKVExtract=FALSE
set HDR10P=FALSE
set DV=FALSE
set RAW_FILE=FALSE
set RPU_FILE=FALSE
set HDR=No HDR Infos found
set INPUTFILENAME=%~nx1
set WAIT="%sfkpath%" sleep
set GREEN="%sfkpath%" color green
set RED="%sfkpath%" color red
set YELLOW="%sfkpath%" color yellow
set WHITE="%sfkpath%" color white
set CYAN="%sfkpath%" color cyan
set MAGENTA="%sfkpath%" color magenta
set GREY="%sfkpath%" color grey
set ERRORCOUNT=0
set RESOLUTION=n.A.
set HDR=n.A.
set CODEC_NAME=n.A.
set FRAMERATE=n.A.
set FRAMES=n.A.

%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                             Dolby Vision Tool FRAMEINFO
%WHITE%
echo                                         ====================================
echo.
%WHITE%
echo.
echo.
echo  == CHECK INPUT FILE ====================================================================================================

if "%~1"=="" (
	%yellow%
	echo.
	echo No Input File. Use DDVT_FRAMEINFO.cmd "YourFilename.mkv/mp4/hevc/h265/bin"
	%WHITE%
	goto EXIT
)
	
if /i "%~x1"==".mkv" set "MKVExtract=TRUE" & goto CHECK
if /i "%~x1"==".mp4" set "MP4Extract=TRUE" & goto CHECK
if /i "%~x1"==".h265" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".hevc" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".bin" set "RPU_FILE=TRUE" & goto CHECK

%yellow%
echo.
echo File not Supported^! Only HEVC^/h265^/BIN^/MP4^/MKV files supported.
goto EXIT

:CHECK
set "VIDEOSTREAM=%~1"
"%MEDIAINFOpath%" --output=Video;%%Width%%x%%Height%% %1>"%TEMP%\Info.txt"
set /p RESOLUTION=<"%TEMP%\Info.txt"
"%MEDIAINFOpath%" --output=Video;%%HDR_Format/String%% %1>"%TEMP%\Info.txt"
if "%RESOLUTION%"=="3840x21601920x1080" set "RESOLUTION=3840x2160 DL"
set /p HDR=<"%TEMP%\Info.txt"
"%MEDIAINFOpath%" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% %1>"%TEMP%\Info.txt"
set /p CODEC_NAME=<"%TEMP%\Info.txt"
if "%CODEC_NAME%"=="HEVC-10Bit-YUV-4:2:0HEVC-10Bit-YUV-4:2:0" set "CODEC_NAME=HEVC-10Bit-YUV-4:2:0"
"%MEDIAINFOpath%" --output=Video;%%FrameRate%% %1>"%TEMP%\Info.txt"
set /p FRAMERATE=<"%TEMP%\Info.txt"
if "%FRAMERATE%"=="23.97623.976" set "FRAMERATE=23.976"
if "%FRAMERATE%"=="24.00024.000" set "FRAMERATE=24.000"
"%MEDIAINFOpath%" --output=Video;%%FrameCount%% %1>"%TEMP%\Info.txt"
set /p FRAMES=<"%TEMP%\Info.txt"
del /y "%TEMP%\Info.txt">nul

:START
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                             Dolby Vision Tool FRAMEINFO
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == VIDEO INPUT =========================================================================================================
echo.
%CYAN%
echo Filename   = [%INPUTFILENAME%]
echo Video Info = [Resolution = %RESOLUTION%] [Codec = %CODEC_NAME%] [Frames = %FRAMES%] [FPS = %FRAMERATE%]
echo HDR Info   = [%HDR%]
echo.
if "%RESOLUTION%"=="3840x2160 DL" (
	%yellow%
	echo No Support for Double Layer Profile 7 File^! 
	echo Abort Operation now.
	goto EXIT
)
echo "%HDR%" | find "dvhe.">nul 2>&1
if "%RAW_FILE%"=="FALSE" if "%RPU_FILE%"=="FALSE" (
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Stream contains Dolby Vision.
	) else (
		%RED%
		echo No Dolby Vision Infos found.
		goto exit
	)
)
	
:DV_INFO
echo.
%WHITE%
echo == FRAME INFO ==========================================================================================================
echo.
echo Type in the Frame.
echo Example: For Frame Info of Frame 1000 type in 1000^!
echo.
set /p "FRAME=Type in the Frame and press [ENTER]: "
echo.
set "REALFRAME=%FRAME%"
if "%FRAME%"=="0" set "REALFRAME=1"
set /a "FRAME=%FRAME%"
set /a "FRAME=%FRAME%-1"
if "%FRAME%"=="-1" set "FRAME=0"
if "%RAW_FILE%"=="TRUE" goto RPU_EXTRACT
if "%RPU_FILE%"=="TRUE" goto WRITE_INFO
echo.

:DEMUX
%WHITE%
echo == DEMUXING ============================================================================================================
echo.
%YELLOW%
echo ATTENTION^! You need many HDD Space for this operation.
echo.
if not exist "%~dpn1_[TEMP]" md "%~dpn1_[TEMP]"
%CYAN%
echo Please wait. Extracting the Video Layer ...
if "%MKVExtract%"=="TRUE" "%MKVEXTRACTpath%" "%~1" tracks 0:"%~dpn1_[TEMP]\temp.hevc"
if "%MP4Extract%"=="TRUE" "%MP4BOXpath%" -raw 1 -out "%~dpn1_[TEMP]\temp.hevc" "%~1"
set "VIDEOSTREAM=%~dpn1_[TEMP]\temp.hevc"
if exist "%~dpn1_[TEMP]\temp.hevc" (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
	echo.
)

:RPU_EXTRACT
%WHITE%
echo  == EXTRACTING RPU ======================================================================================================
echo.
%CYAN%
echo Please wait. Extracting the RPU Metadata Binary ...
if not exist "%~dpn1_[TEMP]" md "%~dpn1_[TEMP]"
"%DO_VI_TOOLpath%" extract-rpu "%VIDEOSTREAM%" -o "%~dpn1_[TEMP]\RPU.bin"
if exist "%~dpn1_[TEMP]\RPU.bin" (
	set RPUFILE=%~dpn1_[TEMP]\RPU.bin
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
	echo.
)

:WRITE_INFO
%WHITE%
if "%Frame%"=="0" set "Frame=00"
if "%Frame%"=="1" set "Frame=01"
if "%Frame%"=="2" set "Frame=02"
if "%Frame%"=="3" set "Frame=03"
if "%Frame%"=="4" set "Frame=04"
if "%Frame%"=="5" set "Frame=05"
if "%Frame%"=="6" set "Frame=06"
if "%Frame%"=="7" set "Frame=07"
if "%Frame%"=="8" set "Frame=08"
if "%Frame%"=="9" set "Frame=09"
echo  == WRITE INFO ==========================================================================================================
echo.
%CYAN%
echo Write Infos from Frame %REALFRAME% to^:
%WHITE%
echo "%~dp1
echo %~n1_[Frame %REALFRAME% Info].json"
%CYAN%
"%DO_VI_TOOLpath%" info -i "%RPUFILE%" -s>"%~dpn1_[Frame %REALFRAME% Info].json"
"%DO_VI_TOOLpath%" info -i "%RPUFILE%" -f %Frame%>>"%~dpn1_[Frame %REALFRAME% Info].json"
echo.
echo Please wait. Cleaning and Moving files ...
if exist "%~dpn1_[TEMP]" (
	RD /S /Q "%~dpn1_[TEMP]">nul
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting TEMP folder - Done.
	) else (
		%RED%
		echo Deleting TEMP folder - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)

echo.
if "%ERRORCOUNT%"=="0" (
	%GREEN%
	echo All Operations successful.
) else (
	%RED%
	echo SOME Operations failed.
)
goto exit

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
TIMEOUT 30
exit