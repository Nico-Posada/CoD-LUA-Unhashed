@echo off
mkdir bin 2> NUL
gcc -m64 -Wall -O3 -march=native -c .\src\util\C-src\fnv64.c -o .\src\util\C-src\fnv64.o
crystal build -o .\bin\lua_dehasher.exe .\src\lua_dehasher.cr --release --no-debug