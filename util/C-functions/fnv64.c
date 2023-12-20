#define ull unsigned long long

ull fnv64(const char* string) {
    ull hash = 0x47F5817A5EF961BA;
    ull prime = 0x100000001B3;

    for (int i = 0; string[i]; ++i) {
        char cur = string[i];
        if ((unsigned char)(cur - 'A') <= 25)
            cur |= 0x20;

        if (cur == '\\')
            cur = '/';

        hash ^= cur;
        hash *= prime;
    }

    return hash;
}