@echo off & setlocal
mode con cols=122 lines=57
TITLE DDVT INJECTOR [DonaldFaQ] v0.47 beta

rem --- Hardcoded settings. Can be changed manually ---
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "MKVEXTRACTpath=%~dp0tools\mkvextract.exe" rem Path to mkvextract.exe
set "MKVMERGEpath=%~dp0tools\mkvmerge.exe" rem Path to mkvmerge.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "AUTOCROPpath=%~dp0tools\Autocrop.exe" rem Path to dovi_tool.exe
SET "LSMASHpath=%~dp0tools\LSMASHSource.dll"
set "HDR10Plus_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe
set "RPUFILE=%~dp1RPU.bin"
set "ELFILE=%~dp1EL.hevc"
set "HDR10PFILE=%~dp1HDR10Plus.json"

rem --- Hardcoded settings. Cannot be changed ---
set MP4Extract=FALSE
set MKVExtract=FALSE
set RAW_FILE=FALSE
set DELAY=0
set L6EDITING=NO
set HDR10P=FALSE
set DV=FALSE
set REMHDR10P=NO
set RPU_exist=NO
set EL_exist=NO
set HDR10P_exist=NO
set MUXINMKV=NO
set MUXINMP4=NO
set MUXP7SETTING=STANDARD
set REMHDR10PString=
set MUXP7String=
set DV_INJ=TRUE
set HDR10P_INJ=TRUE
set HDR=No HDR Infos found
set INPUTFILE=%~1
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
set RESOLUTION=n.a.
set HDR=n.a.
set CODEC_NAME=n.a.
set FRAMERATE=n.a.
set FRAMES=n.a.
set RPU_FRAMES=n.a.
set RPU_CMV=n.a.
set RPU_DVP=n.a.
set RPU_DVSP=

%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
%WHITE%
echo                                         ====================================
echo.
%WHITE%
echo.
echo.
echo  == CHECK INPUT FILE(S) =================================================================================================
if "%~1"=="" (
	%yellow%
	echo.
	echo No Input File. Use DDVT_INJECTOR.cmd "YourFilename.hevc/h265/mkv/mp4"
	%WHITE%
	goto EXIT
)
IF EXIST "%~dp1RPU.bin" (
	set "RPU_exist=YES"
	set "DV_INJ=TRUE"
)
IF EXIST "%~dp1EL.hevc" (
	set "EL_exist=YES"
	set "DV_INJ=TRUE"
)
if "%RPU_exist%%EL_exist%"=="NONO" (
	%YELLOW%
	set "DV_INJ=FALSE"
	echo.
	echo Dolby Vision Metadata not found^!
	echo Copy RPU.bin or EL.hevc to^:
	echo "%~dp1"
	echo Dolby Vision Injecting disabled.
)
IF EXIST "%~dp1HDR10Plus.json" (
	set "HDR10P_exist=YES"
) else (
	%YELLOW%
	set "HDR10P_INJ=FALSE"
	echo.
	echo HDR10+ Metadata not found^!
	echo Copy HDR10Plus.json to^:
	echo "%~dp1"
	echo HDR10+ Injecting disabled.
)
if "%RPU_exist%%EL_exist%%HDR10P_exist%"=="NONONO" (
	%RED%
	echo DV and^/or HDR10+ Metadata not found^!
	echo.
	%YELLOW%
	echo Abort Operation now.
	goto EXIT
)

if /i "%~x1"==".mkv" set "MKVExtract=TRUE" & goto CHECK
if /i "%~x1"==".mp4" set "MP4Extract=TRUE" & goto CHECK
if /i "%~x1"==".hevc" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".h265" set "RAW_FILE=TRUE" & goto CHECK

%yellow%
echo.
echo File not Supported^! Only HEVC^/h265^/MP4^/MKV files supported.

goto EXIT


:CHECK
echo.
%CYAN%
set "VIDEOSTREAM=%~1"
echo Analysing Video Stream. Please wait ...
if "%RAW_FILE%"=="TRUE" (
	"%MKVMERGEpath%" --priority higher --output ^"%TEMP%\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"%~1^" ^"^)^" --split parts:00:00:00-00:00:01 -q
	pushd %TEMP%
	"%MEDIAINFOpath%" --output=Video;%%Width%%x%%Height%% Info.mkv>"%TEMP%\Info.txt"
	set /p RESOLUTION=<"%TEMP%\Info.txt"
	"%MEDIAINFOpath%" --output=Video;%%HDR_Format/String%% Info.mkv>"%TEMP%\Info.txt"
	set /p HDR=<"%TEMP%\Info.txt"
	"%MEDIAINFOpath%" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% Info.mkv>"%TEMP%\Info.txt"
	set /p CODEC_NAME=<"%TEMP%\Info.txt"
	popd
	IF EXIST "%TEMP%\Info.txt" (
		del "%TEMP%\Info.txt"
		%GREEN%
		echo Done.
	) else (
		%YELLOW%
		echo Analysing failed.
	)
	echo.
) else (
	"%MEDIAINFOpath%" --output=Video;%%Width%%x%%Height%% "%~1">"%TEMP%\Info.txt"
	set /p RESOLUTION=<"%TEMP%\Info.txt"
	"%MEDIAINFOpath%" --output=Video;%%HDR_Format/String%% "%~1">"%TEMP%\Info.txt"
	set /p HDR=<"%TEMP%\Info.txt"
	"%MEDIAINFOpath%" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% "%~1">"%TEMP%\Info.txt"
	set /p CODEC_NAME=<"%TEMP%\Info.txt"
	"%MEDIAINFOpath%" --output=Video;%%FrameRate%% "%~1">"%TEMP%\Info.txt"
	set /p FRAMERATE=<"%TEMP%\Info.txt"
	"%MEDIAINFOpath%" --output=Video;%%FrameCount%% "%~1">"%TEMP%\Info.txt"
	set /p FRAMES=<"%TEMP%\Info.txt"
	IF EXIST "%TEMP%\Info.txt" (
		del "%TEMP%\Info.txt"
		%GREEN%
		echo Done.
	) else (
		%YELLOW%
		echo Analysing failed.
	)
	echo.
)

if "%RESOLUTION%"=="3840x21601920x1080" set "RESOLUTION=3840x2160 DL"
if "%CODEC_NAME%"=="HEVC-10Bit-YUV-4:2:0HEVC-10Bit-YUV-4:2:0" set "CODEC_NAME=HEVC-10Bit-YUV-4:2:0"
if "%FRAMERATE%"=="23.97623.976" set "FRAMERATE=23.976"
if "%FRAMERATE%"=="24.00024.000" set "FRAMERATE=24.000"

IF EXIST "%TEMP%\Info.txt" del "%TEMP%\Info.txt">nul
IF EXIST "%TEMP%\Info.mkv" del "%TEMP%\Info.mkv">nul

if "%RAW_FILE%"=="FALSE" (
	%CYAN%
	echo Analysing Video Borders. Please wait ...
	"%~dp0tools\DetectBorders.exe" --ffmpeg-path="%FFMPEGpath%" --input-file="%INPUTFILE%" --log-file="%TEMP%\Crop.txt"
	FOR /F "tokens=2-5 delims=(,-)" %%A IN (%TEMP%\Crop.txt) DO (
		set "AA_INPUT_LC=%%A"
		set "AA_INPUT_TC=%%B"
		set "AA_INPUT_RC=%%C"
		set "AA_INPUT_BC=%%D"
		set "RPU_AA_LC=%%A"
		set "RPU_AA_TC=%%B"
		set "RPU_AA_RC=%%C"
		set "RPU_AA_BC=%%D"
	)
	IF EXIST "%TEMP%\Crop.txt" (
		del "%TEMP%\Crop.txt"
		%GREEN%
		echo Done.
	) else (
		%YELLOW%
		echo Analysing failed.
		set "AA_INPUT_LC="
		set "AA_INPUT_TC="
		set "AA_INPUT_RC="
		set "AA_INPUT_BC="
	)
	echo.
)

IF EXIST "%ELFILE%" (
	%CYAN%
	echo Analysing DV EL Stream. Please wait ...
	"%DO_VI_TOOLpath%" extract-rpu "%ELFILE%" -o "%TEMP%\RPU.bin"
	IF EXIST "%TEMP%\RPU.bin" (
		%GREEN%
		echo Done.
	) else (
		%YELLOW%
		echo Analysing failed.
	)
	echo.
)

%CYAN%
echo Analysing DV RPU.bin. Please wait ...
IF EXIST "%ELFILE%" (
	"%DO_VI_TOOLpath%" info -i "%TEMP%\RPU.bin" -f 01>"%TEMP%\Info.json"
	"%DO_VI_TOOLpath%" info -i "%TEMP%\RPU.bin" -s>"%TEMP%\Sum.json"
	IF EXIST "%TEMP%\RPU.bin" (
		del "%TEMP%\RPU.bin"
		%GREEN%
		echo Done.
	) else (
		%YELLOW%
		echo Analysing failed.
	)
) else (
	"%DO_VI_TOOLpath%" info -i "%RPUFILE%" -f 01>"%TEMP%\Info.json"
	"%DO_VI_TOOLpath%" info -i "%RPUFILE%" -s>"%TEMP%\Sum.json"
	IF EXIST "%TEMP%\Info.json" (
		del "%TEMP%\RPU.bin"
		%GREEN%
		echo Done.
	) else (
		del "%TEMP%\RPU.bin"
		%YELLOW%
		echo Analysing failed.
	)
)
SETLOCAL ENABLEDELAYEDEXPANSION
IF EXIST "%TEMP%\Info.json" (
	FOR /F "delims=" %%A IN ('findstr /C:"dovi_profile" "%TEMP%\Info.json"') DO (
		set "RPU_DVP=%%A"
		set "RPU_DVP=!RPU_DVP:*:=!"
		set "RPU_DVP=!RPU_DVP:~1,-1!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"subprofile" "%TEMP%\Info.json"') DO (
		set "RPU_DVSP=%%A"
		set "RPU_DVSP=!RPU_DVSP:*:=!"
		set "RPU_DVSP=!RPU_DVSP:~2,-2!"
		set "RPU_DVSP= !RPU_DVSP!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"active_area_left_offset" "%TEMP%\Info.json"') DO (
		set "RPU_INPUT_AA_LC=%%A"
		set "RPU_INPUT_AA_LC=!RPU_INPUT_AA_LC:*:=!"
		set "RPU_INPUT_AA_LC=!RPU_INPUT_AA_LC:~1,-1!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"active_area_top_offset" "%TEMP%\Info.json"') DO (
		set "RPU_INPUT_AA_TC=%%A"
		set "RPU_INPUT_AA_TC=!RPU_INPUT_AA_TC:*:=!"
		set "RPU_INPUT_AA_TC=!RPU_INPUT_AA_TC:~1,-1!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"active_area_right_offset" "%TEMP%\Info.json"') DO (
		set "RPU_INPUT_AA_RC=%%A"
		set "RPU_INPUT_AA_RC=!RPU_INPUT_AA_RC:*:=!"
		set "RPU_INPUT_AA_RC=!RPU_INPUT_AA_RC:~1,-1!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"active_area_bottom_offset" "%TEMP%\Info.json"') DO (
		set "RPU_INPUT_AA_BC=%%A"
		set "RPU_INPUT_AA_BC=!RPU_INPUT_AA_BC:*:=!"
		set "RPU_INPUT_AA_BC=!RPU_INPUT_AA_BC:~1!"
	)
	del "%TEMP%\Info.json">nul
)
IF EXIST "%TEMP%\Sum.json" (
	FOR /F "delims=" %%A IN ('findstr /C:"Frames: " "%TEMP%\Sum.json"') DO (
		set "RPU_FRAMES=%%A"
		set "RPU_FRAMES=!RPU_FRAMES:~10!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"DM version: " "%TEMP%\Sum.json"') DO (
		set "RPU_CMV=%%A"
		set "RPU_CMV=!RPU_CMV:~21,-1!"
	)
	del "%TEMP%\Sum.json">nul
)
SETLOCAL DISABLEDELAYEDEXPANSION

if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="" (
	set "RPU_AA_LC=%RPU_INPUT_AA_LC%"
	set "RPU_AA_TC=%RPU_INPUT_AA_TC%"
	set "RPU_AA_RC=%RPU_INPUT_AA_RC%"
	set "RPU_AA_BC=%RPU_INPUT_AA_BC%"
)

set "RPU_AA_String=[LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px]"
if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%" set "RPU_AA_String=[LEAVE UNTOUCHED]"
if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="" set "RPU_AA_String=[LEAVE UNTOUCHED]"

:START
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
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
	echo Dolby Vision Profile 5 found.
	goto EXIT	
)
echo "%HDR%" | find "dvhe">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "DV=TRUE"
)
echo "%HDR%" | find "HDR10+">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "HDR10P=TRUE"
)

:MENU
echo.
%WHITE%
if "%DV_INJ%"=="TRUE" if "%HDR10P_INJ%"=="FALSE" goto DV_INJCT
if "%DV_INJ%"=="FALSE" if "%HDR10P_INJ%"=="TRUE" goto HDR10P_INJCT
echo  == MENU ================================================================================================================
echo.
echo 1. DOLBY VISION INJECTOR
echo 2. HDR10+ INJECTOR
echo.
%GREEN%
echo CHOOSE ONE INJECTOR^!
CHOICE /C 12 /N /M "Select a Letter 1,2"
if "%ERRORLEVEL%"=="2" goto HDR10P_INJCT
if "%ERRORLEVEL%"=="1" goto DV_INJCT

:HDR10P_INJCT
if "%MUXINMKV%%HDR10P_exist%"=="NOYES" set "HEADER_FILENAME=%~n1_[HDR10+ INJECTED].hevc"
if "%MKVExtract%%MUXINMKV%%HDR10P_exist%"=="TRUEYESYES" set "HEADER_FILENAME=%~n1_[HDR10+ INJECTED].mkv"
if "%MP4Extract%%MUXINMP4%%HDR10P_exist%"=="TRUEYESYES" set "HEADER_FILENAME=%~n1_[HDR10+ INJECTED].mp4"
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                                 - HDR10+ INJECTOR -
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
echo  == VIDEO OUTPUT ========================================================================================================
echo.
%YELLOW%
echo Filename   = [%HEADER_FILENAME%]
%WHITE%
echo.
echo  == MENU ================================================================================================================
echo.
if "%MKVExtract%"=="TRUE" echo 1. Mux Stream in MKV   : [%MUXINMKV%]
if "%MP4Extract%"=="TRUE" echo 1. Mux Stream in MP4   : [%MUXINMP4%]
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Injecting^!
if "%RAW_FILE%"=="FALSE" (
	CHOICE /C 1S /N /M "Select a Letter 1,[S]tart"
) else (
	CHOICE /C 1S /N /M "Select a Letter [S]tart"
)
if "%ERRORLEVEL%"=="2" goto HDR10P_BEGIN
if "%ERRORLEVEL%"=="1" (
	if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
	if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
	if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
	if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
)
goto HDR10P_INJCT

:HDR10P_BEGIN
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                                 - HDR10+ INJECTOR -
%WHITE%
echo                                        ====================================
echo.
echo.
echo  == SETTINGS ============================================================================================================
echo.
%CYAN%
if "%MKVExtract%"=="TRUE" echo 1. Mux Stream in MKV   : [%MUXINMKV%]
if "%MP4Extract%"=="TRUE" echo 1. Mux Stream in MP4   : [%MUXINMP4%]
echo.
%WHITE%
echo  == INJECTING ===========================================================================================================
echo.
%YELLOW%
echo ATTENTION^! You need many HDD Space for this operation.
echo.
%CYAN%
%CYAN%
if "%RAW_FILE%"=="FALSE" (
	echo Please wait. Extracting the Video Layer ...
	if "%MKVExtract%"=="TRUE" "%MKVEXTRACTpath%" "%~1" tracks 0:"%~dpn1_[TEMP].hevc"
	if "%MP4Extract%"=="TRUE" "%MP4BOXpath%" -raw 1 -out "%~dpn1_[TEMP].hevc" "%~1"
	set "VIDEOSTREAM=%~dpn1_[TEMP].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
%CYAN%
echo Please wait. Injecting the HDR10+ Metadata into stream...
"%HDR10Plus_TOOLpath%" inject -i "%VIDEOSTREAM%" -j "%HDR10PFILE%" -o "%~dpn1_[HDR10+ INJECTED].hevc"
if "%ERRORLEVEL%"=="0" (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
	echo.
)
if "%RAW_FILE%"=="FALSE" (
	IF EXIST "%VIDEOSTREAM%" (
		del "%VIDEOSTREAM%">nul
		if "%ERRORLEVEL%"=="0" (
			%GREEN%
			echo Deleting Temp File - Done.
			echo.
		) else (
			%RED%
			echo Deleting Temp File - Error.
			set "ERRORCOUNT=1"
			echo.
		)
	)
)
if "%MUXINMKV%"=="YES" if "%MKVExtract%"=="TRUE" (
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
	%YELLOW% 
	echo Don't close the "Muxing into MKV Container" cmd window.
	start /WAIT /MIN "Muxing into MKV Container" "%MKVMERGEpath%" --output ^"%~dpn1_[HDR10+ INJECTED].mkv^" --no-video ^"^(^" ^"%~1^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"%~dpn1_[HDR10+ INJECTED].hevc^" ^"^)^" --track-order 1:0
	SETLOCAL DISABLEDELAYEDEXPANSION
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)
)

if "%MUXINMP4%"=="YES" if "%MP4Extract%"=="TRUE" (
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	"%MP4BOXpath%" -rem 1 "%~1" -out "%~dpn1_[temp].mp4"
	"%MP4BOXpath%" -add "%~dpn1_[HDR10+ INJECTED].hevc:ID=1:NAME=" "%~dpn1_[temp].mp4" -out "%~dpn1_[HDR10+ INJECTED].mp4"
	IF EXIST "%~dpn1_[temp].mp4" del "%~dpn1_[temp].mp4"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)
)

%CYAN%
echo Please wait. Cleaning and Moving files ...
if "%MUXINMKV%%MKVExtract%"=="YESTRUE" IF EXIST "%~dpn1_[HDR10+ INJECTED].hevc" (
	del "%~dpn1_[HDR10+ INJECTED].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp File - Done.
	) else (
		%RED%
		echo Deleting Temp File - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)

if "%MUXINMP4%%MP4Extract%"=="YESTRUE" IF EXIST "%~dpn1_[HDR10+ INJECTED].hevc" (
	del "%~dpn1_[HDR10+ INJECTED].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp File - Done.
	) else (
		%RED%
		echo Deleting Temp File - Error.
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
%WHITE%
goto exit

:DV_INJCT
if "%MKVExtract%"=="FALSE" set "MUXINMKV=NO"
if "%MUXINMKV%%RPU_exist%"=="NOYES" set "HEADER_FILENAME=%~n1_[BL+RPU].hevc"
if "%MKVExtract%%MUXINMKV%%RPU_exist%"=="TRUEYESYES" set "HEADER_FILENAME=%~n1_[BL+RPU].mkv"
if "%MUXINMKV%%EL_exist%"=="NOYES" set "HEADER_FILENAME=%~n1_[BL+EL+RPU].hevc"
if "%MKVExtract%%MUXINMKV%%EL_exist%"=="TRUEYESYES" set "HEADER_FILENAME=%~n1_[BL+EL+RPU].mkv"
if "%MUXINMP4%%RPU_exist%"=="NOYES" set "HEADER_FILENAME=%~n1_[BL+RPU].hevc"
if "%MP4Extract%%MUXINMP4%%RPU_exist%"=="TRUEYESYES" set "HEADER_FILENAME=%~n1_[BL+RPU].mp4"
if "%MUXINMP4%%EL_exist%"=="NOYES" set "HEADER_FILENAME=%~n1_[BL+EL+RPU].hevc"
if "%MP4Extract%%MUXINMP4%%EL_exist%"=="TRUEYESYES" set "HEADER_FILENAME=%~n1_[BL+EL+RPU].mp4"

if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%" (
	set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px] [" & call :colortxt 0A "MATCH WITH VIDEO" & call :colortxt 0B "]" /n
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0A "MATCH WITH RPU" & call :colortxt 0B "]" /n
) else (
	set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0B "]" /n
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0C "NOT MATCH WITH RPU" & call :colortxt 0B "]" /n
)
if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="" (
	set "AA_String=call :colortxt 0B "Borders    = [" & call :colortxt 0E "NOT FOUND. MUX FILE IN CONTAINER OR SET CROPPING VALUES MANUALLY" & call :colortxt 0B "]" /n
	set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px] [" & call :colortxt 0E "VIDEO BORDERS NOT FOUND" & call :colortxt 0B "]" /n
)
if "%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%"=="" set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [" & call :colortxt 0C "BORDERS NOT SET IN RPU" & call :colortxt 0B "]" /n

cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                              - DOLBY VISION INJECTOR -
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
%AA_String%
echo.
if "%RPU_exist%%EL_exist%"=="YESNO" (
	echo.
	%WHITE%
	echo  == RPU INPUT ===========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [RPU.bin]
	echo RPU Info   = [DV Profile = %RPU_DVP%%RPU_DVSP%] [CM Version = %RPU_CMV%] [Frames = %RPU_FRAMES%]
	%HEADER_RPU_AA_String%
	%WHITE%
	echo.
) else (
	echo.
	%WHITE%
	echo  == EL INPUT ============================================================================================================
	echo.
	%CYAN%
	echo Filename   = [EL.hevc]
	echo EL Info    = [DV Profile = %RPU_DVP%%RPU_DVSP%] [CM Version = %RPU_CMV%] [Frames = %RPU_FRAMES%]
	%HEADER_RPU_AA_String%
	%WHITE%
	echo.
)
if "%RPU_exist%%EL_exist%"=="YESNO" (
	echo.
	%WHITE%
	echo  == FILE OUTPUT =========================================================================================================
	echo.
	%YELLOW%
	echo Filename   = [%HEADER_FILENAME%]
	echo RPU Info   = [DV Profile = %RPU_DVP%%RPU_DVSP%] [CM Version = %RPU_CMV%] [Frames = %FRAMES%]	
	echo Borders    = %RPU_AA_String%
	echo Delay      = [%DELAY% FRAMES]
	%WHITE%
	echo.
) else (
	echo.
	%WHITE%
	echo  == FILE OUTPUT =========================================================================================================
	echo.
	%YELLOW%
	echo Filename   = [%HEADER_FILENAME%]
	echo EL Info    = [DV Profile = %RPU_DVP%%RPU_DVSP%] [CM Version = %RPU_CMV%] [Frames = %FRAMES%]	
	echo Borders    = %RPU_AA_String%
	%WHITE%
	echo.
)
echo  == MENU ================================================================================================================
echo.
IF NOT EXIST "%ELFILE%" echo 1. DELAY               : [%DELAY% FRAMES]
call :colortxt 0F "2. Match L6 Metadata   : [%L6EDITING%]" & call :colortxt 0E "*" & call :colortxt 0E "   *Change L6 Metadata to match with Video." /n
if "%HDR10P%"=="TRUE" echo 3. Remove HDR10+       : [%REMHDR10P%]
if "%MKVExtract%"=="TRUE" echo 4. MUX STREAM IN MKV   : [%MUXINMKV%]
if "%MP4Extract%"=="TRUE" echo 4. MUX STREAM IN MP4   : [%MUXINMP4%]
IF EXIST "%ELFILE%" call :colortxt 0F "5. MUX EL IN BL        : [%MUXP7SETTING%]" & call :colortxt 0E "*" & call :colortxt 0E " *Create Profile 7 Single Layer File." /n
call :colortxt 0F "6. EDIT ACTIVE AREA" & call :colortxt 0E "*" & call :colortxt 0E "   *Setting Crop Values. DISCARD set Borders to [LEAVE UNTOUCHED]." /n
%WHITE%
echo.
echo S. START
echo.
%GREEN%

IF EXIST "%ELFILE%" (
	if "%HDR10P%"=="TRUE" (
		if "%RAW_FILE%"=="FALSE" (
			echo Change Settings and press [S] to start Injecting^!
			CHOICE /C 23456S /N /M "Select a Letter 2,3,4,5,6,[S]tart"
		) else (
			echo Change Settings and press [S] to start Injecting^!
			CHOICE /C 2356S /N /M "Select a Letter 2,3,5,6,[S]tart"
		)
	) else (
		if "%RAW_FILE%"=="FALSE" (
			echo Change Settings and press [S] to start Injecting^!
			CHOICE /C 2456S /N /M "Select a Letter 2,4,5,6,[S]tart"
		) else (
			echo Change Settings and press [S] to start Injecting^!
			CHOICE /C 256S /N /M "Select a Letter 2,5,6,[S]tart"
		)
	)
) else (
	if "%HDR10P%"=="TRUE" (
		if "%RAW_FILE%"=="FALSE" (
			echo Change Settings and press [S] to start Injecting^!
			CHOICE /C 12346S /N /M "Select a Letter 1,2,3,4,6,[S]tart"
		) else (
			echo Change Settings and press [S] to start Injecting^!
			CHOICE /C 1236S /N /M "Select a Letter 1,2,3,6,[S]tart"
		)
	) else (
		if "%RAW_FILE%"=="FALSE" (
			echo Change Settings and press [S] to start Injecting^!
			CHOICE /C 1246S /N /M "Select a Letter 1,2,4,6,[S]tart"
		) else (
			echo Change Settings and press [S] to start Injecting^!
			CHOICE /C 126S /N /M "Select a Letter 1,2,6,[S]tart"
		)
	)
)

IF EXIST "%ELFILE%" (
	if "%HDR10P%"=="TRUE" (
		if "%RAW_FILE%"=="FALSE" (
			if "%ERRORLEVEL%"=="6" goto DV_BEGIN
			if "%ERRORLEVEL%"=="5" goto AA_AREA
			if "%ERRORLEVEL%"=="4" (
				if "%MUXP7SETTING%"=="makeMKV" set "MUXP7SETTING=STANDARD"
				if "%MUXP7SETTING%"=="STANDARD" set "MUXP7SETTING=makeMKV"
			)
			if "%ERRORLEVEL%"=="3" (
				if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
				if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
				if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
				if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			)
			if "%ERRORLEVEL%"=="2" (
				if "%REMHDR10P%"=="NO" (
					set "REMHDR10P=YES"
				)
				if "%REMHDR10P%"=="YES" (
					set "REMHDR10P=NO"
				)
			)
			if "%ERRORLEVEL%"=="1" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
		) else (
			if "%ERRORLEVEL%"=="5" goto DV_BEGIN
			if "%ERRORLEVEL%"=="4" goto AA_AREA
			if "%ERRORLEVEL%"=="3" (
				if "%MUXP7SETTING%"=="makeMKV" set "MUXP7SETTING=STANDARD"
				if "%MUXP7SETTING%"=="STANDARD" set "MUXP7SETTING=makeMKV"
			)
			if "%ERRORLEVEL%"=="2" (
				if "%REMHDR10P%"=="NO" (
					set "REMHDR10P=YES"
				)		
				if "%REMHDR10P%"=="YES" (
					set "REMHDR10P=NO"
				)
			)
			if "%ERRORLEVEL%"=="1" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
		)
	) else (
		if "%RAW_FILE%"=="FALSE" (
			if "%ERRORLEVEL%"=="5" goto DV_BEGIN
			if "%ERRORLEVEL%"=="4" goto AA_AREA
			if "%ERRORLEVEL%"=="3" (
				if "%MUXP7SETTING%"=="makeMKV" set "MUXP7SETTING=STANDARD"
				if "%MUXP7SETTING%"=="STANDARD" set "MUXP7SETTING=makeMKV"
			)
			if "%ERRORLEVEL%"=="2" (
				if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
				if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
				if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
				if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			)
			if "%ERRORLEVEL%"=="1" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
		) else (
			if "%ERRORLEVEL%"=="4" goto DV_BEGIN
			if "%ERRORLEVEL%"=="3" goto AA_AREA	
			if "%ERRORLEVEL%"=="2" (
				if "%MUXP7SETTING%"=="makeMKV" set "MUXP7SETTING=STANDARD"
				if "%MUXP7SETTING%"=="STANDARD" set "MUXP7SETTING=makeMKV"
			)
			if "%ERRORLEVEL%"=="1" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)				
		)
	)
) else (
	if "%HDR10P%"=="TRUE" (
		if "%RAW_FILE%"=="FALSE" (
			if "%ERRORLEVEL%"=="6" goto DV_BEGIN
			if "%ERRORLEVEL%"=="5" goto AA_AREA
			if "%ERRORLEVEL%"=="4" (
				if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
				if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
				if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
				if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			)	
			if "%ERRORLEVEL%"=="3" (
				if "%REMHDR10P%"=="NO" (
					set "REMHDR10P=YES"
				)		
				if "%REMHDR10P%"=="YES" (
					set "REMHDR10P=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="1" (
				echo.
				%WHITE%
				echo Type in the RPU DELAY, which will be added.
				echo Importend^! Set "-" for negative Delay.
				echo Example: For cutting 3 Frames type "-3" and press Enter^!
				echo.
				set /p "DELAY=Type in the Frames and press [ENTER]: "
				goto START
			)
		) else (
			if "%ERRORLEVEL%"=="5" goto DV_BEGIN
			if "%ERRORLEVEL%"=="4" goto AA_AREA
			if "%ERRORLEVEL%"=="3" (
				if "%REMHDR10P%"=="NO" (
					set "REMHDR10P=YES"
				)		
				if "%REMHDR10P%"=="YES" (
					set "REMHDR10P=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)				
			if "%ERRORLEVEL%"=="1" (
				echo.
				%WHITE%
				echo Type in the RPU DELAY, which will be added.
				echo Importend^! Set "-" for negative Delay.
				echo Example: For cutting 3 Frames type "-3" and press Enter^!
				echo.
				set /p "DELAY=Type in the Frames and press [ENTER]: "
				goto START
			)
		)
	) else (
		if "%RAW_FILE%"=="FALSE" (
			if "%ERRORLEVEL%"=="5" goto DV_BEGIN
			if "%ERRORLEVEL%"=="4" goto AA_AREA
			if "%ERRORLEVEL%"=="3" (
				if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
				if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
				if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
				if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			)
			if "%ERRORLEVEL%"=="2" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="1" (
				echo.
				%WHITE%
				echo Type in the RPU DELAY, which will be added.
				echo Importend^! Set "-" for negative Delay.
				echo Example: For cutting 3 Frames type "-3" and press Enter^!
				echo.
				set /p "DELAY=Type in the Frames and press [ENTER]: "
			)
		) else (
			if "%ERRORLEVEL%"=="4" goto DV_BEGIN
			if "%ERRORLEVEL%"=="3" goto AA_AREA
			if "%ERRORLEVEL%"=="2" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)			
			if "%ERRORLEVEL%"=="1" (
				echo.
				%WHITE%
				echo Type in the RPU DELAY, which will be added.
				echo Importend^! Set "-" for negative Delay.
				echo Example: For cutting 3 Frames type "-3" and press Enter^!
				echo.
				set /p "DELAY=Type in the Frames and press [ENTER]: "
			)
		)
	)
)

goto DV_INJCT

:DV_BEGIN
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                              - DOLBY VISION INJECTOR -
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == SETTINGS ============================================================================================================
echo.
%CYAN%
IF NOT EXIST "%ELFILE%" echo Delay               : [%DELAY% FRAMES]
if "%HDR10P%"=="TRUE" echo Remove HDR10+       : [%REMHDR10P%]
if "%MP4Extract%"=="TRUE" echo Mux Stream in MKV   : [%MUXINMKV%]
if "%MP4Extract%"=="TRUE" echo Mux Stream in MP4   : [%MUXINMP4%]
echo Cropping Values     : %RPU_AA_String%
echo.
%WHITE%
echo  == INJECTING ===========================================================================================================
echo.
%YELLOW%
echo ATTENTION^! You need many HDD Space for this operation.
echo.
%CYAN%

rem -------- LOGFILE ------------
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ>"%~dpn1.log"
echo.>>"%~dpn1.log"
echo                                         ====================================>>"%~dpn1.log"
echo                                              Dolby Vision Tool INJECTOR>>"%~dpn1.log"
echo                                         ====================================>>"%~dpn1.log"
echo.>>"%~dpn1.log"
echo.>>"%~dpn1.log"
echo.>>"%~dpn1.log"
echo  == LOGFILE START =======================================================================================================>>"%~dpn1.log"
echo.>>"%~dpn1.log"
echo %date%  %time%>>"%~dpn1.log"
echo.>>"%~dpn1.log"

:DV_AA
if "%EL_exist%"=="YES" set "RPUFILE=%~dp1EL.hevc"
if "%RPU_AA_String%"=="[LEAVE UNTOUCHED]" goto CUSTOM
%CYAN%
if "%EL_exist%"=="YES" (
	echo Please wait. Extracting RPU.bin from EL.hevc...
	"%DO_VI_TOOLpath%" -m 0 extract-rpu "%ELFILE%" -o "%TEMP%\ELRPU.bin"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)
)

if exist "%TEMP%\ELRPU.bin" set "RPUFILE=%TEMP%\ELRPU.bin"

:CUSTOM
if not exist "%~dp1custom.json" goto :CROPRPU
%CYAN%
echo  == CUSTOM JSON =========================================================================================================>>"%~dpn1.log"
echo.>>"%~dpn1.log"
echo Please wait. Applying custom JSON script...
"%DO_VI_TOOLpath%" editor -i "%RPUFILE%" -j "%~dp1custom.json" -o "%TEMP%\RPU-CUSTOM.bin">>"%~dpn1.log"
echo.>>"%~dpn1.log"
if exist "%TEMP%\RPU-CUSTOM.bin" (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
	echo.
)
	
set "RPUFILE=%TEMP%\RPU-CUSTOM.bin"

:CROPRPU
if "%RPU_AA_String%"=="[LEAVE UNTOUCHED]" goto L6EDITING
%CYAN%
echo  == CROP RPU ============================================================================================================>>"%~dpn1.log"
echo.>>"%~dpn1.log"
echo Please wait. Applying cropping values...
echo ^{ >"%TEMP%\EDIT.json"
echo   ^"active_area^"^: ^{ >>"%TEMP%\EDIT.json"
echo     ^"presets^"^: ^[ >>"%TEMP%\EDIT.json"
echo       ^{ >>"%TEMP%\EDIT.json"
echo       	 ^"id^"^: 0, >>"%TEMP%\EDIT.json"
echo       	 ^"left^"^: %RPU_AA_LC%, >>"%TEMP%\EDIT.json"
echo       	 ^"right^"^: %RPU_AA_RC%, >>"%TEMP%\EDIT.json"
echo       	 ^"top^"^: %RPU_AA_TC%, >>"%TEMP%\EDIT.json"
echo      	 ^"bottom^"^: %RPU_AA_BC% >>"%TEMP%\EDIT.json"
echo       ^} >>"%TEMP%\EDIT.json"
echo     ^], >>"%TEMP%\EDIT.json"
echo      ^"edits^"^: { >>"%TEMP%\EDIT.json"
echo      ^"all^"^: 0 >>"%TEMP%\EDIT.json"
echo     ^} >>"%TEMP%\EDIT.json"
echo   ^} >>"%TEMP%\EDIT.json"
echo ^} >>"%TEMP%\EDIT.json"

"%DO_VI_TOOLpath%" editor -i "%RPUFILE%" -j "%TEMP%\EDIT.json" -o "%TEMP%\RPU-CROPPED.bin">>"%~dpn1.log"
echo.>>"%~dpn1.log"
if exist "%TEMP%\RPU-CROPPED.bin" (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
	echo.
)
	
if exist "%TEMP%\EDIT.json" del "%TEMP%\EDIT.json"
if exist "%TEMP%\ELRPU.bin" del "%TEMP%\ELRPU.bin"
if exist "%TEMP%\RPU-CUSTOM.bin" del "%TEMP%\RPU-CUSTOM.bin"
set "RPUFILE=%TEMP%\RPU-CROPPED.bin"

%CYAN%
if "%EL_exist%"=="YES" (
	echo Please wait. Injecting RPU.bin in EL.hevc...
	"%DO_VI_TOOLpath%" inject-rpu "%ELFILE%" --rpu-in "%RPUFILE%" -o "%~dp1ELTEMP.hevc"
	set "RPUFILE=%~dp1ELTEMP.hevc"
	if "%ERRORLEVEL%"=="0" (
	%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)
)

:L6EDITING
if "%L6EDITING%"=="NO" goto DV_DELAY
"%MEDIAINFOpath%" --output=Video;%%MaxCLL%% %1>"%TEMP%\Info.txt"
set /p MaxCLL=<"%TEMP%\Info.txt"
set "MaxCLL=%MaxCLL:~0,-6%"
if "%MaxCLL%"=="~0,-6" set "MaxCLL=1000"
"%MEDIAINFOpath%" --output=Video;%%MaxFALL%% %1>"%TEMP%\Info.txt"
set /p MaxFALL=<"%TEMP%\Info.txt"
set "MaxFALL=%MaxFALL:~0,-6%"
if "%MaxFall%"=="~0,-6" set "MaxFALL=400"
"%MEDIAINFOpath%" --output=Video;%%MasteringDisplay_Luminance%% %1>"%TEMP%\Info.txt"
set /p Luminance=<"%TEMP%\Info.txt"
for /F "tokens=2" %%A in ("%Luminance%") do set MinDML=%%A
for /F "tokens=* delims=0." %%A in ("%MinDML%") do set "MinDML=%%A"
if "%MinDML%"=="" set "MinDML=1"
for /F "tokens=5" %%A in ("%Luminance%") do set MaxDML=%%A
if "%MaxDML%"=="" set "MaxDML=1000"
del "%TEMP%\Info.txt">nul
%CYAN%
echo  == L6 METADATA EDIT ====================================================================================================>>"%~dpn1.log"
echo.>>"%~dpn1.log"
echo Please wait. Editing L6 Metadata ...
echo {>"%TEMP%\EDIT.json"
echo 	"level6": {>>"%TEMP%\EDIT.json"
echo	 	"max_display_mastering_luminance": %MaxDML%,>>"%TEMP%\EDIT.json"
echo	 	"min_display_mastering_luminance": %MinDML%,>>"%TEMP%\EDIT.json"
echo	 	"max_content_light_level": %MaxCLL%,>>"%TEMP%\EDIT.json"
echo	 	"max_frame_average_light_level": %MaxFall% >>"%TEMP%\EDIT.json"
echo 	}>>"%TEMP%\EDIT.json"
echo }>>"%TEMP%\EDIT.json"
"%DO_VI_TOOLpath%" editor -i "%RPUFILE%" -j "%TEMP%\EDIT.json" -o "%TEMP%\RPU-L6EDIT.bin">>"%~dpn1.log"
echo.>>"%~dpn1.log"
IF EXIST "%TEMP%\RPU-L6EDIT.bin" (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
	echo.
)
del "%TEMP%\EDIT.json"
set "RPUFILE=%TEMP%\RPU-L6EDIT.bin"

:DV_DELAY
if "%DELAY%"=="0" goto DV_INJECT
echo "%DELAY%" | find "-">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	goto DV_NEGDELAY
) else (
	goto DV_POSDELAY
)
:DV_POSDELAY
%CYAN%
echo Please wait. Applying %DELAY% Frames positive Delay ...
echo ^{ >"%TEMP%\Edit.json"
echo 	^"duplicate^"^: ^[ >>"%TEMP%\Edit.json"
echo 		^{ >>"%TEMP%\Edit.json"
echo 			^"source^"^: 0^, >>"%TEMP%\Edit.json"
echo 			^"offset^"^: 0^, >>"%TEMP%\Edit.json"
echo 			^"length^"^: %DELAY% >>"%TEMP%\Edit.json"
echo 		^} >>"%TEMP%\Edit.json"
echo 	^] >>"%TEMP%\Edit.json"
echo ^} >>"%TEMP%\Edit.json"
goto DV_APPLYDELAY

:DV_NEGDELAY
%CYAN%
echo Please wait. Applying %DELAY% Frames negative Delay ...
set /A DELAY=%DELAY%+1
echo ^{ >"%TEMP%\EDIT.json"
echo 	^"remove^"^: ^[ >>"%TEMP%\EDIT.json"
echo 		^"0%DELAY%^" >>"%TEMP%\EDIT.json"
echo 	^] >>"%TEMP%\EDIT.json"
echo ^} >>"%TEMP%\EDIT.json"
goto DV_APPLYDELAY

:DV_APPLYDELAY
echo  == RPU DELAY ===========================================================================================================>>"%~dpn1.log"
echo.>>"%~dpn1.log"
"%DO_VI_TOOLpath%" editor -i "%RPUFILE%" -j "%TEMP%\EDIT.json" -o "%TEMP%\RPU-DELAYED.bin">>"%~dpn1.log"
echo.>>"%~dpn1.log"
IF EXIST "%TEMP%\RPU-DELAYED.bin" (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
	echo.
)
del "%TEMP%\EDIT.json"
set "RPUFILE=%TEMP%\RPU-DELAYED.bin"

:DV_INJECT
if "%REMHDR10P%"=="YES" set "REMHDR10PString=--drop-hdr10plus "
if "%MUXP7SETTING%"=="makeMKV" set "MUXP7String=--eos-before-el "
%CYAN%
if "%RAW_FILE%"=="FALSE" (
	echo Please wait. Extracting the Video Layer ...
	if "%MKVExtract%"=="TRUE" "%MKVEXTRACTpath%" "%~1" tracks 0:"%~dpn1_[TEMP].hevc"
	if "%MP4Extract%"=="TRUE" "%MP4BOXpath%" -raw 1 -out "%~dpn1_[TEMP].hevc" "%~1"
	set "VIDEOSTREAM=%~dpn1_[TEMP].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
	
%CYAN%
echo Please wait. Injecting the DV Metadata Binary into stream...
if "%EL_exist%"=="YES" (
	"%DO_VI_TOOLpath%" %REMHDR10PString%mux %MUXP7String%--bl "%VIDEOSTREAM%" --el "%RPUFILE%" -o "%~dpn1_[BL+EL+RPU].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)
	IF EXIST "%~dp1ELTEMP.hevc" DEL "%~dp1ELTEMP.hevc"
	IF EXIST "%~dp1ELRPU.bin" DEL "%~dp1ELRPU.bin"
) else (
	"%DO_VI_TOOLpath%" %REMHDR10PString%inject-rpu "%VIDEOSTREAM%" --rpu-in "%RPUFILE%" -o "%~dpn1_[BL+RPU].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)	
)

if "%RAW_FILE%"=="FALSE" IF EXIST "%VIDEOSTREAM%" del "%VIDEOSTREAM%"

if "%MUXINMKV%%MKVExtract%"=="YESTRUE" (
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
	%YELLOW%
	echo Don't close the "Muxing into MKV Container" cmd window.
	if "%EL_exist%"=="YES" (
		start /WAIT /MIN "Muxing into MKV Container" "%MKVMERGEpath%" --output ^"%~dpn1_[BL+EL+RPU].mkv^" --no-video ^"^(^" ^"%~1^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"%~dpn1_[BL+EL+RPU].hevc^" ^"^)^" --track-order 1:0
	) else (
		start /WAIT /MIN "Muxing into MKV Container" "%MKVMERGEpath%" --output ^"%~dpn1_[BL+RPU].mkv^" --no-video ^"^(^" ^"%~1^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"%~dpn1_[BL+RPU].hevc^" ^"^)^" --track-order 1:0	
	)
	SETLOCAL DISABLEDELAYEDEXPANSION
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)
)

if "%MUXINMP4%%MP4Extract%"=="YESTRUE" (
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	"%MP4BOXpath%" -rem 1 "%~1" -out "%~dpn1_[temp].mp4"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
	)	
	"%MP4BOXpath%" -add "%~dpn1_[BL+RPU].hevc:ID=1:dv-profile=8.hdr10:hdr=none:NAME=" "%~dpn1_[temp].mp4" -out "%~dpn1_[BL+RPU].mp4"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set "ERRORCOUNT=1"
		echo.
	)	
	IF EXIST "%~dpn1_[temp].mp4" del "%~dpn1_[temp].mp4"
)

%CYAN%
echo Please wait. Cleaning and Moving files ...
if "%MUXINMKV%%MKVExtract%"=="YESTRUE" IF EXIST "%~dpn1_[BL+RPU].hevc" (
	del "%~dpn1_[BL+RPU].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp File - Done.
	) else (
		%RED%
		echo Deleting Temp File - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
if "%MUXINMKV%%MKVExtract%"=="YESTRUE" IF EXIST "%~dpn1_[BL+EL+RPU].hevc" (
	del "%~dpn1_[BL+EL+RPU].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp File - Done.
	) else (
		%RED%
		echo Deleting Temp File - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)

if "%MUXINMP4%%MP4Extract%"=="YESTRUE" IF EXIST "%~dpn1_[BL+RPU].hevc" (
	del "%~dpn1_[BL+RPU].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp File - Done.
	) else (
		%RED%
		echo Deleting Temp File - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
if "%MUXINMP4%%MP4Extract%"=="YESTRUE" IF EXIST "%~dpn1_[BL+EL+RPU].hevc" (
	del "%~dpn1_[BL+EL+RPU].hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp File - Done.
	) else (
		%RED%
		echo Deleting Temp File - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
IF EXIST "%TEMP%\RPU-CROPPED.bin" (
	del "%TEMP%\RPU-CROPPED.bin"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting RPU-CROPPED.bin - Done.
	) else (
		%RED%
		echo Deleting RPU-CROPPED.bin - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
IF EXIST "%TEMP%\RPU-L6EDIT.bin" (
	del "%TEMP%\RPU-L6EDIT.bin"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting RPU-L6EDIT.bin - Done.
	) else (
		%RED%
		echo Deleting RPU-L6EDIT.bin - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
IF EXIST "%TEMP%\RPU-DELAYED.bin" (
	del "%TEMP%\RPU-DELAYED.bin"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting RPU-DELAYED.bin - Done.
	) else (
		%RED%
		echo Deleting RPU-DELAYED.bin - Error.
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
%WHITE%
echo  == LOGFILE END =========================================================================================================>>"%~dpn1.log"
goto exit

:AA_AREA
set "RPU_AA_String=[LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px]"
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                                - ACTIVE AREA EDITOR -
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == VIDEO INPUT =========================================================================================================
echo.
%CYAN%
%AA_String%
echo.
if "%RPU_exist%%EL_exist%"=="YESNO" (
	echo.
	%WHITE%
	echo  == RPU INPUT ===========================================================================================================
	%CYAN%
	%HEADER_RPU_AA_String%
	echo.
) else (
	echo.
	%WHITE%
	echo  == EL INPUT ============================================================================================================
	%CYAN%
	%HEADER_RPU_AA_String%
	echo.
)
if "%RPU_exist%%EL_exist%"=="YESNO" (
	echo.
	%WHITE%
	echo  == RPU OUTPUT ==========================================================================================================
	%YELLOW%
	echo Borders    = %RPU_AA_String%
	%WHITE%
	echo.
) else (
	echo.
	%WHITE%
	echo  == EL OUTPUT ===========================================================================================================
	%YELLOW%
	echo Borders    = %RPU_AA_String%
	%WHITE%
	echo.
)
echo  == EDIT ACTIVE AREA ====================================================================================================
%CYAN%
echo.
echo If you change the resolution of the target video you must edit the Active Area. For Example^:
echo Source^: 3840 px x 2160 px Letterboxed ^(Active Area 3840 px x 1600 px^) ^= 280 px at Top and Bottom.
echo Target^: 1920 px x 1080 px Letterboxed ^(Active Area 1920 px x 800 px^) ^= 140 px at Top and Bottom.
echo If your target File is cropped (1920 px x 800 px) set all values to 0 or simply use the "Crop RPU" Function in Demuxer.
echo.
%WHITE%
echo  ========================================================================================================================
echo.
%RED%
echo All Settings will be Lost if you closed the Tool^!
%WHITE%
echo.
echo  ========================================================================================================================
echo.
call :colortxt 0F "L. Set " & call :colortxt 0E "LEFT" & call :colortxt 0F " Crop value [" & call :colortxt 0E "%RPU_AA_LC%" & call :colortxt 0F " px]" /n
call :colortxt 0F "T. Set " & call :colortxt 0E "TOP" & call :colortxt 0F " Crop value [" & call :colortxt 0E "%RPU_AA_TC%" & call :colortxt 0F " px]" /n
call :colortxt 0F "R. Set " & call :colortxt 0E "RIGHT" & call :colortxt 0F " Crop value [" & call :colortxt 0E "%RPU_AA_RC%" & call :colortxt 0F " px]" /n
call :colortxt 0F "B. Set " & call :colortxt 0E "BOTTOM" & call :colortxt 0F " Crop value [" & call :colortxt 0E "%RPU_AA_BC%" & call :colortxt 0F " px]" /n
echo.
%WHITE%
echo D. DISCARD Settings and Exit
echo S. SAVE Settings and Exit
echo.
%GREEN%
echo Change Settings and press [S] to SAVE or [D] to DISCARD^!
CHOICE /C LTRBDS /N /M "Select a Letter L,T,R,B,[D]iscard,[S]ave"

if "%ERRORLEVEL%"=="6" goto DV_INJCT
if "%ERRORLEVEL%"=="5" (
	set "RPU_AA_String=[LEAVE UNTOUCHED]"		
	goto DV_INJCT
)

if "%ERRORLEVEL%"=="4" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on BOTTOM side.
	echo Example: For cropping 140px on BOTTOM side type "140" and press Enter^!
	echo.
	set /p "RPU_AA_BC=Type in the Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="3" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on RIGHT side.
	echo Example: For cropping 140px on RIGHT side type "140" and press Enter^!
	echo.
	set /p "RPU_AA_RC=Type in the Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="2" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on TOP side.
	echo Example: For cropping 140px on TOP side type "140" and press Enter^!
	echo.
	set /p "RPU_AA_TC=Type in the Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="1" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on LEFT side.
	echo Example: For cropping 140px on LEFT side type "140" and press Enter^!
	echo.
	set /p "RPU_AA_LC=Type in the Pixels and press [ENTER]: "
)

goto :AA_AREA

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
TIMEOUT 30
exit