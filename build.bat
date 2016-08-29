@echo off

echo LPP-Build Script by gnmmarechal
echo ===================================
echo Version: 1.0
echo Project: StarUpdater by astronautlevel
echo ===================================
if "%1" == "clean" goto clean
echo Cleaning romfs directory....
del Builder\romfs\index.lua
echo Copying updated script to romfs directory...
::Copy the new index to romfs
copy index.lua Builder\romfs
echo Creating romfs file from directory...
cd Builder
tools\3dstool -cvtf romfs romfs.bin --romfs-dir romfs

if "%1" == "" goto all
if %1 == cia-b goto cia
if %1 == 3dsx-b goto 3dsx

goto %1

:all
call :cia-b
call :3dsx-b
echo Created all targets.
cd ..
exit /b

:3dsx
call :3dsx-b
echo Created all targets.
cd ..
exit /b
:cia
call :cia-b
echo Created all targets.
cd ..
exit /b

:3dsx-b
echo Creating SMDH...
tools\bannertool makesmdh -s "StarUpdater" -l "StarUpdater for Luma3DS" -p "astronautlevel" -i starlogo.png -o StarUpdater.smdh
echo Creating target 2 - 3DSX...
tools\3dsxtool bin/lpp-3ds.elf ../StarUpdater.3dsx --romfs=romfs.bin --smdh=StarUpdater.smdh
goto :EOF

:cia-b
echo Creating banner from files...
tools\bannertool makebanner -i banner.png -a luma.wav -o banner.bin
echo Creating icon from file...
tools\bannertool makesmdh -s "StarUpdater" -l "StarUpdater for Luma3DS" -p "astronautlevel" -i starlogo.png -o icon.bin
echo Creating target 1 - CIA ...
tools\makerom -f cia -o ../StarUpdater.cia -elf bin/lpp-3ds.elf -rsf StarUpdater.rsf -icon icon.bin -banner banner.bin -exefslogo -target t -romfs romfs.bin
goto :EOF

:clean
echo Cleaning...
cd Builder
del ..\*.3dsx
del ..\*.cia
del romfs\*.lua
del *.bin
del *.smdh
cd ..
echo Cleaned.
exit /b