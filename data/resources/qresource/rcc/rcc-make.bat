@echo off

set rcc=rcc.exe
set opt=--verbose --compress-algo zlib --format-version 1 --binary

%rcc% %opt% ./../qrc/facet.qrc -o ./../rcc/facet.rcc

pause
