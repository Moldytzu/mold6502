@echo off
set base_dir=%~dp0
set tools=%base_dir%\tools\
set asm=%tools%\vasm6502_oldstyle.exe
set emu=python %tools%\emu.py
echo Base is %base_dir%
echo Tools are at %tools%
echo Assembler is at %asm%