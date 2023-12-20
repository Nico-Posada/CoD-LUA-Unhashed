gcc -Wall -O3 -march=native -c .\util\C-functions\fnv64.c -o .\util\C-functions\fnv64.o
mkdir build 2> NUL
crystal build -o .\build\lua_dehasher.exe lua_dehasher.cr --release --no-debug