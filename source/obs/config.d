module obs.config;

/*
    NOTE: Whenever a new OBS version comes out and the binding is adjusted,
    these version tags need to be updated.
*/
enum LIBOBS_API_MAJOR_VERSION = 30;
enum LIBOBS_API_MINOR_VERSION = 1;
enum LIBOBS_API_PATCH_VERSION = 0;

enum uint MAKE_SEMANTIC_VERSION(uint major, uint minor, uint patch) = ((major << 24) | (minor << 16) | patch);

/**
    The version of the libobs API this library implements.
*/
enum uint LIBOBS_API_VERSION = MAKE_SEMANTIC_VERSION!(LIBOBS_API_MAJOR_VERSION, LIBOBS_API_MINOR_VERSION, LIBOBS_API_PATCH_VERSION);