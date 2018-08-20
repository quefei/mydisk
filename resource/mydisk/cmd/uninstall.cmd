@echo off
title %~nx0

if exist %~d0\udisk (
        rd /s /q %~d0\udisk
)

exit
