@echo off
title %~nx0

set UdiskLabel=MYDISK
set KeyName=HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR\Enum
set Git=Git-2.18.0-64-bit.exe
set GitSrc=%~d0\mydisk\resource\%Git%
set GitBash="C:\Program Files\Git\git-bash.exe"

REM U�̾��
for /f "tokens=1-3" %%a in ('wmic logicaldisk get Description^,DeviceID^,VolumeName 2^>nul') do (
        if /i "%%a"=="���ƶ�����" (
                if /i "%%b\mydisk\cmd\"=="%~dp0" (
                        set DeviceID=%%b
                )
        )
)

if defined DeviceID (
        label %DeviceID% MYDISK
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

if not exist %~d0\mydisk\tmp (
        mkdir %~d0\mydisk\tmp
)

type nul>%~d0\mydisk\tmp\udisk.tmp

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
                        
                        echo,VID: !VID! PID: !PID! SN: !SN!>>%~d0\mydisk\tmp\udisk.tmp
                )
        )
)

endlocal

REM ��װGitBash
if not exist %GitBash% (
        if exist %~d0\mydisk\resource\Git-2.18.0-64-bit.exe (
                cls
                echo,���ڰ�װ ���Ժ�...
                start /wait %~d0\mydisk\resource\Git-2.18.0-64-bit.exe /sp- /silent /norestart
        ) else (
                echo,Error: %~d0\mydisk\resource\Git-2.18.0-64-bit.exe �ļ�������!
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
if exist %~d0\mydisk\shell\install.sh (
        start %GitBash% %~d0\mydisk\shell\install.sh
) else (
        echo,Error: %~d0\mydisk\shell\install.sh �ļ�������!
        pause>nul
        exit
)

exit

:EchoError
setlocal
set Message=%~1

if not defined Message (
        set Message=δ֪����
)

echo,Error: %Message%!
pause>nul
exit
(endlocal)
goto:eof
