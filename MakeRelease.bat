rem Delete old release
del "Release.zip" /q

rem Open folder with application
cd "Release\"

rem Delete old PowerOff.exe.old
del "PowerOff.exe.old" /q

rem Create Release archive
set Zip=..\7za.exe
"%Zip%" a "..\Release.zip" -ssw

exit