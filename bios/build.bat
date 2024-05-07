@echo off

call %cd%\..\env.cmd

del /q bios.bin *.o


rem %asm% -Fbin -chklabels -nocase -dotdir -ldots -I"%cd%" -o bios.bin entry.S
@echo on
%asm%  --cpu 65c02 -t none -I"%cd%" -o entry.o entry.S
%ld%  -C sbc.cfg -o bios.bin entry.o