@echo off
title %~nx0

set GitBash="C:\Program Files\Git\git-bash.exe"
set KeyName=HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR\Enum

REM U�̾���
for /f "tokens=1-3" %%a in ('wmic logicaldisk get Description^,DeviceID^,VolumeName 2^>nul') do (
        if /i "%%a"=="���ƶ�����" (
                if /i "%%b\udisk\cmd\"=="%~dp0" (
                        set DeviceID=%%b
                )
        )
)

if defined DeviceID (
        label %DeviceID% UDISK
) else (
        echo,Error: �뽫�˳����Ƶ�U�̸�Ŀ¼������!
        pause>nul
        exit
)

REM ����uninstall.cmd
if not exist %~d0\LMT (
        mkdir %~d0\LMT
)

if exist %~dp0uninstall.cmd (
        copy /y %~dp0uninstall.cmd %~d0\LMT>nul
) else (
        echo,Error: %~dp0uninstall.cmd �ļ�������!
        pause>nul
        exit
)

REM U������ֵ
echo,�����Ҫ�Զ����ض����U��, �����U��!
echo,
echo,
echo,�밴���������...
pause>nul

if not exist %~d0\udisk\tmp (
        mkdir %~d0\udisk\tmp
)

type nul>%~d0\udisk\tmp\attr.tmp

for /f "tokens=1-3" %%a in ('reg query "%KeyName%" /v Count 2^>nul') do (
        if /i "%%a"=="Count" (
                set /a CountVar=%%c
        )
)

setlocal enabledelayedexpansion

for /l %%a in (1,1,%CountVar%) do (
        set /a Num=%%a-1
        
        for /f "tokens=1-3" %%b in ('reg query "%KeyName%" 2^>nul') do (
                if /i "%%b"=="!Num!" (
                        set Attr=%%d
                        set VID=!Attr:~8,4!
                        set PID=!Attr:~17,4!
                        set SN=!Attr:~22!
                        
                        echo,VID: !VID! PID: !PID! SN: !SN!>>%~d0\udisk\tmp\attr.tmp
                )
        )
)

endlocal

REM ��װGitBash
if not exist %GitBash% (
        if exist %~d0\udisk\resource\Git-2.18.0-64-bit.exe (
                cls
                echo,���ڰ�װ ���Ժ�...
                start /wait %~d0\udisk\resource\Git-2.18.0-64-bit.exe /sp- /silent /norestart
        ) else (
                echo,Error: %~d0\udisk\resource\Git-2.18.0-64-bit.exe �ļ�������!
                pause>nul
                exit
        )
)

if not exist %GitBash% (
        echo,Error: ��װʧ��!
        pause>nul
        exit
)

REM ����install.sh
if exist %~d0\udisk\shell\install.sh (
        start %GitBash% %~d0\udisk\shell\install.sh
) else (
        echo,Error: %~d0\udisk\shell\install.sh �ļ�������!
        pause>nul
        exit
)

exit