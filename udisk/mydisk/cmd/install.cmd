@echo off
title %~nx0

set UdiskLabel=MYDISK
set KeyName=HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR\Enum
set Git=Git-2.18.0-64-bit.exe
set GitSrc=%~d0\mydisk\resource\%Git%
set GitBash="C:\Program Files\Git\git-bash.exe"

REM U盘卷标
for /f "tokens=1-3" %%a in ('wmic logicaldisk get Description^,DeviceID^,VolumeName 2^>nul') do (
        if /i "%%a"=="可移动磁盘" (
                if /i "%%b\mydisk\cmd\"=="%~dp0" (
                        set DeviceID=%%b
                )
        )
)

if defined DeviceID (
        label %DeviceID% %UdiskLabel%
) else (
        call :EchoError "请将此程序复制到U盘根目录下运行"
)

REM U盘属性值
echo,如果需要自动挂载额外的U盘, 请插入U盘!
echo,
echo,
echo,请按任意键继续...
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

REM 安装GitBash
if not exist %GitBash% (
        if exist %GitSrc% (
                cls
                echo,正在安装 请稍后...
                echo,
                
                start /wait %GitSrc% /sp- /silent /norestart
        ) else (
                call :EchoError "%GitSrc% 文件不存在"
        )
)

if not exist %GitBash% (
        call :EchoError "安装失败"
)

REM 运行install.sh
if exist %~d0\mydisk\shell\install.sh (
        start %GitBash% %~d0\mydisk\shell\install.sh
) else (
        call :EchoError "%~d0\mydisk\shell\install.sh 文件不存在"
)

exit

:EchoError
setlocal
set Message=%~1

if not defined Message (
        set Message=未知错误
)

echo,Error: %Message%!
pause>nul
exit
(endlocal)
goto:eof
