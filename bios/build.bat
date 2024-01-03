@echo off

call %cd%\..\env.cmd

del /q bios.bin
%asm% -Fbin -chklabels -nocase -dotdir -o bios.bin entry.S