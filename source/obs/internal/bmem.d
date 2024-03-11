module obs.internal.bmem;
public import core.stdc.string : memset, strlen;
public import core.stdc.wchar_ : wcslen, wchar_t;
extern (C):

struct base_allocator {
    void* function(size_t) malloc;
    void* function(void*, size_t) realloc;
    void function(void*) free;
}

export void* bmalloc(size_t size);
export void* brealloc(void* ptr, size_t size);
export void bfree(void* ptr);

export int base_get_alignment();

export long bnum_allocs();

export void* bmemdup(const void* ptr, size_t size);

pragma(inline, true)
static void* bzalloc(size_t size) {
    void* mem = bmalloc(size);
    if (mem)
        memset(mem, 0, size);
    return mem;
}

pragma(inline, true)
static char* bstrdup_n(const char* str, size_t n) {
    char* dup;
    if (!str)
        return null;

    dup = cast(char*) bmemdup(str, n + 1);
    dup[n] = 0;

    return dup;
}

pragma(inline, true)
static wchar_t* bwstrdup_n(const wchar_t* str, size_t n) {
    wchar_t* dup;
    if (!str)
        return null;

    dup = cast(wchar_t*) bmemdup(str, (n + 1) * wchar_t.sizeof);
    dup[n] = 0;

    return dup;
}

pragma(inline, true)
static char* bstrdup(const char* str) {
    if (!str)
        return null;

    return bstrdup_n(str, strlen(str));
}

pragma(inline, true)
static wchar_t* bwstrdup(const wchar_t* str) {
    if (!str)
        return null;

    return bwstrdup_n(str, wcslen(str));
}
