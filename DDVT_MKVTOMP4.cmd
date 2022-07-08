@echo off & setlocal
mode con cols=122 lines=57
TITLE DDVT MKVTOMP4 [DonaldFaQ] v0.47 beta

rem --- Hardcoded settings. Can be changed manually ---
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "MP4FPSMODpath=%~dp0tools\mp4fpsmod.exe" rem Path to mp4fpsmod.exe
set "MKVEXTRACTpath=%~dp0tools\mkvextract.exe" rem Path to mkvextract.exe
set "MKVMERGEpath=%~dp0tools\mkvmerge.exe" rem Path to mkvmerge.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "HDR10P_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe
set "AUDIOCODEC=Untouched"

rem --- Hardcoded settings. Cannot be changed ---
set HDR=No HDR Infos found
set RESOLUTION=n.a.
set HDR=n.a.
set CODEC_NAME=n.a.
set FRAMERATE=n.a.
set FRAMES=n.a.
set INPUTFILENAME=%~nx1
set WAIT="%sfkpath%" sleep
set GREEN="%sfkpath%" color green
set RED="%sfkpath%" color red
set YELLOW="%sfkpath%" color yellow
set WHITE="%sfkpath%" color white
set CYAN="%sfkpath%" color cyan
set MAGENTA="%sfkpath%" color magenta
set GREY="%sfkpath%" color grey

%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool MKVtoMP4
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
	echo No Input File. Use DDVT_MKVTOMP4.cmd "YourFilename.mkv"
	goto EXIT
)

if /i "%~x1"==".mkv" set "MKVExtract=TRUE" & goto CHECK

%yellow%
echo.
echo File not Supported^! Only MKV files supported.
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
echo                                              Dolby Vision Tool MKVtoMP4
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
echo "%HDR%" | find "HDR10+">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "HDR10P=TRUE"
	%GREEN%
	echo HDR10+ Metadata found.
	%WHITE%
)
echo "%HDR%" | find "dvhe.08">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "DV=TRUE"
	%GREEN%
	echo Dolby Vision Profile 8 found.
	%WHITE%
)
echo "%HDR%" | find "dvhe.07">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "DV=TRUE"
	%GREEN%
	echo Dolby Vision Profile 7 found.
	%WHITE%
)
echo "%HDR%" | find "dvhe.05">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "DV=TRUE"
	%GREEN%
	echo Dolby Vision Profile 5 found.
	%WHITE%
)
echo.
%YELLOW%
echo Be sure that there no picture based subtitles in your MKV file (PGS or VobSub)^!
echo Only textbased subtitles supported.
echo.
echo Please check your Audio Codec and the MP4 specifications. You can switch the 
echo Audio Codec if the source is not compatible with MP4 container.
echo.
%WHITE%
echo  == MENU ================================================================================================================
echo.
echo 1. Audio Codec                    : [%AUDIOCODEC%]
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Converting^!
CHOICE /C 1S /N /M "Select a Letter 1,[S]tart"

if "%ERRORLEVEL%"=="2" goto BEGIN
if "%ERRORLEVEL%"=="1" (
	if "%AUDIOCODEC%"=="Untouched" set "AUDIOCODEC=eAC-3 @640k"
	if "%AUDIOCODEC%"=="eAC-3 @640k" set "AUDIOCODEC=AC-3 @640k"
	if "%AUDIOCODEC%"=="AC-3 @640k" set "AUDIOCODEC=AAC @High Quality"
	if "%AUDIOCODEC%"=="AAC @High Quality" set "AUDIOCODEC=Untouched"
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
echo                                              Dolby Vision Tool MKVtoMP4
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
%WHITE%
echo  == CONVERTING ==========================================================================================================
echo.
set "duration="
if "%FRAMERATE%"=="23.976" set "duration=--fps 0:24000/1001"
if "%FRAMERATE%"=="24.000" set "duration=--fps 0:24"
if "%FRAMERATE%"=="25.000" set "duration=--fps 0:25"
if "%FRAMERATE%"=="30.000" set "duration=--fps 0:30"
if "%FRAMERATE%"=="60.000" set "duration=--fps 0:60"
IF "%AUDIOCODEC%"=="Untouched" (
	set "DRC="
) else (
	set "DRC=-drc_scale 0"
)
IF "%AUDIOCODEC%"=="Untouched" set "AUDIOCODEC=-c:a copy"
IF "%AUDIOCODEC%"=="eAC-3 @640k" set "AUDIOCODEC=-c:a eac3 -b:a 640k"
IF "%AUDIOCODEC%"=="AC-3 @640k" set "AUDIOCODEC=-c:a ac3 -b:a 640k"
IF "%AUDIOCODEC%"=="AAC @High Quality" set "AUDIOCODEC=-c:a aac -vbr 5"
%GREEN%
"%FFMPEGpath%" %DRC% -y -i "%~1" -loglevel error -stats -map 0:v? -map 0:a? -map 0:s? -c:v copy %AUDIOCODEC% -c:s mov_text -strict -2 "%~dpn1.mp4"
if "%ERRORLEVEL%"=="0" (
	%GREEN%
	echo Done.
	"%MP4FPSMODpath%" -i %duration% "%~dpn1.mp4"
	echo.
) else (
	%RED%
	echo Error.
	echo.
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