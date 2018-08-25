@echo off
title %~nx0

set UdiskLabel=MYDISK
set KeyName=HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR\Enum
set Git=Git-2.18.0-64-bit.exe
set GitSrc=%~d0\mydisk\resource\%Git%
set GitBash="C:\Program Files\Git\git-bash.exe"

REM U�̾���
for /f "tokens=1-3" %%a in ('wmic logicaldisk get Description^,DeviceID^,VolumeName 2^>nul') do (
        if /i "%%a"=="���ƶ�����" (
                if /i "%%b\mydisk\cmd\"=="%~dp0" (
                        set DeviceID=%%b
                )
        )
)

if defined DeviceID (
        label %DeviceID% %UdiskLabel%
) else (
        call :EchoError "�뽫�˳����Ƶ�U�̸�Ŀ¼������"
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
        if exist %GitSrc% (
                cls
                echo,���ڰ�װ ���Ժ�...
                echo,
                
                start /wait %GitSrc% /sp- /silent /norestart
        ) else (
                call :EchoError "%GitSrc% �ļ�������"
        )
)

if not exist %GitBash% (
        call :EchoError "��װʧ��"
)

REM ����mydisk.sh
if exist %~d0\mydisk\shell\mydisk.sh (
        start %GitBash% %~d0\mydisk\shell\mydisk.sh
) else (
        call :EchoError "%~d0\mydisk\shell\mydisk.sh �ļ�������"
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