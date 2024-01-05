@echo off
set base_dir=%~dp0
set tools=%base_dir%\tools\
set cc65=%tools%\cc65\bin\
rem set asm=%tools%\vasm6502_oldstyle.exe
set asm=%cc65%\ca65.exe
set ld=%cc65%\ld65.exe
set emu=python %tools%\emu.py
echo Base is %base_dir%
echo Tools are at %tools%
echo Assembler is at %asm%