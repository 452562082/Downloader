@echo off
set _upx=".\tools\Free_UPX\upx.exe"
set Params=--nrv2b
%_upx% %Params% "downer.exe"
pause
