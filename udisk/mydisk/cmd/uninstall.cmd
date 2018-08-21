@echo off
title %~nx0

if exist %~d0\mydisk (
        rd /s /q %~d0\mydisk
)

exit
