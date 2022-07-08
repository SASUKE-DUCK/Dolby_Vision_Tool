@echo off & setlocal
mode con cols=122 lines=57
TITLE DDVT REMOVER [DonaldFaQ] v0.47 beta

rem --- Hardcoded settings. Can be changed manually ---
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "PYTHONpath=%~dp0tools\Python\Python.exe" rem Path to PYTHON exe
set "SCRIPTpath=%~dp0tools\Python\Scripts\hdr10plus_remove.py" rem Path to SCRIPT
set "MKVEXTRACTpath=%~dp0tools\mkvextract.exe" rem Path to mkvextract.exe
set "MKVMERGEpath=%~dp0tools\mkvmerge.exe" rem Path to mkvmerge.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "HDR10Plus_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe

rem --- Hardcoded settings. Cannot be changed ---
set MP4Extract=FALSE
set MKVExtract=FALSE
set RAW_FILE=FALSE
set HDR10P=FALSE
set REM_HDR10P=NO
set DV=FALSE
set REM_DV=NO
set HDR=No HDR Infos found
set INPUTFILENAME=%~nx1
set NAMESTRING=
set DVSTRING=
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
set FRAME=0.

%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool REMOVER
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
	echo No Input File. Use DDVT REMOVER.cmd "YourFilename.hevc/h265/mkv/mp4"
	%WHITE%
	goto EXIT
)

if /i "%~x1"==".hevc" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".h265" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".mkv" set "MKVExtract=TRUE" & goto CHECK
if /i "%~x1"==".mp4" set "MP4Extract=TRUE" & goto CHECK

%yellow%
echo.
echo File not Supported^! Only HEVC^/h265^/MP4^/MKV files supported.
goto EXIT

:CHECK
set "VIDEOSTREAM=%~1"
if "%RAW_FILE%"=="TRUE" "%MKVMERGEpath%" --priority higher --output ^"%TEMP%\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"%~1^" ^"^)^" --split parts:00:00:00-00:00:01 -q
"%MEDIAINFOpath%" --output=Video;%%Width%%x%%Height%% %1>"%TEMP%\Info.txt"
set /p RESOLUTION=<"%TEMP%\Info.txt"
if "%RESOLUTION%"=="3840x21601920x1080" set "RESOLUTION=3840x2160 DL"
if "%RAW_FILE%"=="TRUE" (
	pushd %tmp%
	"%MEDIAINFOpath%" --output=Video;%%HDR_Format/String%% Info.mkv>"%TEMP%\Info.txt"
	popd
) else (
	"%MEDIAINFOpath%" --output=Video;%%HDR_Format/String%% %1>"%TEMP%\Info.txt"
)
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
if exist "%TEMP%\Info.txt" del "%TEMP%\Info.txt">nul
if exist "%TEMP%\Info.mkv" del "%TEMP%\Info.mkv">nul

:START
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool REMOVER
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
echo "%HDR%" | find "dvhe.05">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	%YELLOW%
	echo Stream contains Dolby Vision Profile 5.
	echo Profile 5 cannot be removed^!
	goto exit
)
echo "%HDR%" | find "dvhe.">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "DV=TRUE"
	%GREEN%
	echo Stream contains Dolby Vision.
)
echo "%HDR%" | find "HDR10+">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "HDR10P=TRUE"
	%GREEN%
	echo Stream contains HDR10 Plus.
)
if "%HDR10P%"=="FALSE" if "%DV%"=="FALSE" (
	%YELLOW%
	echo No Dolby Vision or HDR10+ Metadata Found.
	echo Nothing to do^!
	goto exit
)
	
:START
echo.
%WHITE%
echo  == REMOVER =============================================================================================================
echo.
if "%HDR10P%"=="TRUE" echo 1. Remove HDR10 Plus Metadata   : [%REM_HDR10P%]
if "%DV%"=="TRUE" echo 2. Remove Dolby Vision Metadata : [%REM_DV%]
echo.
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^!
if "%HDR10P%"=="TRUE" if "%DV%"=="TRUE" CHOICE /C 12S /N /M "Select a Letter 1,2,[S]tart"
if "%HDR10P%"=="TRUE" if "%DV%"=="FALSE" CHOICE /C 12S /N /M "Select a Letter 1,[S]tart"
if "%HDR10P%"=="FALSE" if "%DV%"=="TRUE" CHOICE /C 12S /N /M "Select a Letter 2,[S]tart"
if "%ERRORLEVEL%"=="3" goto :DEMUX
if "%ERRORLEVEL%"=="2" (
	if "%REM_DV%"=="NO" set "REM_DV=YES"
	if "%REM_DV%"=="YES" set "REM_DV=NO"
)
if "%ERRORLEVEL%"=="1" (
	if "%REM_HDR10P%"=="NO" set "REM_HDR10P=YES"
	if "%REM_HDR10P%"=="YES" set "REM_HDR10P=NO"
)
goto START

:BEGIN
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool REMOVER
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
if "%HDR10P%"=="TRUE" echo Remove HDR10 Plus Metadata   : [%REM_HDR10P%]
if "%DV%"=="TRUE" echo Remove Dolby Vision Metadata : [%REM_DV%]

:DEMUX
if "%RAW_FILE%"=="TRUE" goto NODEMUX
%WHITE%
echo.
echo  == DEMUXING ============================================================================================================
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
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
)
goto REMOVE_HDR10+

:NODEMUX
if not exist "%~dpn1_[TEMP]" md "%~dpn1_[TEMP]"
copy "%~1" "%~dpn1_[TEMP]\temp.hevc">nul
set "VIDEOSTREAM=%~dpn1_[TEMP]\temp.hevc"

:REMOVE_HDR10+
if "%REM_HDR10P%"=="NO" goto :REMOVE_DV
%WHITE%
echo.
echo  == REMOVING HDR10+ =====================================================================================================
echo.
if "%REM_HDR10P%"=="YES" if "%HDR10P%"=="TRUE" (
	%CYAN%
	echo Please wait. Removing HDR10+ Metadata...
	PUSHD "%~dpn1_[TEMP]"
	"%PYTHONpath%" "%SCRIPTpath%" -i "%~dpn1_[temp]\temp.hevc" -o "%~dpn1_[temp]\BL_NOHDR10P.hevc"
	POPD
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
	)
)

if exist "%~dpn1_[TEMP]\temp.hevc" if "%REM_HDR10P%"=="YES" del "%~dpn1_[TEMP]\temp.hevc"
if exist "%~dpn1_[TEMP]\BL_NOHDR10P.hevc" set "VIDEOSTREAM=%~dpn1_[TEMP]\BL_NOHDR10P.hevc"

:REMOVE_DV
if "%REM_DV%"=="NO" goto POSTPROC
%WHITE%
echo.
echo  == REMOVING Dolby Vision ===============================================================================================
echo.
%CYAN%
echo Please wait. Removing Dolby Vision Metadata...
PUSHD "%~dpn1_[TEMP]"
"%DO_VI_TOOLpath%" demux "%VIDEOSTREAM%"
POPD
if "%ERRORLEVEL%"=="0" (
	%GREEN%
	echo Done.
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
)

if exist "%~dpn1_[TEMP]\EL.hevc" del "%~dpn1_[TEMP]\EL.hevc"
if exist "%~dpn1_[TEMP]\temp.hevc" del "%~dpn1_[TEMP]\temp.hevc"
if exist "%~dpn1_[TEMP]\BL.hevc" move "%~dpn1_[TEMP]\BL.hevc" "%~dpn1_[TEMP]\BL_NODV.hevc">nul
if exist "%~dpn1_[TEMP]\BL_NODV.hevc" set "VIDEOSTREAM=%~dpn1_[TEMP]\BL_NODV.hevc"
if exist "%~dpn1_[TEMP]\BL_NOHDR10P.hevc" del "%~dpn1_[TEMP]\BL_NOHDR10P.hevc"

:POSTPROC
if "%REM_HDR10P%"=="NO" if "%REM_DV%"=="NO" goto CLEANING
if "%HDR10P%"=="TRUE" if "%REM_HDR10P%"=="YES" set "NAMESTRING=No HDR10+"
if "%DV%"=="TRUE" if "%REM_DV%"=="YES" set "NAMESTRING=No DV"
if "%HDR10P%"=="TRUE" if "%REM_HDR10P%"=="YES" if "%DV%"=="TRUE" if "%REM_DV%"=="YES" set "NAMESTRING=No HDR10+ No DV"
if "%DV%"=="TRUE" if "%REM_DV%"=="NO" set "DVSTRING=:dv-profile=8.hdr10:hdr=none"
if "%RAW_FILE%"=="FALSE" goto MUX 

:POSTRAW
move "%VIDEOSTREAM%" "%~dpn1_[%NAMESTRING%].hevc">nul
goto CLEANING

:MUX
%WHITE%
echo.
echo  == MUXING ==============================================================================================================
if "%MKVExtract%"=="TRUE" (
	set "duration="
	SETLOCAL ENABLEDELAYEDEXPANSION
	if "!FRAMERATE!"=="23.976" set "duration=--default-duration 0:24000/1001p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="24.000" set "duration=--default-duration 0:24p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="25.000" set "duration=--default-duration 0:25p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="30.000" set "duration=--default-duration 0:30p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="48.000" set "duration=--default-duration 0:48p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="50.000" set "duration=--default-duration 0:50p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="60.000" set "duration=--default-duration 0:60p --fix-bitstream-timing-information 0:1"
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	"%MKVMERGEpath%" --output ^"%~dpn1_[%NAMESTRING%].mkv^" --no-video ^"^(^" ^"%~1^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"%VIDEOSTREAM%^" ^"^)^" --track-order 1:0 -q
	SETLOCAL DISABLEDELAYEDEXPANSION
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
	)
)
if "%MP4Extract%"=="TRUE" (
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	"%MP4BOXpath%" -rem 1 "%~1" -out "%~dpn1_[TEMP]\temp.mp4"
	"%MP4BOXpath%" -add "%VIDEOSTREAM%:ID=1%DVSTRING%:NAME=" "%~dpn1_[TEMP]\temp.mp4" -out "%~dpn1_[%NAMESTRING%].mp4"
	if exist "%~dpn1_[TEMP]\temp.mp4" del "%~dpn1_[TEMP]\temp.mp4"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
	)
)

:CLEANING
echo.
%WHITE%
echo  == CLEANING ============================================================================================================
echo.
if exist "%~dpn1_[TEMP]\BL_NODV.hevc" if "%RAW_FILE%"=="FALSE" del "%~dpn1_[TEMP]\BL_NODV.hevc"
if exist "%~dpn1_[TEMP]\BL_NODV.hevc" if "%RAW_FILE%"=="TRUE" move "%~dpn1_[TEMP]\BL_NODV.hevc" 
if exist "%~dpn1_[TEMP]\BL_NOHDR10P.hevc" if "%RAW_FILE%"=="FALSE" del "%~dpn1_[TEMP]\BL_NOHDR10P.hevc"
if exist "%~dpn1_[TEMP]" rd /S /Q "%~dpn1_[TEMP]"
if "%ERRORLEVEL%"=="0" (
	%GREEN%
	echo Cleaning Temp Folder - Done.
) else (
	%RED%
	echo Cleaning Temp Folder - Error.
	set "ERRORCOUNT=1"
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