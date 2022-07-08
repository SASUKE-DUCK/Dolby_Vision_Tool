@echo off & setlocal
mode con cols=122 lines=57
TITLE DDVT DEMUXER [DonaldFaQ] v0.47 beta

rem --- Hardcoded settings. Can be changed manually ---
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "MKVEXTRACTpath=%~dp0tools\mkvextract.exe" rem Path to mkvextract.exe
set "MKVMERGEpath=%~dp0tools\mkvmerge.exe" rem Path to mkvmerge.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MP4FPSMODpath=%~dp0tools\mp4fpsmod.exe" rem Path to mp4fpsmod.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "HDR10P_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe
set "MP4Extract=FALSE"
set "MKVExtract=FALSE"
set "CONVERT=PROFILE 8.1 HDR"
set "CHGHDR10P=YES"
set "REMHDR10P=NO"
set "SAVHDR10P=NO"
set "CM_VERSION=V29"
set "CROP=NO"
set "BL=NO"
set "EL=NO"
set "RPU=YES"

rem --- Hardcoded settings. Cannot be changed ---
set HDR=No HDR Infos found
set DV=FALSE
set HDR10P=FALSE
set REMHDR10PString=
set EXTSTRING=
set RESOLUTION=n.a.
set HDR=n.a.
set CODEC_NAME=n.a.
set FRAMERATE=n.a.
set FRAMES=n.a.
set INPUTFILENAME=%~nx1
set RAW_FILE=FALSE
set WAIT="%sfkpath%" sleep
set GREEN="%sfkpath%" color green
set RED="%sfkpath%" color red
set YELLOW="%sfkpath%" color yellow
set WHITE="%sfkpath%" color white
set CYAN="%sfkpath%" color cyan
set MAGENTA="%sfkpath%" color magenta
set GREY="%sfkpath%" color grey
set ERRORCOUNT=0

%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
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
	echo No Input File. Use DDVT_DEMUXER.cmd "YourFilename.hevc/h265/mkv/mp4"
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
echo                                               Dolby Vision Tool DEMUXER
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
	goto DV8
)
echo "%HDR%" | find "dvhe.07">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "DV=TRUE"
	%GREEN%
	echo Dolby Vision Profile 7 found.
	%WHITE%
	goto DV7
)
echo "%HDR%" | find "dvhe.05">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	set "DV=TRUE"
	%GREEN%
	echo Dolby Vision Profile 5 found.
	%WHITE%
	goto DV5
)
if "%HDR10P%"=="TRUE" if "%DV%"=="FALSE" goto HDR10Plus 
if "%ERRORLEVEL%"=="1" (
	%RED%
	echo No Dolby Vision Profile found.
	echo Abort Operation now.
	goto EXIT
)

:HDR10Plus
if "%CM_VERSION%"=="V40" set "CM_VERSION_text=4.0"
if "%CM_VERSION%"=="V29" set "CM_VERSION_text=2.9"
echo.
"%MEDIAINFOpath%" --output=Video;%%MaxCLL%% %1>"%TEMP%\Info.txt"
set /p MaxCLL=<"%TEMP%\Info.txt"
set "MaxCLL=%MaxCLL:~0,-6%"
if "%MaxCLL%"=="~0,-6" set "MaxCLL=0
"%MEDIAINFOpath%" --output=Video;%%MaxFALL%% %1>"%TEMP%\Info.txt"
set /p MaxFALL=<"%TEMP%\Info.txt"
set "MaxFALL=%MaxFALL:~0,-6%"
if "%MaxFall%"=="~0,-6" set "MaxFALL=0"
"%MEDIAINFOpath%" --output=Video;%%MasteringDisplay_Luminance%% %1>"%TEMP%\Info.txt"
set /p Luminance=<"%TEMP%\Info.txt"
for /F "tokens=2" %%A in ("%Luminance%") do set MinDML=%%A
for /F "tokens=* delims=0." %%A in ("%MinDML%") do set "MinDML=%%A"
if "%MinDML%"=="" set "MinDML=1"
for /F "tokens=5" %%A in ("%Luminance%") do set MaxDML=%%A
if "%MaxDML%"=="" set "MaxDML=1000"
del "%TEMP%\Info.txt">nul
echo  == MENU ================================================================================================================
echo.
echo 1. SAVE HDR BL                    : [%BL%]
echo 2. SAVE HDR10+ Metadata           : [%SAVHDR10P%]
echo 3. Remove HDR10+ Metadata from BL : [%REMHDR10P%]
echo 4. Convert HDR10+ Metadata to DV  : [%CHGHDR10P%]
if "%CHGHDR10P%"=="YES" echo 5. Content Mapping Version        : [%CM_VERSION_text%]
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^!
if "%CHGHDR10P%"=="YES" (
	CHOICE /C 12345S /N /M "Select a Letter 1,2,3,4,5,[S]tart"
) else (
	CHOICE /C 1234S /N /M "Select a Letter 1,2,3,4,[S]tart"
)

if "%CHGHDR10P%"=="YES" (
	if "%ERRORLEVEL%"=="6" goto HDR10PlusEXT
) else (
	if "%ERRORLEVEL%"=="5" goto HDR10PlusEXT
)
if "%CHGHDR10P%"=="YES" (
	if "%ERRORLEVEL%"=="5" (
		if "%CM_VERSION%"=="V40" set "CM_VERSION=V29"
		if "%CM_VERSION%"=="V29" set "CM_VERSION=V40"
	)
)
if "%ERRORLEVEL%"=="4" (
	if "%CHGHDR10P%"=="NO" set "CHGHDR10P=YES"
	if "%CHGHDR10P%"=="YES" set "CHGHDR10P=NO"
)
if "%ERRORLEVEL%"=="3" (
	if "%REMHDR10P%"=="YES" set "REMHDR10P=NO"
	if "%REMHDR10P%"=="NO" (
		set "REMHDR10P=YES"
		set "BL=YES"
	)
)
if "%ERRORLEVEL%"=="2" (
	if "%SAVHDR10P%"=="YES" set "SAVHDR10P=NO"
	if "%SAVHDR10P%"=="NO" set "SAVHDR10P=YES"
)
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" (
		set "BL=NO"
		set "REMHDR10P=NO"
	)
)
goto START

:HDR10PlusEXT
if "%REMHDR10P%"=="YES" set "REMHDR10PString=--drop-hdr10plus"
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == SETTINGS ============================================================================================================
%CYAN%
echo.
echo SAVE HDR BL                    : [%BL%]
echo SAVE HDR10+ Metadata           : [%SAVHDR10P%]
echo Remove HDR10+ Metadata from BL : [%REMHDR10P%]
echo Convert HDR10+ Metadata to DV  : [%CHGHDR10P%]
echo Content Mapping Version        : [%CM_VERSION_text%]
echo.
%WHITE%
echo  == DEMUXING ============================================================================================================
echo.
%YELLOW%
echo ATTENTION^! You need many HDD Space for this operation.
echo.
if not exist "%~dpn1_[EXTRACTED]" md "%~dpn1_[EXTRACTED]"
if "%RAW_FILE%"=="FALSE" (
	%CYAN%
	echo Please wait. Extracting the Video Layer ...
	if "%MKVExtract%"=="TRUE" "%MKVEXTRACTpath%" "%~1" tracks 0:"%~dpn1_[EXTRACTED]\temp.hevc"
	if "%MP4Extract%"=="TRUE" "%MP4BOXpath%" -raw 1 -out "%~dpn1_[EXTRACTED]\temp.hevc" "%~1"
	set "VIDEOSTREAM=%~dpn1_[EXTRACTED]\temp.hevc"
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

if %BL%==YES (
	%CYAN%
	if "%REMHDR10P%"=="YES" echo Please wait. Extracting BL without HDR10+ Metadata...
	if "%REMHDR10P%"=="NO" echo Please wait. Extracting BL...
	PUSHD "%~dpn1_[EXTRACTED]"
	"%DO_VI_TOOLpath%" %REMHDR10PString% demux "%VIDEOSTREAM%"
	POPD
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

if "%SAVHDR10P%"=="YES" (
	if "%CHGHDR10P%"=="NO" (
		%CYAN%
		echo Please wait. Extracting HDR10+ Metadata...
		"%HDR10P_TOOLpath%" extract "%VIDEOSTREAM%" -o "%~dpn1_[EXTRACTED]\HDR10Plus.json"
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
)

if "%CHGHDR10P%"=="YES" (
	%CYAN%
	echo Please wait. Extracting HDR10+ Metadata...
	"%HDR10P_TOOLpath%" extract "%VIDEOSTREAM%" -o "%~dpn1_[EXTRACTED]\HDR10Plus.json"
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
	%CYAN%
	echo Please wait. Prefetching HDR10+ Metadata...
	echo {>"%~dpn1_[EXTRACTED]\Extra.json"
	echo	"cm_version": "%CM_VERSION%",>>"%~dpn1_[EXTRACTED]\Extra.json"
	echo 	"length": %FRAMES%,>>"%~dpn1_[EXTRACTED]\Extra.json"
	echo 	"level6": {>>"%~dpn1_[EXTRACTED]\Extra.json"
	echo	 	"max_display_mastering_luminance": %MaxDML%,>>"%~dpn1_[EXTRACTED]\Extra.json"
	echo	 	"min_display_mastering_luminance": %MinDML%,>>"%~dpn1_[EXTRACTED]\Extra.json"
	echo	 	"max_content_light_level": %MaxCLL%,>>"%~dpn1_[EXTRACTED]\Extra.json"
	echo	 	"max_frame_average_light_level": %MaxFall% >>"%~dpn1_[EXTRACTED]\Extra.json"
	echo 	}>>"%~dpn1_[EXTRACTED]\Extra.json"
	echo }>>"%~dpn1_[EXTRACTED]\Extra.json"
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
	%CYAN%
	echo Please wait. Generate RPU.bin...
	%YELLOW%
	"%DO_VI_TOOLpath%" generate -j "%~dpn1_[EXTRACTED]\Extra.json" --hdr10plus-json "%~dpn1_[EXTRACTED]\HDR10Plus.json" -o "%~dpn1_[EXTRACTED]\RPU.bin"
	if exist "%~dpn1_[EXTRACTED]\RPU.bin" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error during RPU.bin creating.
		set "ERRORCOUNT=1"
		echo.
	)
)

pause

%CYAN%
echo Please wait. Cleaning and Moving files ...
if exist "%~dpn1_[EXTRACTED]\EL.hevc" (
	del "%~dpn1_[EXTRACTED]\EL.hevc">nul
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting EL.hevc - Done.
	) else (
		%RED%
		echo Deleting EL.hevc - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
if exist "%~dpn1_[EXTRACTED]\temp.hevc" (
	%CYAN%
	del "%~dpn1_[EXTRACTED]\temp.hevc"
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
%CYAN%
if "%SAVHDR10P%"=="NO" (
	if exist "%~dpn1_[EXTRACTED]\HDR10Plus.json" (
		del "%~dpn1_[EXTRACTED]\HDR10Plus.json">nul
		if "%ERRORLEVEL%"=="0" (
			%GREEN%
			echo Deleting JSon Script - Done.
		) else (
			%RED%
			echo Deleting JSon Script - Error.
			set "ERRORCOUNT=1"
			echo.
		)
	)
)
if exist "%~dpn1_[EXTRACTED]\Extra.json" (
	del "%~dpn1_[EXTRACTED]\Extra.json">nul
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting JSon Script - Done.
	) else (
		%RED%
		echo Deleting JSon Script - Error.
		set "ERRORCOUNT=1"
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

:DV8
echo.
if "%CONVERT%"=="PROFILE 8.1 HDR" set "CONVERT=LEAVE UNTOUCHED"
if "%HDR10P%"=="TRUE" goto DV8HDR10P
echo  == MENU ================================================================================================================
echo.
echo 1. SAVE HDR BL         : [%BL%]
echo 2. SAVE RPU            : [%RPU%]
echo 3. CONVERT RPU         : [%CONVERT%]
call :colortxt 0F "4. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "           : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
echo.
call :colortxt 0F "C. CHECK RPU CROPPING VALUES" & call :colortxt 0E "*" & call :colortxt 0E " *Check and Fix wrong cropped Releases" /n
%WHITE%
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^!
CHOICE /C 1234CS /N /M "Select a Letter 1,2,3,4,[C]heck,[S]tart"

if "%ERRORLEVEL%"=="6" goto DV8EXT
if "%ERRORLEVEL%"=="5" goto DV8CHK
if "%ERRORLEVEL%"=="4" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="3" (
	if "%CONVERT%"=="LEAVE UNTOUCHED" set "CONVERT=PROFILE 7 MEL"
	if "%CONVERT%"=="PROFILE 7 MEL" set "CONVERT=PROFILE 8.1 HDR"
	if "%CONVERT%"=="PROFILE 8.1 HDR" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=LEAVE UNTOUCHED"
)
if "%ERRORLEVEL%"=="2" (
	if "%RPU%"=="NO" set "RPU=YES"
	if "%RPU%"=="YES" (
		set "RPU=NO"
		set "CROP=NO"
	)
)
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" set "BL=NO"
)
goto START

:DV8HDR10P
echo  == MENU ================================================================================================================
echo.
echo 1. SAVE HDR BL                    : [%BL%]
echo 2. SAVE RPU                       : [%RPU%]
echo 3. CONVERT RPU                    : [%CONVERT%]
call :colortxt 0F "4. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "                      : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
echo 5. Remove HDR10+ Metadata from BL : [%REMHDR10P%]
echo 6. SAVE HDR10+ Metadata           : [%SAVHDR10P%]
echo.
call :colortxt 0F "C. CHECK RPU CROPPING VALUES" & call :colortxt 0E "*" & call :colortxt 0E "            *Check and Fix wrong cropped Releases" /n
%WHITE%
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^!
CHOICE /C 123456CS /N /M "Select a Letter 1,2,3,4,5,6,[C]heck,[S]tart"

if "%ERRORLEVEL%"=="8" goto DV8EXT
if "%ERRORLEVEL%"=="7" goto DV8CHK
if "%ERRORLEVEL%"=="6" (
	if "%SAVHDR10P%"=="NO" set "SAVHDR10P=YES"
	if "%SAVHDR10P%"=="YES" set "SAVHDR10P=NO"
)
if "%ERRORLEVEL%"=="5" (
	if "%REMHDR10P%"=="YES" set "REMHDR10P=NO"
	if "%REMHDR10P%"=="NO" (
		set "REMHDR10P=YES"
		set "BL=YES"
	)		
)
if "%ERRORLEVEL%"=="4" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="3" (
	if "%CONVERT%"=="LEAVE UNTOUCHED" set "CONVERT=PROFILE 7 MEL"
	if "%CONVERT%"=="PROFILE 7 MEL" set "CONVERT=PROFILE 8.1 HDR"
	if "%CONVERT%"=="PROFILE 8.1 HDR" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=LEAVE UNTOUCHED"
)
if "%ERRORLEVEL%"=="2" (
	if "%RPU%"=="NO" set "RPU=YES"
	if "%RPU%"=="YES" (
		set "RPU=NO"
		set "CROP=NO"
	)
)
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" (
		set "BL=NO"
		set "REMHDR10P=NO"
	)
)
goto START

:DV8EXT
if "%REMHDR10P%"=="YES" set "REMHDR10PString=--drop-hdr10plus"
if "%CROP%"=="NO" set "CROPSTRING="
if "%CROP%"=="YES" set "CROPSTRING=-c"
if "%CONVERT%"=="LEAVE UNTOUCHED" set "CONVERTSTRING="
if "%CONVERT%"=="PROFILE 7 MEL" set "CONVERTSTRING=-m 1"
if "%CONVERT%"=="PROFILE 8.1 HDR" set "CONVERTSTRING=-m 2"
if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERTSTRING=-m 4"
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
if "%HDR10P%"=="TRUE" (
	echo  == SETTINGS ============================================================================================================
	%CYAN%
	echo.
	echo SAVE HDR BL                    : [%BL%]
	echo CROP RPU                       : [%CROP%]
	echo CONVERT RPU                    : [%CONVERT%]
	echo Remove HDR10+ Metadata from BL : [%REMHDR10P%]
	echo SAVE HDR10+ Metadata           : [%SAVHDR10P%]
	echo SAVE RPU                       : [%RPU%]
	echo.
	%WHITE%
) else (
	echo  == SETTINGS ============================================================================================================
	%CYAN%	
	echo.
	echo SAVE HDR BL                    : [%BL%]
	echo CROP RPU                       : [%CROP%]
	echo CONVERT RPU                    : [%CONVERT%]
	echo SAVE RPU                       : [%RPU%]
	echo.
	%WHITE%
)
if "%RAW_FILE%"=="FALSE" (
	echo  == DEMUXING ============================================================================================================
	echo.
	%YELLOW%
	echo ATTENTION^! You need many HDD Space for this operation.
	echo.
	if not exist "%~dpn1_[EXTRACTED]" md "%~dpn1_[EXTRACTED]"
	%CYAN%
	echo Please wait. Extracting the Video Layer ...
	if "%MKVExtract%"=="TRUE" "%MKVEXTRACTpath%" "%~1" tracks 0:"%~dpn1_[EXTRACTED]\temp.hevc"
	if "%MP4Extract%"=="TRUE" "%MP4BOXpath%" -raw 1 -out "%~dpn1_[EXTRACTED]\temp.hevc" "%~1"
	set "VIDEOSTREAM=%~dpn1_[EXTRACTED]\temp.hevc"
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
if "%HDR10P%"=="TRUE" if "%SAVHDR10P%"=="YES" (
	%CYAN%
	echo Please wait. Extracting HDR10+ Metadata...
	"%HDR10P_TOOLpath%" extract "%VIDEOSTREAM%" -o "%~dpn1_[EXTRACTED]\HDR10Plus.json"
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


if %BL%==NO if %EL%==NO goto DV8RPUEXTRACT

%CYAN%
echo Please wait. Extracting BL...
PUSHD "%~dpn1_[EXTRACTED]"
"%DO_VI_TOOLpath%" %REMHDR10PString% demux "%VIDEOSTREAM%"
POPD
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

:DV8RPUEXTRACT
if "%RPU%"=="NO" goto DV8CLEANING
%CYAN%
echo Please wait. Extracting the RPU Metadata Binary ...
"%DO_VI_TOOLpath%" %CROPSTRING% %CONVERTSTRING% extract-rpu "%VIDEOSTREAM%" -o "%~dpn1_[EXTRACTED]\RPU.bin"
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

:DV8CLEANING
%CYAN%
echo Please wait. Cleaning and Moving files ...
if exist "%~dpn1_[EXTRACTED]\EL.hevc" (
	del "%~dpn1_[EXTRACTED]\EL.hevc">nul
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting EL.hevc - Done.
	) else (
		%RED%
		echo Deleting EL.hevc - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
if exist "%~dpn1_[EXTRACTED]\temp.hevc" (
	%CYAN%
	del "%~dpn1_[EXTRACTED]\temp.hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp File - Done.
	) else (
		%RED%
		echo Deleting Temp File - Error.
		set "ERRORCOUNT=1"
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

:DV8CHK
set AA_LC=Untouched
set AA_TC=Untouched
set AA_RC=Untouched
set AA_BC=Untouched
set RPU_AA_LC=Undefined
set RPU_AA_TC=Undefined
set RPU_AA_RC=Undefined
set RPU_AA_BC=Undefined
set "CONTAINERSTREAM=%~1"
cls
echo.
%WHITE%
if "%RAW_FILE%"=="FALSE" (
	echo  == DEMUXING ============================================================================================================
	echo.
	%YELLOW%
	echo ATTENTION^! You need many HDD Space for this operation.
	echo.
	if not exist "%~dpn1_[EXTRACTED]" md "%~dpn1_[EXTRACTED]"
	%CYAN%
	echo Please wait. Extracting the Video Layer ...
	if "%MKVExtract%"=="TRUE" "%MKVEXTRACTpath%" "%~1" tracks 0:"%~dpn1_[EXTRACTED]\temp.hevc"
	if "%MP4Extract%"=="TRUE" "%MP4BOXpath%" -raw 1 -out "%~dpn1_[EXTRACTED]\temp.hevc" "%~1"
	set "VIDEOSTREAM=%~dpn1_[EXTRACTED]\temp.hevc"
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
) else (
	echo  == MUXING ==============================================================================================================
	echo.
	%YELLOW%
	echo ATTENTION^! You need many HDD Space for this operation.
	echo.
	if not exist "%~dpn1_[EXTRACTED]" md "%~dpn1_[EXTRACTED]"
	SETLOCAL ENABLEDELAYEDEXPANSION
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	%RED% 
	echo Don't close the "Muxing into MKV Container" cmd window.
	start /WAIT /MIN "Muxing into MKV Container" "%MKVMERGEpath%" --output ^"%~dpn1_[EXTRACTED]\temp.mkv^" ^"^(^" ^"%~1^" ^"^)^" --language 0:und --compression 0:none ^"^(^" ^"%VIDEOSTREAM%^" ^"^)^"
	set "CONTAINERSTREAM=%~dpn1_[EXTRACTED]\temp.mkv"
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
%CYAN%
echo Please wait. Analysing Videostream ...
"%~dp0tools\DetectBorders.exe" --ffmpeg-path="%FFMPEGpath%" --input-file="%CONTAINERSTREAM%" --log-file="%TEMP%\Crop.txt"
FOR /F "tokens=2-5 delims=(,-)" %%A IN (%TEMP%\Crop.txt) DO (
	set AA_LC=%%A
	set AA_TC=%%B
	set AA_RC=%%C
	set AA_BC=%%D
)
IF EXIST "%TEMP%\Crop.txt" (
	del "%TEMP%\Crop.txt"
	%GREEN%
	echo Done.
	echo.
) else (
	%YELLOW%
	echo Analysing failed.
	set AA_LC=Untouched
	set AA_TC=Untouched
	set AA_RC=Untouched
	set AA_BC=Untouched
	echo.
)
set "AA_String=[LEFT=%AA_LC% px], [TOP=%AA_TC% px], [RIGHT=%AA_RC% px], [BOTTOM=%AA_BC% px]"
if "%AA_LC%%AA_TC%%AA_RC%%AA_BC%"=="UntouchedUntouchedUntouchedUntouched" set "RPU_AA_String=[ANALYSING FAILED^!]"

%CYAN%
echo Please wait. Analysing RPU Binary ...
"%DO_VI_TOOLpath%" extract-rpu "%VIDEOSTREAM%" -o "%~dpn1_[EXTRACTED]\RPU.bin"
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
set "RPUFILE=%~dpn1_[EXTRACTED]\RPU.bin"
IF EXIST %RPUFILE% (
	"%DO_VI_TOOLpath%" info -i "%RPUFILE%" -f 01>"%TEMP%\Info.json"
	SETLOCAL ENABLEDELAYEDEXPANSION
	IF EXIST "%TEMP%\Info.json" (
		FOR /F "delims=" %%A IN ('findstr /C:"active_area_left_offset" "%TEMP%\Info.json"') DO (
			set RPU_AA_LC=%%A
			set RPU_AA_LC=!RPU_AA_LC:*:=!
			set RPU_AA_LC=!RPU_AA_LC:~1,-1!
		)
		FOR /F "delims=" %%A IN ('findstr /C:"active_area_top_offset" "%TEMP%\Info.json"') DO (
			set RPU_AA_TC=%%A
			set RPU_AA_TC=!RPU_AA_TC:*:=!
			set RPU_AA_TC=!RPU_AA_TC:~1,-1!
		)
		FOR /F "delims=" %%A IN ('findstr /C:"active_area_right_offset" "%TEMP%\Info.json"') DO (
			set RPU_AA_RC=%%A
			set RPU_AA_RC=!RPU_AA_RC:*:=!
			set RPU_AA_RC=!RPU_AA_RC:~1,-1!
		)
		FOR /F "delims=" %%A IN ('findstr /C:"active_area_bottom_offset" "%TEMP%\Info.json"') DO (
			set RPU_AA_BC=%%A
			set RPU_AA_BC=!RPU_AA_BC:*:=!
			set RPU_AA_BC=!RPU_AA_BC:~1!
		)
	)
	IF EXIST "%TEMP%\Info.json" DEL "%TEMP%\Info.json">nul
	SETLOCAL DISABLEDELAYEDEXPANSION
)
set "RPU_AA_String=[LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px]"
if "%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%"=="UndefinedUndefinedUndefinedUndefined" set "RPU_AA_String=[NOT SET IN RPU]"
IF "%RAW_FILE%"=="TRUE" IF EXIST %CONTAINERSTREAM% DEL %CONTAINERSTREAM%

:DV8CHKMENU
set "RPUMATCH=FALSE"
IF "%AA_LC%%AA_TC%%AA_RC%%AA_BC%"=="%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%" set "RPUMATCH=TRUE"
IF "%RPUMATCH%"=="TRUE" (
	set "RPU_AA_String=call :colortxt 0B "Borders = [LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px] [" & call :colortxt 0A "MATCH WITH VIDEO" & call :colortxt 0B "]" /n
	set "AA_String=call :colortxt 0B "Borders = [LEFT=%AA_LC% px], [TOP=%AA_TC% px], [RIGHT=%AA_RC% px], [BOTTOM=%AA_BC% px] [" & call :colortxt 0A "MATCH WITH RPU" & call :colortxt 0B "]" /n
) else (
	set "RPU_AA_String=call :colortxt 0B "Borders = [LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0B "]" /n
	set "AA_String=call :colortxt 0B "Borders = [LEFT=%AA_LC% px], [TOP=%AA_TC% px], [RIGHT=%AA_RC% px], [BOTTOM=%AA_BC% px] [" & call :colortxt 0C "NOT MATCH WITH RPU" & call :colortxt 0B "]" /n
)
IF "%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%"=="UndefinedUndefinedUndefinedUndefined" set "RPU_AA_String=call :colortxt 0B "Borders = [" & call :colortxt 0C "BORDERS NOT SET IN RPU" & call :colortxt 0B "]" /n
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                             Dolby Vision Tool CROP CHECK
%WHITE%
echo                                         ====================================
echo.
echo.
%WHITE%
echo  == FILENAME ============================================================================================================
%CYAN%
echo.
echo %INPUTFILENAME%
echo.
%WHITE%
echo  == MOVIE INPUT =========================================================================================================
%YELLOW%
echo.
%AA_String%
%WHITE%
echo.
echo.
echo  == RPU INPUT ===========================================================================================================
echo.
%YELLOW%
%RPU_AA_String%
%WHITE%
echo.
echo.
echo  == EDIT ACTIVE AREA ====================================================================================================
echo.
IF "%RPUMATCH%"=="TRUE" (
	%GREEN%
	echo All Cropping values correct. Nothing to do^!
) else (
	%RED%
	echo Cropping values incorrect. Please use ^[S^] to fix them^!
)
%WHITE%
echo.
echo  ========================================================================================================================
echo.
echo L. Set LEFT Crop value [%AA_LC% px]
echo T. Set TOP Crop value [%AA_TC% px]
echo R. Set RIGHT Crop value [%AA_RC% px]
echo B. Set BOTTOM Crop value [%AA_BC% px]
echo.
IF "%RPUMATCH%"=="TRUE" (
	echo S. SAVE and FIX Release
	%YELLOW%
	echo E. EXIT and do nothing [RECOMMENDED]
) else (
	%YELLOW%
	echo S. SAVE and FIX Release [RECOMMENDED]
	%WHITE%
	echo E. EXIT and do nothing
)
echo.
%GREEN%
echo Change Settings and press [S] to SAVE or [E] to EXIT^!
CHOICE /C LTRBSE /N /M "Select a Letter L,T,R,B,[S]ave,[E]xit"

if "%ERRORLEVEL%"=="6" goto DV8CHKCLEAN
if "%ERRORLEVEL%"=="5" goto DV8CHKFIX
if "%ERRORLEVEL%"=="4" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on BOTTOM side.
	echo Example: For cropping 140px on BOTTOM side type "140" and press Enter^!
	echo.
	set /p "AA_BC=Type in the Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="3" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on RIGHT side.
	echo Example: For cropping 140px on RIGHT side type "140" and press Enter^!
	echo.
	set /p "AA_RC=Type in the Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="2" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on TOP side.
	echo Example: For cropping 140px on TOP side type "140" and press Enter^!
	echo.
	set /p "AA_TC=Type in the Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="1" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on LEFT side.
	echo Example: For cropping 140px on LEFT side type "140" and press Enter^!
	echo.
	set /p "AA_LC=Type in the Pixels and press [ENTER]: "
)

goto :DV8CHKMENU

:DV8CHKFIX
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                             Dolby Vision Tool CROP CHECK
%WHITE%
echo                                         ====================================
echo.
echo.
%WHITE%
echo  == MOVIE INPUT =========================================================================================================
%CYAN%
echo.
%AA_String%
%WHITE%
echo.
echo.
echo  == RPU INPUT ===========================================================================================================
echo.
%CYAN%
%RPU_AA_String%
%WHITE%
echo.
echo.
echo  == FIXING RELEASE ======================================================================================================
%CYAN%
echo.
echo Please wait. Applying cropping values...
echo ^{ >"%~dpn1_[EXTRACTED]\CROP.json"
echo   ^"active_area^"^: ^{ >>"%~dpn1_[EXTRACTED]\CROP.json"
echo     ^"presets^"^: ^[ >>"%~dpn1_[EXTRACTED]\CROP.json"
echo       ^{ >>"%~dpn1_[EXTRACTED]\CROP.json"
echo       	 ^"id^"^: 0, >>"%~dpn1_[EXTRACTED]\CROP.json"
echo       	 ^"left^"^: %AA_LC%, >>"%~dpn1_[EXTRACTED]\CROP.json"
echo       	 ^"right^"^: %AA_RC%, >>"%~dpn1_[EXTRACTED]\CROP.json"
echo       	 ^"top^"^: %AA_TC%, >>"%~dpn1_[EXTRACTED]\CROP.json"
echo      	 ^"bottom^"^: %AA_BC% >>"%~dpn1_[EXTRACTED]\CROP.json"
echo       ^} >>"%~dpn1_[EXTRACTED]\CROP.json"
echo     ^], >>"%~dpn1_[EXTRACTED]\CROP.json"
echo      ^"edits^"^: { >>"%~dpn1_[EXTRACTED]\CROP.json"
echo      ^"all^"^: 0 >>"%~dpn1_[EXTRACTED]\CROP.json"
echo     ^} >>"%~dpn1_[EXTRACTED]\CROP.json"
echo   ^} >>"%~dpn1_[EXTRACTED]\CROP.json"
echo ^} >>"%~dpn1_[EXTRACTED]\CROP.json"

"%DO_VI_TOOLpath%" editor -i "%RPUFILE%" -j "%~dpn1_[EXTRACTED]\CROP.json" --rpu-out "%~dpn1_[EXTRACTED]\RPU-cropped.bin">nul
IF EXIST "%~dpn1_[EXTRACTED]\RPU-cropped.bin" (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set "ERRORCOUNT=1"
	echo.
)
del "%~dpn1_[EXTRACTED]\CROP.json"
set "RPUFILE=%~dpn1_[EXTRACTED]\RPU-cropped.bin"
%CYAN%
echo Please wait. Injecting the RPU Metadata Binary into stream...
%WHITE%
"%DO_VI_TOOLpath%" inject-rpu -i "%VIDEOSTREAM%" --rpu-in "%RPUFILE%" -o "%~dpn1_[FIXED].hevc"
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
IF "%RAW_FILE%"=="FALSE" (
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

if "%MKVExtract%"=="TRUE" (
	set "duration="
	SETLOCAL ENABLEDELAYEDEXPANSION
	if "!FRAMERATE!"=="23.976" set "duration=--default-duration 0:24000/1001p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="24.000" set "duration=--default-duration 0:24p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="25.000" set "duration=--default-duration 0:25p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="30.000" set "duration=--default-duration 0:30p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="60.000" set "duration=--default-duration 0:60p --fix-bitstream-timing-information 0:1"
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	%RED% 
	echo Don't close the "Muxing into MKV Container" cmd window.
	start /WAIT /MIN "Muxing into MKV Container" "%MKVMERGEpath%" --output ^"%~dpn1_[FIXED].mkv^" --no-video ^"^(^" ^"%~1^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"%~dpn1_[FIXED].hevc^" ^"^)^" --track-order 1:0
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
	
if "%MP4Extract%"=="TRUE" (
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
	"%MP4BOXpath%" -add "%~dpn1_[HDR10+ INJECTED].hevc:ID=1:NAME=" "%~dpn1_[temp].mp4" -out "%~dpn1_[FIXED].mp4"
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

:DV8CHKCLEAN
%CYAN%
echo Please wait. Cleaning and Moving files ...
IF "%RAW_FILE%"=="FALSE" (
	IF EXIST "%~dpn1_[FIXED].hevc" (
		del "%~dpn1_[FIXED].hevc">nul
		if "%ERRORLEVEL%"=="0" (
			%GREEN%
			echo Deleting Temp File - Done.
		) else (
			%RED%
			echo Deleting Temp File - Error.
			set "ERRORCOUNT=1"
		)
	)
)

IF EXIST "%~dpn1_[EXTRACTED]" (
	RD /S /Q "%~dpn1_[EXTRACTED]"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp Folder - Done.
	) else (
		%RED%
		echo Deleting Temp Folder - Error.
		set "ERRORCOUNT=1"
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

goto EXIT

	
:DV7
echo.
if "%RESOLUTION%"=="3840x2160 DL" (
	%yellow%
	echo No Support for Double Layer Profile 7 File^! 
	echo.
	%WHITE%
	goto EXIT
)
if "%HDR10P%"=="TRUE" goto DV7HDR10P
echo  == MENU ================================================================================================================
echo.
call :colortxt 0F "1. SAVE HDR BL" & call :colortxt 0E "*" & call :colortxt 0F "        : [%BL%]" & call :colortxt 0E " *For creating a Dual layer Profile 7 Disc set to [YES]." /n
call :colortxt 0F "2. SAVE DoVI EL" & call :colortxt 0E "*" & call :colortxt 0F "       : [%EL%]" & call :colortxt 0E " *For creating a Dual layer Profile 7 Disc set to [YES]." /n
echo 3. SAVE RPU            : [%RPU%]
echo 4. CONVERT RPU         : [%CONVERT%]
call :colortxt 0F "5. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "           : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^!
CHOICE /C 12345S /N /M "Select a Letter 1,2,3,4,5,[S]tart"
if "%ERRORLEVEL%"=="6" goto DV7EXT
if "%ERRORLEVEL%"=="5" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="4" (
	if "%CONVERT%"=="LEAVE UNTOUCHED" set "CONVERT=PROFILE 8.1 HDR"
	if "%CONVERT%"=="PROFILE 8.1 HDR" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=LEAVE UNTOUCHED"
)
if "%ERRORLEVEL%"=="3" (
	if "%RPU%"=="NO" set "RPU=YES"
	if "%RPU%"=="YES" (
		set "RPU=NO"
		set "CROP=NO"
	)
)
if "%ERRORLEVEL%"=="2" (
	if "%EL%"=="NO" set "EL=YES"
	if "%EL%"=="YES" set "EL=NO"
)
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" set "BL=NO"
)
goto START

:DV7HDR10P
if "%RESOLUTION%"=="3840x2160 DL" (
	%yellow%
	echo No Support for Double Layer Profile 7 File^! 
	echo.
	%WHITE%
	goto EXIT
)
echo  == MENU ================================================================================================================
echo.
call :colortxt 0F "1. SAVE HDR BL" & call :colortxt 0E "*" & call :colortxt 0F "                   : [%BL%]" & call :colortxt 0E " *For creating a Dual layer Profile 7 Disc set to [YES]." /n
echo 2. Remove HDR10+ Metadata from BL : [%REMHDR10P%]
echo 3. SAVE HDR10+ Metadata           : [%SAVHDR10P%]
call :colortxt 0F "4. SAVE DoVI EL" & call :colortxt 0E "*" & call :colortxt 0F "                  : [%EL%]" & call :colortxt 0E " *For creating a Dual layer Profile 7 Disc set to [YES]." /n
echo 5. SAVE RPU                       : [%RPU%]
echo 6. CONVERT RPU                    : [%CONVERT%]
call :colortxt 0F "7. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "                      : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^!
CHOICE /C 1234567S /N /M "Select a Letter 1,2,3,4,5,6,7,[S]tart"

if "%ERRORLEVEL%"=="8" goto DV7EXT
if "%ERRORLEVEL%"=="7" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="6" (
	if "%CONVERT%"=="LEAVE UNTOUCHED" set "CONVERT=PROFILE 8.1 HDR"
	if "%CONVERT%"=="PROFILE 8.1 HDR" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=LEAVE UNTOUCHED"
)
if "%ERRORLEVEL%"=="5" (
	if "%RPU%"=="NO" set "RPU=YES"
	if "%RPU%"=="YES" (
		set "RPU=NO"
		set "CROP=NO"
	)
)
if "%ERRORLEVEL%"=="4" (
	if "%EL%"=="NO" set "EL=YES"
	if "%EL%"=="YES" set "EL=NO"
)
if "%ERRORLEVEL%"=="3" (
	if "%SAVHDR10P%"=="NO" set "SAVHDR10P=YES"
	if "%SAVHDR10P%"=="YES" set "SAVHDR10P=NO"
)
if "%ERRORLEVEL%"=="2" (
	if "%REMHDR10P%"=="YES" set "REMHDR10P=NO"
	if "%REMHDR10P%"=="NO" (
		set "REMHDR10P=YES"
		set "BL=YES"
	)
)
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" (
		set "BL=NO"
		set "REMHDR10P=NO"
	)
)
goto START

:DV7EXT
if "%REMHDR10P%"=="YES" set "REMHDR10PString=--drop-hdr10plus"
if "%CONVERT%"=="LEAVE UNTOUCHED" set "CONVERTSTRING="
if "%CONVERT%"=="PROFILE 8.1 HDR" set "CONVERTSTRING=-m 2"
if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERTSTRING=-m 4"
if "%BL%"=="NO" set "EXTSTRING=--el-only"
if "%CROP%"=="YES" set "CROPSTRING=-c"
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
if "%HDR10P%"=="TRUE" (
	echo  == SETTINGS ============================================================================================================	
	%CYAN%
	echo.
	echo SAVE HDR BL                    : [%BL%]
	echo SAVE DoVI EL                   : [%EL%]
	echo SAVE RPU                       : [%RPU%]
	echo CONVERT RPU                    : [%CONVERT%]
	echo CROP RPU                       : [%CROP%]
	echo Remove HDR10+ Metadata from BL : [%REMHDR10P%]
	echo.
	%WHITE%
) else (
	echo  == SETTINGS ============================================================================================================
	%CYAN%
	echo.
	echo SAVE HDR BL         : [%BL%]
	echo SAVE DoVI EL        : [%EL%]
	echo SAVE RPU            : [%RPU%]
	echo CONVERT RPU         : [%CONVERT%]
	echo CROP RPU            : [%CROP%]
	echo.
	%WHITE%
)
	
echo  == DEMUXING ============================================================================================================
echo.
%YELLOW%
echo ATTENTION^! You need many HDD Space for this operation.
if not exist "%~dpn1_[EXTRACTED]" md "%~dpn1_[EXTRACTED]"
echo.
if "%RAW_FILE%"=="FALSE" (
	%CYAN%
	echo Please wait. Extracting the Video Layer ...
	if "%MKVExtract%"=="TRUE" "%MKVEXTRACTpath%" "%~1" tracks 0:"%~dpn1_[EXTRACTED]\temp.hevc"
	if "%MP4Extract%"=="TRUE" "%MP4BOXpath%" -raw 1 -out "%~dpn1_[EXTRACTED]\temp.hevc" "%~1"
	set "VIDEOSTREAM=%~dpn1_[EXTRACTED]\temp.hevc"
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
if "%HDR10P%"=="TRUE" if "%SAVHDR10P%"=="YES" (
	%CYAN%
	echo Please wait. Extracting HDR10+ Metadata...
	"%HDR10P_TOOLpath%" extract "%VIDEOSTREAM%" -o "%~dpn1_[EXTRACTED]\HDR10Plus.json"
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

if "%BL%"=="NO" if "%EL%"=="NO" goto DV7RPUEXTRACT

%CYAN%
echo Please wait. Extracting choosen Layer^(s^) ...
PUSHD "%~dpn1_[EXTRACTED]"
"%DO_VI_TOOLpath%" %REMHDR10PString% demux %EXTSTRING% "%VIDEOSTREAM%"
POPD
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
if "%RPU%"=="NO" goto DV7CLEANING

:DV7RPUEXTRACT
if "%RPU%"=="NO" goto DV7CLEANING
%CYAN%
echo Please wait. Extracting RPU Metadata Binary ...
"%DO_VI_TOOLpath%" %CROPSTRING% %CONVERTSTRING% extract-rpu "%VIDEOSTREAM%" -o "%~dpn1_[EXTRACTED]\RPU.bin"
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
	
:DV7CLEANING
%CYAN%
echo Please wait. Cleaning and Moving files ...
if exist "%~dpn1_[EXTRACTED]\EL.hevc" if "%EL%"=="NO" (
	del "%~dpn1_[EXTRACTED]\EL.hevc">nul
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting EL.hevc - Done.
	) else (
		%RED%
		echo Deleting EL.hevc - Error.
		set "ERRORCOUNT=1"
		echo.
	)
)
if exist "%~dpn1_[EXTRACTED]\temp.hevc" (
	%CYAN%
	del "%~dpn1_[EXTRACTED]\temp.hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp File - Done.
	) else (
		%RED%
		echo Deleting Temp File - Error.
		set "ERRORCOUNT=1"
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

:DV5
echo.
echo  == MENU ================================================================================================================
echo.
echo 1. CONVERT RPU         : [%CONVERT%]
call :colortxt 0F "2. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "           : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^!
CHOICE /C 12S /N /M "Select a Letter 1,2,[S]tart"

if "%ERRORLEVEL%"=="3" goto DV5EXT
if "%ERRORLEVEL%"=="2" (
	if "%CROP%"=="NO" set "CROP=YES"
	if "%CROP%"=="YES" set "CROP=NO"
)
if "%ERRORLEVEL%"=="1" (
	if "%CONVERT%"=="LEAVE UNTOUCHED" set "CONVERT=PROFILE 8.1 HDR"
	if "%CONVERT%"=="PROFILE 8.1 HDR" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=LEAVE UNTOUCHED"
)
goto START

:DV5EXT
if "%CONVERT%"=="LEAVE UNTOUCHED" set "CONVERTSTRING="
if "%CONVERT%"=="PROFILE 8.1 HDR" set "CONVERTSTRING=-m 3"
if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERTSTRING=-m 4"
if "%CROP%"=="NO" set "CROPSTRING="
if "%CROP%"=="YES" set "CROPSTRING=-c"
cls
%GREEN%
echo  powered by quietvoids tools                                                                 Copyright (c) 2021 DonaldFaQ
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == SETTINGS ============================================================================================================
%CYAN%
echo.
echo CONVERT RPU         : [%CONVERT%]
echo CROP RPU            : [%CROP%]
echo.
%WHITE%
echo  == DEMUXING ============================================================================================================
echo.
%YELLOW%
echo ATTENTION^! You need many HDD Space for this operation.
if not exist "%~dpn1_[EXTRACTED]" md "%~dpn1_[EXTRACTED]"
echo.
if "%RAW_FILE%"=="FALSE" (
	%CYAN%
	echo Please wait. Extracting the Video Layer ...
	if "%MKVExtract%"=="TRUE" "%MKVEXTRACTpath%" "%~1" tracks 0:"%~dpn1_[EXTRACTED]\temp.hevc"
	if "%MP4Extract%"=="TRUE" "%MP4BOXpath%" -raw 1 -out "%~dpn1_[EXTRACTED]\temp.hevc" "%~1"
	set "VIDEOSTREAM=%~dpn1_[EXTRACTED]\temp.hevc"
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
echo Please wait. Extracting the RPU Metadata Binary ...
"%DO_VI_TOOLpath%" %CROPSTRING% %CONVERTSTRING% extract-rpu "%VIDEOSTREAM%" -o "%~dpn1_[EXTRACTED]\RPU.bin"
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
%CYAN%
echo Please wait. Cleaning and Moving files ...
if exist "%~dpn1_[EXTRACTED]\temp.hevc" (
	del "%~dpn1_[EXTRACTED]\temp.hevc"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp File - Done.
	) else (
		%RED%
		echo Deleting Temp File - Error.
		set "ERRORCOUNT=1"
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