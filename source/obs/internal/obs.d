/**
 * @file
 * @brief Main libobs header used by applications.
 *
 * @mainpage
 *
 * @section intro_sec Introduction
 *
 * This document describes the api for libobs to be used by applications as well
 * as @ref modules_page implementing some kind of functionality.
 *
 */
module obs.internal.obs;
import obs.internal.mediaio.audio;
import obs.internal.mediaio.video;
import obs.internal.mediaio;
import obs.internal.graphics;
import obs.internal.bmem;
import inmath.linalg;
extern (C):

public import obs.internal.source;
public import obs.internal.properties;
public import obs.internal.data;

// Opqaue types
struct obs_module_t;
struct obs_context_data_t;
struct obs_display_t;
struct obs_view_t;
struct obs_source_t;
struct obs_scene_t;
struct obs_sceneitem_t;
struct obs_output_t;
struct obs_encoder_t;
struct obs_service_t;
struct obs_fader_t;
struct obs_volmeter_t;

// DUMMIES
struct signal_handler_t;
struct lookup_t;
struct proc_handler_t;
struct obs_object_t;
struct gs_effect_t;
struct gs_texture_t;
struct obs_missing_files_t;
struct obs_key_event_t;
struct obs_mouse_event_t;
struct gs_init_data_t;

struct obs_weak_module_t;
struct obs_weak_context_data_t;
struct obs_weak_display_t;
struct obs_weak_view_t;
struct obs_weak_source_t;
struct obs_weak_scene_t;
struct obs_weak_scene_item_t;
struct obs_weak_output_t;
struct obs_weak_encoder_t;
struct obs_weak_service_t;
struct obs_weak_fader_t;
struct obs_weak_volmeter_t;
struct obs_weak_object_t;

/** Used for changing the order of items (for example, filters in a source,
 * or items in a scene) */
enum obs_order_movement_t {
    OBS_ORDER_MOVE_UP,
    OBS_ORDER_MOVE_DOWN,
    OBS_ORDER_MOVE_TOP,
    OBS_ORDER_MOVE_BOTTOM,
}

/**
 * Used with obs_source_process_filter to specify whether the filter should
 * render the source directly with the specified effect, or whether it should
 * render it to a texture
 */
enum obs_allow_direct_render_t {
    OBS_NO_DIRECT_RENDERING,
    OBS_ALLOW_DIRECT_RENDERING,
}

enum obs_scale_type_t {
    OBS_SCALE_DISABLE,
    OBS_SCALE_POINT,
    OBS_SCALE_BICUBIC,
    OBS_SCALE_BILINEAR,
    OBS_SCALE_LANCZOS,
    OBS_SCALE_AREA,
}

enum obs_blending_method_t {
    OBS_BLEND_METHOD_DEFAULT,
    OBS_BLEND_METHOD_SRGB_OFF,
}

enum obs_blending_type_t {
    OBS_BLEND_NORMAL,
    OBS_BLEND_ADDITIVE,
    OBS_BLEND_SUBTRACT,
    OBS_BLEND_SCREEN,
    OBS_BLEND_MULTIPLY,
    OBS_BLEND_LIGHTEN,
    OBS_BLEND_DARKEN,
}

/**
 * Used with scene items to indicate the type of bounds to use for scene items.
 * Mostly determines how the image will be scaled within those bounds, or
 * whether to use bounds at all.
 */
enum obs_bounds_type_t {
    OBS_BOUNDS_NONE, /**< no bounds */
    OBS_BOUNDS_STRETCH, /**< stretch (ignores base scale) */
    OBS_BOUNDS_SCALE_INNER, /**< scales to inner rectangle */
    OBS_BOUNDS_SCALE_OUTER, /**< scales to outer rectangle */
    OBS_BOUNDS_SCALE_TO_WIDTH, /**< scales to the width  */
    OBS_BOUNDS_SCALE_TO_HEIGHT, /**< scales to the height */
    OBS_BOUNDS_MAX_ONLY, /**< no scaling, maximum size only */
}

struct obs_transform_info_t {
    vec2 pos;
    float rot;
    vec2 scale;
    uint alignment;

    obs_bounds_type_t bounds_type;
    uint bounds_alignment;
    vec2 bounds;
    bool crop_to_bounds;
}

/**
 * Video initialization structure
 */
struct obs_video_info_t {
    version (SWIG) {
        /**
        * Graphics module to use (usually "libobs-opengl" or "libobs-d3d11")
        */
        const(char)* graphics_module;
    }

    uint fps_num; /**< Output FPS numerator */
    uint fps_den; /**< Output FPS denominator */

    uint base_width; /**< Base compositing width */
    uint base_height; /**< Base compositing height */

    uint output_width; /**< Output width */
    uint output_height; /**< Output height */
    video_format_t output_format; /**< Output format */

    /** Video adapter index to use (NOTE: avoid for optimus laptops) */
    uint adapter;

    /** Use shaders to convert to different color formats */
    bool gpu_conversion;

    video_colorspace_t colorspace; /**< YUV type (if YUV) */
    video_range_type_t range; /**< YUV range (if YUV) */

    obs_scale_type_t scale_type; /**< How to scale if scaling */
}

/**
 * Audio initialization structure
 */
struct obs_audio_info_t {
    uint samples_per_sec;
    speaker_layout_t speakers;
}

struct obs_audio_info2_t {
    uint samples_per_sec;
    speaker_layout_t speakers;

    uint max_buffering_ms;
    bool fixed_buffering;
}

/**
 * Sent to source filters via the filter_audio callback to allow filtering of
 * audio data
 */
struct obs_audio_data_t {
    ubyte*[MAX_AV_PLANES] data;
    uint frames;
    ulong timestamp;
}

/**
 * Source audio output structure.  Used with obs_source_output_audio to output
 * source audio.  Audio is automatically resampled and remixed as necessary.
 */
struct obs_source_audio_t {
    const(ubyte)*[MAX_AV_PLANES] data;
    uint frames;

    speaker_layout_t speakers;
    audio_format_t format;
    uint samples_per_sec;

    ulong timestamp;
}

struct obs_source_cea_708_t {
    const ubyte* data;
    uint packets;
    ulong timestamp;
}

enum OBS_SOURCE_FRAME_LINEAR_ALPHA = (1 << 0);

/**
 * Source asynchronous video output structure.  Used with
 * obs_source_output_video to output asynchronous video.  Video is buffered as
 * necessary to play according to timestamps.  When used with audio output,
 * audio is synced to video as it is played.
 *
 * If a YUV format is specified, it will be automatically upsampled and
 * converted to RGB via shader on the graphics processor.
 *
 * NOTE: Non-YUV formats will always be treated as full range with this
 * structure!  Use obs_source_frame2 along with obs_source_output_video2
 * instead if partial range support is desired for non-YUV video formats.
 */
struct obs_source_frame_t {
    ubyte*[MAX_AV_PLANES] data;
    uint[MAX_AV_PLANES] linesize;
    uint width;
    uint height;
    ulong timestamp;

    video_format_t format;
    float[16] color_matrix;
    bool full_range;
    ushort max_luminance;
    float[3] color_range_min;
    float[3] color_range_max;
    bool flip;
    ubyte flags;
    ubyte trc; /* enum video_trc */

    /* used internally by libobs */
    long refs;
    bool prev_frame;
}

struct obs_source_frame2_t {
    ubyte*[MAX_AV_PLANES] data;
    uint[MAX_AV_PLANES] linesize;
    uint width;
    uint height;
    ulong timestamp;

    video_format_t format;
    video_range_type_t range;
    float[16] color_matrix;
    float[3] color_range_min;
    float[3] color_range_max;
    bool flip;
    ubyte flags;
    ubyte trc; /* enum video_trc */
}

/** Access to the argc/argv used to start OBS. What you see is what you get. */
struct obs_cmdline_args_t {
    int argc;
    char** argv;
}

/* ------------------------------------------------------------------------- */
/* OBS context */

/**
 * Find a core libobs data file
 * @param path name of the base file
 * @return A string containing the full path to the file.
 *          Use bfree after use.
 */
export char* obs_find_data_file(const(char)* file);

/**
 * Add a path to search libobs data files in.
 * @param path Full path to directory to look in.
 *             The string is copied.
 */
export void obs_add_data_path(const(char)* path);

/**
 * Remove a path from libobs core data paths.
 * @param path The path to compare to currently set paths.
 *             It does not need to be the same pointer, but
 *             the path string must match an entry fully.
 * @return Whether or not the path was successfully removed.
 *         If false, the path could not be found.
 */
export bool obs_remove_data_path(const(char)* path);

/**
 * Initializes OBS
 *
 * @param  locale              The locale to use for modules
 * @param  module_config_path  Path to module config storage directory
 *                             (or NULL if none)
 * @param  store               The profiler name store for OBS to use or NULL
 */
// export bool obs_startup(const(char)* locale, const char* module__config_path,
//     profiler_name_store_t* store);

/** Releases all data associated with OBS and terminates the OBS context */
export void obs_shutdown();

/** @return true if the main OBS context has been initialized */
export bool obs_initialized();

/** @return The current core version */
export uint obs_get_version();

/** @return The current core version string */
export const(char)* obs_get_version_string();

/**
 * Sets things up for calls to obs_get_cmdline_args. Called only once at startup
 * and safely copies argv/argc from main(). Subsequent calls do nothing.
 *
 * @param  argc  The count of command line arguments, from main()
 * @param  argv  An array of command line arguments, copied from main() and ends
 *               with NULL.
 */
export void obs_set_cmdline_args(int argc, const(const(char)*)* argv);

/**
 * Get the argc/argv used to start OBS
 *
 * @return  The command line arguments used for main(). Don't modify this or
 *          you'll mess things up for other callers.
 */
export obs_cmdline_args_t obs_get_cmdline_args();

/**
 * Sets a new locale to use for modules.  This will call obs_module_set_locale
 * for each module with the new locale.
 *
 * @param  locale  The locale to use for modules
 */
export void obs_set_locale(const(char)* locale);

/** @return the current locale */
export const(char)* obs_get_locale();

/** Initialize the Windows-specific crash handler */
version (Windows) export void obs_init_win32_crash_handler();

/**
 * Returns the profiler name store (see util/profiler.h) used by OBS, which is
 * either a name store passed to obs_startup, an internal name store, or NULL
 * in case obs_initialized() returns false.
 */
// export profiler_name_store_t* obs_get_profiler_name_store();

/**
 * Sets base video output base resolution/fps/format.
 *
 * @note This data cannot be changed if an output is currently active.
 * @note The graphics module cannot be changed without fully destroying the
 *       OBS context.
 *
 * @param   ovi  Pointer to an obs_video_info_t structure containing the
 *               specification of the graphics subsystem,
 * @return       OBS_VIDEO_SUCCESS if successful
 *               OBS_VIDEO_NOT_SUPPORTED if the adapter lacks capabilities
 *               OBS_VIDEO_INVALID_PARAM if a parameter is invalid
 *               OBS_VIDEO_CURRENTLY_ACTIVE if video is currently active
 *               OBS_VIDEO_MODULE_NOT_FOUND if the graphics module is not found
 *               OBS_VIDEO_FAIL for generic failure
 */
export int obs_reset_video(obs_video_info_t* ovi);

/**
 * Sets base audio output format/channels/samples/etc
 *
 * @note Cannot reset base audio if an output is currently active.
 */
export bool obs_reset_audio(const obs_audio_info_t* oai);
export bool obs_reset_audio2(const obs_audio_info2_t* oai);

/** Gets the current video settings, returns false if no video */
export bool obs_get_video_info(obs_video_info_t* ovi);

/** Gets the SDR white level, returns 300.f if no video */
export float obs_get_video_sdr_white_level();

/** Gets the HDR nominal peak level, returns 1000.f if no video */
export float obs_get_video_hdr_nominal_peak_level();

/** Sets the video levels */
export void obs_set_video_levels(float sdr_white_level,
    float hdr_nominal_peak_level);

/** Gets the current audio settings, returns false if no audio */
export bool obs_get_audio_info(obs_audio_info_t* oai);

/**
 * Opens a plugin module directly from a specific path.
 *
 * If the module already exists then the function will return successful, and
 * the module parameter will be given the pointer to the existing module.
 *
 * This does not initialize the module, it only loads the module image.  To
 * initialize the module, call obs_init_module.
 *
 * @param  module     The pointer to the created module.
 * @param  path       Specifies the path to the module library file.  If the
 *                    extension is not specified, it will use the extension
 *                    appropriate to the operating system.
 * @param  data_path  Specifies the path to the directory where the module's
 *                    data files are stored.
 * @returns           MODULE_SUCCESS if successful
 *                    MODULE_ERROR if a generic error occurred
 *                    MODULE_FILE_NOT_FOUND if the module was not found
 *                    MODULE_MISSING_exportS if required exports are missing
 *                    MODULE_INCOMPATIBLE_VER if incompatible version
 */
export int obs_open_module(obs_module_t** module_, const(char)* path,
    const(char)* data_path);

/**
 * Initializes the module, which calls its obs_module_load export.  If the
 * module is already loaded, then this function does nothing and returns
 * successful.
 */
export bool obs_init_module(obs_module_t* module_);

/** Returns a module based upon its name, or NULL if not found */
export obs_module_t* obs_get_module(const(char)* name);

/** Gets library of module */
export void* obs_get_module_lib(obs_module_t* module_);

/** Returns locale text from a specific module */
export bool obs_module_get_locale_string(const obs_module_t* mod,
    const(char)* lookup_string,
    const(char)** translated_string);

export const(char)* obs_module_get_locale_text(const obs_module_t* mod,
    const(char)* text);

/** Logs loaded modules */
export void obs_log_loaded_modules();

/** Returns the module file name */
export const(char)* obs_get_module_file_name(obs_module_t* module_);

/** Returns the module full name */
export const(char)* obs_get_module_name(obs_module_t* module_);

/** Returns the module author(s) */
export const(char)* obs_get_module_author(obs_module_t* module_);

/** Returns the module description */
export const(char)* obs_get_module_description(obs_module_t* module_);

/** Returns the module binary path */
export const(char)* obs_get_module_binary_path(obs_module_t* module_);

/** Returns the module data path */
export const(char)* obs_get_module_data_path(obs_module_t* module_);

version (SWIG) {

} else {
    /**
    * Adds a module search path to be used with obs_find_modules.  If the search
    * path strings contain %module%, that text will be replaced with the module
    * name when used.
    *
    * @param  bin   Specifies the module's binary directory search path.
    * @param  data  Specifies the module's data directory search path.
    */
    export void obs_add_module_path(const(char)* bin, const(char)* data);

    /**
    * Adds a module to the list of modules allowed to load in Safe Mode.
    * If the list is empty, all modules are allowed.
    *
    * @param  name  Specifies the module's name (filename sans extension).
    */
    export void obs_add_safe_module(const(char)* name);

    /** Automatically loads all modules from module paths (convenience function) */
    export void obs_load_all_modules();

    struct obs_module_failure_info {
        char** failed_modules;
        size_t count;
    }

    export void obs_module_failure_info_free(obs_module_failure_info* mfi);
    export void obs_load_all_modules2(obs_module_failure_info* mfi);

    /** Notifies modules that all modules have been loaded.  This function should
    * be called after all modules have been loaded. */
    export void obs_post_load_modules();

    struct obs_module_info_t {
        const(char)* bin_path;
        const(char)* data_path;
    }

    alias obs_find_module_callback_t = void function(void* param, const obs_module_info_t* info);

    /** Finds all modules within the search paths added by obs_add_module_path. */
    export void obs_find_modules(obs_find_module_callback_t callback, void* param);

    struct obs_module_info2_t {
        const(char)* bin_path;
        const(char)* data_path;
        const(char)* name;
    }

    alias obs_find_module_callback2_t = void function(
        void* param, const obs_module_info2_t* info);

    /** Finds all modules within the search paths added by obs_add_module_path. */
    export void obs_find_modules2(obs_find_module_callback2_t callback,
        void* param);
}

alias obs_enum_module_callback_t = void function(void* param, obs_module_t* module_);

/** Enumerates all loaded modules */
export void obs_enum_modules(obs_enum_module_callback_t callback, void* param);

/** Helper function for using default module locale */
export lookup_t* obs_module_load_locale(obs_module_t* module_,
    const(char)* default_locale,
    const(char)* locale);

/**
 * Returns the location of a plugin module data file.
 *
 * @note   Modules should use obs_module_file function defined in obs-module.h
 *         as a more elegant means of getting their files without having to
 *         specify the module parameter.
 *
 * @param  module  The module associated with the file to locate
 * @param  file    The file to locate
 * @return         Path string, or NULL if not found.  Use bfree to free string.
 */
export char* obs_find_module_file(obs_module_t* module_, const(char)* file);

/**
 * Returns the path of a plugin module config file (whether it exists or not)
 *
 * @note   Modules should use obs_module_config_path function defined in
 *         obs-module.h as a more elegant means of getting their files without
 *         having to specify the module parameter.
 *
 * @param  module  The module associated with the path
 * @param  file    The file to get a path to
 * @return         Path string, or NULL if not found.  Use bfree to free string.
 */
export char* obs_module_get_config_path(obs_module_t* module_, const(char)* file);

/** Enumerates all source types (inputs, filters, transitions, etc).  */
export bool obs_enum_source_types(size_t idx, const(char)** id);

/**
 * Enumerates all available inputs source types.
 *
 *   Inputs are general source inputs (such as capture sources, device sources,
 * etc).
 */
export bool obs_enum_input_types(size_t idx, const(char)** id);
export bool obs_enum_input_types2(size_t idx, const(char)** id,
    const(char)** unversioned_id);

export const(char)* obs_get_latest_input_type_id(const(char)* unversioned_id);

/**
 * Enumerates all available filter source types.
 *
 *   Filters are sources that are used to modify the video/audio output of
 * other sources.
 */
export bool obs_enum_filter_types(size_t idx, const(char)** id);

/**
 * Enumerates all available transition source types.
 *
 *   Transitions are sources used to transition between two or more other
 * sources.
 */
export bool obs_enum_transition_types(size_t idx, const(char)** id);

/** Enumerates all available output types. */
export bool obs_enum_output_types(size_t idx, const(char)** id);

/** Enumerates all available encoder types. */
export bool obs_enum_encoder_types(size_t idx, const(char)** id);

/** Enumerates all available service types. */
export bool obs_enum_service_types(size_t idx, const(char)** id);

/** Helper function for entering the OBS graphics context */
export void obs_enter_graphics();

/** Helper function for leaving the OBS graphics context */
export void obs_leave_graphics();

/** Gets the main audio output handler for this OBS context */
export audio_t* obs_get_audio();

/** Gets the main video output handler for this OBS context */
export video_t* obs_get_video();

/** Returns true if video is active, false otherwise */
export bool obs_video_active();

/** Sets the primary output source for a channel. */
export void obs_set_output_source(uint channel, obs_source_t* source);

/**
 * Gets the primary output source for a channel and increments the reference
 * counter for that source.  Use obs_source_release to release.
 */
export obs_source_t* obs_get_output_source(uint channel);

/**
 * Enumerates all input sources
 *
 *   Callback function returns true to continue enumeration, or false to end
 * enumeration.
 *
 *   Use obs_source_get_ref or obs_source_get_weak_source if you want to retain
 * a reference after obs_enum_sources finishes
 */
export void obs_enum_sources(bool function(void*, obs_source_t*) enum_proc,
    void* param);

/** Enumerates scenes */
export void obs_enum_scenes(bool function(void*, obs_source_t*) enum_proc,
    void* param);

/** Enumerates all sources (regardless of type) */
export void obs_enum_all_sources(bool function(void*, obs_source_t*) enum_proc,
    void* param);

/** Enumerates outputs */
export void obs_enum_outputs(bool function(void*, obs_output_t*) enum_proc,
    void* param);

/** Enumerates encoders */
export void obs_enum_encoders(bool function(void*, obs_encoder_t*) enum_proc,
    void* param);

/** Enumerates encoders */
export void obs_enum_services(bool function(void*, obs_service_t*) enum_proc,
    void* param);

/**
 * Gets a source by its name.
 *
 *   Increments the source reference counter, use obs_source_release to
 * release it when complete.
 */
export obs_source_t* obs_get_source_by_name(const(char)* name);

/**
 * Gets a source by its UUID.
 *
 *   Increments the source reference counter, use obs_source_release to
 * release it when complete.
 */
export obs_source_t* obs_get_source_by_uuid(const(char)* uuid);

/** Get a transition source by its name. */
export obs_source_t* obs_get_transition_by_name(const(char)* name);

/** Get a transition source by its UUID. */
export obs_source_t* obs_get_transition_by_uuid(const(char)* uuid);

/** Gets an output by its name. */
export obs_output_t* obs_get_output_by_name(const(char)* name);

/** Gets an encoder by its name. */
export obs_encoder_t* obs_get_encoder_by_name(const(char)* name);

/** Gets an service by its name. */
export obs_service_t* obs_get_service_by_name(const(char)* name);

enum obs_base_effect {
    OBS_EFFECT_DEFAULT, /**< RGB/YUV */
    OBS_EFFECT_DEFAULT_RECT, /**< RGB/YUV (using texture_rect) */
    OBS_EFFECT_OPAQUE, /**< RGB/YUV (alpha set to 1.0) */
    OBS_EFFECT_SOLID, /**< RGB/YUV (solid color only) */
    OBS_EFFECT_BICUBIC, /**< Bicubic downscale */
    OBS_EFFECT_LANCZOS, /**< Lanczos downscale */
    OBS_EFFECT_BILINEAR_LOWRES, /**< Bilinear low resolution downscale */
    OBS_EFFECT_PREMULTIPLIED_ALPHA, /**< Premultiplied alpha */
    OBS_EFFECT_REPEAT, /**< RGB/YUV (repeating) */
    OBS_EFFECT_AREA, /**< Area rescale */



}

/** Returns a commonly used base effect */
export gs_effect_t* obs_get_base_effect(obs_base_effect effect);

/** Returns the primary obs signal handler */
export signal_handler_t* obs_get_signal_handler();

/** Returns the primary obs procedure handler */
export proc_handler_t* obs_get_proc_handler();

/** Renders the last main output texture */
export void obs_render_main_texture();

/** Renders the last main output texture ignoring background color */
export void obs_render_main_texture_src_color_only();

/** Returns the last main output texture.  This can return NULL if the texture
 * is unavailable. */
export gs_texture_t* obs_get_main_texture();

/** Saves a source to settings data */
export obs_data_t* obs_save_source(obs_source_t* source);

/** Loads a source from settings data */
export obs_source_t* obs_load_source(obs_data_t* data);

/** Loads a private source from settings data */
export obs_source_t* obs_load_private_source(obs_data_t* data);

/** Send a save signal to sources */
export void obs_source_save(obs_source_t* source);

/** Send a load signal to sources (soft deprecated; does not load filters) */
export void obs_source_load(obs_source_t* source);

/** Send a load signal to sources */
export void obs_source_load2(obs_source_t* source);

alias obs_load_source_cb = void function(void* private_data, obs_source_t* source);

/** Loads sources from a data array */
export void obs_load_sources(obs_data_array_t* array, obs_load_source_cb cb,
    void* private_data);

/** Saves sources to a data array */
export obs_data_array_t* obs_save_sources();

alias obs_save_source_filter_cb = bool function(void* data, obs_source_t* source);
export obs_data_array_t* obs_save_sources_filtered(obs_save_source_filter_cb cb,
    void* data);

/** Reset source UUIDs. NOTE: this function is only to be used by the UI and
 *  will be removed in a future version! */
export void obs_reset_source_uuids();

enum obs_obj_type_t {
    OBS_OBJ_TYPE_INVALID,
    OBS_OBJ_TYPE_SOURCE,
    OBS_OBJ_TYPE_OUTPUT,
    OBS_OBJ_TYPE_ENCODER,
    OBS_OBJ_TYPE_SERVICE,
}

export obs_obj_type_t obs_obj_get_type(void* obj);
export const(char)* obs_obj_get_id(void* obj);
export bool obs_obj_invalid(void* obj);
export void* obs_obj_get_data(void* obj);
export bool obs_obj_is_private(void* obj);

alias obs_enum_audio_device_cb = bool function(void* data, const(char)* name,
    const(char)* id);

export bool obs_audio_monitoring_available();

export void obs_reset_audio_monitoring();

export void obs_enum_audio_monitoring_devices(obs_enum_audio_device_cb cb,
    void* data);

export bool obs_set_audio_monitoring_device(const(char)* name, const(char)* id);
export void obs_get_audio_monitoring_device(const(char)** name, const(char)** id);

export void obs_add_tick_callback(void function(void* param, float seconds) tick,
    void* param);
export void obs_remove_tick_callback(void function(void* param, float seconds) tick,
    void* param);

export void obs_add_main_render_callback(void function(void* param, uint cx, uint cy) draw, void* param);
export void obs_remove_main_render_callback(void function(void* param, uint cx, uint cy) draw, void* param);

export void obs_add_main_rendered_callback(void function(void* param) rendered,
    void* param);
export void obs_remove_main_rendered_callback(void function(void* param) rendered,
    void* param);

export void obs_add_raw_video_callback(
    const video_scale_info_t* conversion,
    void function(void* param, video_data_t* frame) callback, void* param);
export void obs_add_raw_video_callback2(
    const video_scale_info_t* conversion, uint frame_rate_divisor,
    void function(void* param, video_data_t* frame) callback, void* param);
export void obs_remove_raw_video_callback(
    void function(void* param, video_data_t* frame) callback, void* param);

export void obs_add_raw_audio_callback(size_t mix_idx,
    const audio_convert_info_t* conversion,
    audio_output_callback_t callback, void* param);
export void obs_remove_raw_audio_callback(size_t mix_idx,
    audio_output_callback_t callback,
    void* param);

export ulong obs_get_video_frame_time();

export double obs_get_active_fps();
export ulong obs_get_average_frame_time_ns();
export ulong obs_get_frame_interval_ns();

export uint obs_get_total_frames();
export uint obs_get_lagged_frames();

export bool obs_nv12_tex_active();
export bool obs_p010_tex_active();

export void obs_apply_private_data(obs_data_t* settings);
export void obs_set_private_data(obs_data_t* settings);
export obs_data_t* obs_get_private_data();

alias obs_task_t = void function(void* param);

enum obs_task_type_t {
    OBS_TASK_UI,
    OBS_TASK_GRAPHICS,
    OBS_TASK_AUDIO,
    OBS_TASK_DESTROY,
}

export void obs_queue_task(obs_task_type_t type, obs_task_t task,
    void* param, bool wait);
export bool obs_in_task_thread(obs_task_type_t type);

export bool obs_wait_for_destroy_queue();

alias obs_task_handler_t = void function(obs_task_t task, void* param, bool wait);
export void obs_set_ui_task_handler(obs_task_handler_t handler);

export obs_object_t* obs_object_get_ref(obs_object_t* object);
export void obs_object_release(obs_object_t* object);

export void obs_weak_object_addref(obs_weak_object_t* weak);
export void obs_weak_object_release(obs_weak_object_t* weak);
export obs_weak_object_t* obs_object_get_weak_object(obs_object_t* object);
export obs_object_t* obs_weak_object_get_object(obs_weak_object_t* weak);
export bool obs_weak_object_expired(obs_weak_object_t* weak);
export bool obs_weak_object_references_object(obs_weak_object_t* weak,
    obs_object_t* object);

/* ------------------------------------------------------------------------- */
/* View context */

/**
 * Creates a view context.
 *
 *   A view can be used for things like separate previews, or drawing
 * sources separately.
 */
export obs_view_t* obs_view_create();

/** Destroys this view context */
export void obs_view_destroy(obs_view_t* view);

/** Sets the source to be used for this view context. */
export void obs_view_set_source(obs_view_t* view, uint channel,
    obs_source_t* source);

/** Gets the source currently in use for this view context */
export obs_source_t* obs_view_get_source(obs_view_t* view, uint channel);

/** Renders the sources of this view context */
export void obs_view_render(obs_view_t* view);

/** Adds a view to the main render loop, with current obs_get_video_info state */
export video_t* obs_view_add(obs_view_t* view);

/** Adds a view to the main render loop, with custom video settings */
export video_t* obs_view_add2(obs_view_t* view, obs_video_info_t* ovi);

/** Removes a view from the main render loop */
export void obs_view_remove(obs_view_t* view);

/** Enumerate the video info of all mixes using the specified view context */
export void obs_view_enum_video_info(obs_view_t* view,
    bool function(void*,
        obs_video_info_t*) enum_proc,
    void* param);

/* ------------------------------------------------------------------------- */
/* Display context */

/**
 * Adds a new window display linked to the main render pipeline.  This creates
 * a new swap chain which updates every frame.
 *
 * @param  graphics_data  The swap chain initialization data.
 * @return                The new display context, or NULL if failed.
 */
export obs_display_t* obs_display_create(const gs_init_data_t* graphics_data,
    uint backround_color);

/** Destroys a display context */
export void obs_display_destroy(obs_display_t* display);

/** Changes the size of this display */
export void obs_display_resize(obs_display_t* display, uint cx,
    uint cy);

/** Updates the color space of this display */
export void obs_display_update_color_space(obs_display_t* display);

/**
 * Adds a draw callback for this display context
 *
 * @param  display  The display context.
 * @param  draw     The draw callback which is called each time a frame
 *                  updates.
 * @param  param    The user data to be associated with this draw callback.
 */
export void obs_display_add_draw_callback(obs_display_t* display,
    void function(void* param, uint cx, uint cy) draw,
    void* param);

/** Removes a draw callback for this display context */
export void obs_display_remove_draw_callback(obs_display_t* display, void function(
        void* param, uint cx, uint cy) draw, void* param);

export void obs_display_set_enabled(obs_display_t* display, bool enable);
export bool obs_display_enabled(obs_display_t* display);

export void obs_display_set_background_color(obs_display_t* display,
    uint color);

export void obs_display_size(obs_display_t* display, uint* width,
    uint* height);

/* ------------------------------------------------------------------------- */
/* Sources */

/** Returns the translated display name of a source */
export const(char)* obs_source_get_display_name(const(char)* id);

/**
 * Creates a source of the specified type with the specified settings.
 *
 *   The "source" context is used for anything related to presenting
 * or modifying video/audio.  Use obs_source_release to release it.
 */
export obs_source_t* obs_source_create(const(char)* id, const(char)* name,
    obs_data_t* settings,
    obs_data_t* hotkey_data);

export obs_source_t* obs_source_create_private(const(char)* id, const(char)* name,
    obs_data_t* settings);

/* if source has OBS_SOURCE_DO_NOT_DUPLICATE output flag set, only returns a
 * reference */
export obs_source_t* obs_source_duplicate(obs_source_t* source,
    const(char)* desired_name,
    bool create_private);
/**
 * Adds/releases a reference to a source.  When the last reference is
 * released, the source is destroyed.
 */
export void obs_source_release(obs_source_t* source);

export void obs_weak_source_addref(obs_weak_source_t* weak);
export void obs_weak_source_release(obs_weak_source_t* weak);

export obs_source_t* obs_source_get_ref(obs_source_t* source);
export obs_weak_source_t* obs_source_get_weak_source(obs_source_t* source);
export obs_source_t* obs_weak_source_get_source(obs_weak_source_t* weak);
export bool obs_weak_source_expired(obs_weak_source_t* weak);

export bool obs_weak_source_references_source(obs_weak_source_t* weak,
    obs_source_t* source);

/** Notifies all references that the source should be released */
export void obs_source_remove(obs_source_t* source);

/** Returns true if the source should be released */
export bool obs_source_removed(const obs_source_t* source);

/** The 'hidden' flag is not the same as a sceneitem's visibility. It is a
  * property the determines if it can be found through searches. **/
/** Simply sets a 'hidden' flag when the source is still alive but shouldn't be found */
export void obs_source_set_hidden(obs_source_t* source, bool hidden);

/** Returns the current 'hidden' state on the source */
export bool obs_source_is_hidden(obs_source_t* source);

/** Returns capability flags of a source */
export uint obs_source_get_output_flags(const obs_source_t* source);

/** Returns capability flags of a source type */
export uint obs_get_source_output_flags(const(char)* id);

/** Gets the default settings for a source type */
export obs_data_t* obs_get_source_defaults(const(char)* id);

/** Returns the property list, if any.  Free with obs_properties_destroy */
export obs_properties_t* obs_get_source_properties(const(char)* id);

export obs_missing_files_t* obs_source_get_missing_files(const obs_source_t* source);

// export void obs_source_replace_missing_file(obs_missing_file_cb_t cb,
//     obs_source_t* source,
//     const(char)* new_path, void* data);

/** Returns whether the source has custom properties or not */
export bool obs_is_source_configurable(const(char)* id);

export bool obs_source_configurable(const obs_source_t* source);

/**
 * Returns the properties list for a specific existing source.  Free with
 * obs_properties_destroy
 */
export obs_properties_t* obs_source_properties(const obs_source_t* source);

/** Updates settings for this source */
export void obs_source_update(obs_source_t* source, obs_data_t* settings);
export void obs_source_reset_settings(obs_source_t* source,
    obs_data_t* settings);

/** Renders a video source. */
export void obs_source_video_render(obs_source_t* source);

/** Gets the width of a source (if it has video) */
export uint obs_source_get_width(obs_source_t* source);

/** Gets the height of a source (if it has video) */
export uint obs_source_get_height(obs_source_t* source);

/** Gets the color space of a source (if it has video) */
export gs_color_space_t obs_source_get_color_space(obs_source_t* source, size_t count,
    const(gs_color_space_t)* preferred_spaces);

/** Hints whether or not the source will blend texels */
export bool obs_source_get_texcoords_centered(obs_source_t* source);

/**
 * If the source is a filter, returns the parent source of the filter.  Only
 * guaranteed to be valid inside of the video_render, filter_audio,
 * filter_video, and filter_remove callbacks.
 */
export obs_source_t* obs_filter_get_parent(const obs_source_t* filter);

/**
 * If the source is a filter, returns the target source of the filter.  Only
 * guaranteed to be valid inside of the video_render, filter_audio,
 * filter_video, and filter_remove callbacks.
 */
export obs_source_t* obs_filter_get_target(const obs_source_t* filter);

/** Used to directly render a non-async source without any filter processing */
export void obs_source_default_render(obs_source_t* source);

/** Adds a filter to the source (which is used whenever the source is used) */
export void obs_source_filter_add(obs_source_t* source, obs_source_t* filter);

/** Removes a filter from the source */
export void obs_source_filter_remove(obs_source_t* source,
    obs_source_t* filter);

/** Modifies the order of a specific filter */
export void obs_source_filter_set_order(obs_source_t* source,
    obs_source_t* filter,
    obs_order_movement_t movement);

/** Gets filter index */
export int obs_source_filter_get_index(obs_source_t* source,
    obs_source_t* filter);

/** Sets filter index */
export void obs_source_filter_set_index(obs_source_t* source,
    obs_source_t* filter, size_t index);

/** Gets the settings string for a source */
export obs_data_t* obs_source_get_settings(const obs_source_t* source);

/** Gets the name of a source */
export const(char)* obs_source_get_name(const obs_source_t* source);

/** Sets the name of a source */
export void obs_source_set_name(obs_source_t* source, const(char)* name);

/** Gets the UUID of a source */
export const(char)* obs_source_get_uuid(const obs_source_t* source);

/** Gets the source type */
export obs_source_type_t obs_source_get_type(const obs_source_t* source);

/** Gets the source identifier */
export const(char)* obs_source_get_id(const obs_source_t* source);
export const(char)* obs_source_get_unversioned_id(const obs_source_t* source);

/** Returns the signal handler for a source */
export signal_handler_t* obs_source_get_signal_handler(const obs_source_t* source);

/** Returns the procedure handler for a source */
export proc_handler_t* obs_source_get_proc_handler(const obs_source_t* source);

/** Sets the user volume for a source that has audio output */
export void obs_source_set_volume(obs_source_t* source, float volume);

/** Gets the user volume for a source that has audio output */
export float obs_source_get_volume(const obs_source_t* source);

/* Gets speaker layout of a source */
export speaker_layout_t obs_source_get_speaker_layout(obs_source_t* source);

/** Sets the balance value for a stereo audio source */
export void obs_source_set_balance_value(obs_source_t* source, float balance);

/** Gets the balance value for a stereo audio source */
export float obs_source_get_balance_value(const obs_source_t* source);

/** Sets the audio sync offset (in nanoseconds) for a source */
export void obs_source_set_sync_offset(obs_source_t* source, long offset);

/** Gets the audio sync offset (in nanoseconds) for a source */
export long obs_source_get_sync_offset(const obs_source_t* source);

/** Enumerates active child sources used by this source */
export void obs_source_enum_active_sources(obs_source_t* source,
    obs_source_enum_proc_t enum_callback,
    void* param);

/** Enumerates the entire active child source tree used by this source */
export void obs_source_enum_active_tree(obs_source_t* source,
    obs_source_enum_proc_t enum_callback,
    void* param);

export void obs_source_enum_full_tree(obs_source_t* source,
    obs_source_enum_proc_t enum_callback,
    void* param);

/** Returns true if active, false if not */
export bool obs_source_active(const obs_source_t* source);

/**
 * Returns true if currently displayed somewhere (active or not), false if not
 */
export bool obs_source_showing(const obs_source_t* source);

/** Unused flag */
enum OBS_SOURCE_FLAG_UNUSED_1 = (1 << 0);
/** Specifies to force audio to mono */
enum OBS_SOURCE_FLAG_FORCE_MONO = (1 << 1);

/**
 * Sets source flags.  Note that these are different from the main output
 * flags.  These are generally things that can be set by the source or user,
 * while the output flags are more used to determine capabilities of a source.
 */
export void obs_source_set_flags(obs_source_t* source, uint flags);

/** Gets source flags. */
export uint obs_source_get_flags(const obs_source_t* source);

/**
 * Sets audio mixer flags.  These flags are used to specify which mixers
 * the source's audio should be applied to.
 */
export void obs_source_set_audio_mixers(obs_source_t* source, uint mixers);

/** Gets audio mixer flags */
export uint obs_source_get_audio_mixers(const obs_source_t* source);

/**
 * Increments the 'showing' reference counter to indicate that the source is
 * being shown somewhere.  If the reference counter was 0, will call the 'show'
 * callback.
 */
export void obs_source_inc_showing(obs_source_t* source);

/**
 * Increments the 'active' reference counter to indicate that the source is
 * fully active.  If the reference counter was 0, will call the 'activate'
 * callback.
 *
 * Unlike obs_source_inc_showing, this will cause children of this source to be
 * considered showing as well (currently used by transition previews to make
 * the stinger transition show correctly).  obs_source_inc_showing should
 * generally be used instead.
 */
export void obs_source_inc_active(obs_source_t* source);

/**
 * Decrements the 'showing' reference counter to indicate that the source is
 * no longer being shown somewhere.  If the reference counter is set to 0,
 * will call the 'hide' callback
 */
export void obs_source_dec_showing(obs_source_t* source);

/**
 * Decrements the 'active' reference counter to indicate that the source is no
 * longer fully active.  If the reference counter is set to 0, will call the
 * 'deactivate' callback
 *
 * Unlike obs_source_dec_showing, this will cause children of this source to be
 * considered not showing as well.  obs_source_dec_showing should generally be
 * used instead.
 */
export void obs_source_dec_active(obs_source_t* source);

/** Enumerates filters assigned to the source */
export void obs_source_enum_filters(obs_source_t* source,
    obs_source_enum_proc_t callback,
    void* param);

/** Gets a filter of a source by its display name. */
export obs_source_t* obs_source_get_filter_by_name(obs_source_t* source,
    const(char)* name);

/** Gets the number of filters the source has. */
export size_t obs_source_filter_count(const obs_source_t* source);

export void obs_source_copy_filters(obs_source_t* dst, obs_source_t* src);
export void obs_source_copy_single_filter(obs_source_t* dst,
    obs_source_t* filter);

export bool obs_source_enabled(const obs_source_t* source);
export void obs_source_set_enabled(obs_source_t* source, bool enabled);

export bool obs_source_muted(const obs_source_t* source);
export void obs_source_set_muted(obs_source_t* source, bool muted);

export bool obs_source_push_to_mute_enabled(obs_source_t* source);
export void obs_source_enable_push_to_mute(obs_source_t* source, bool enabled);

export ulong obs_source_get_push_to_mute_delay(obs_source_t* source);
export void obs_source_set_push_to_mute_delay(obs_source_t* source,
    ulong delay);

export bool obs_source_push_to_talk_enabled(obs_source_t* source);
export void obs_source_enable_push_to_talk(obs_source_t* source, bool enabled);

export ulong obs_source_get_push_to_talk_delay(obs_source_t* source);
export void obs_source_set_push_to_talk_delay(obs_source_t* source,
    ulong delay);

alias obs_source_audio_capture_t = void function(void* param, obs_source_t* source,
    const audio_data_t* audio_data,
    bool muted);

alias signal_callback_t = void*;

export void obs_source_add_audio_pause_callback(obs_source_t* source,
    signal_callback_t callback,
    void* param);
export void obs_source_remove_audio_pause_callback(obs_source_t* source,
    signal_callback_t callback,
    void* param);
export void obs_source_add_audio_capture_callback(
    obs_source_t* source, obs_source_audio_capture_t callback, void* param);
export void obs_source_remove_audio_capture_callback(
    obs_source_t* source, obs_source_audio_capture_t callback, void* param);

alias obs_source_caption_t = void function(void* param, obs_source_t* source,
    const obs_source_cea_708_t* captions);

export void obs_source_add_caption_callback(obs_source_t* source,
    obs_source_caption_t callback,
    void* param);
export void obs_source_remove_caption_callback(obs_source_t* source,
    obs_source_caption_t callback,
    void* param);

enum obs_deinterlace_mode_t {
    OBS_DEINTERLACE_MODE_DISABLE,
    OBS_DEINTERLACE_MODE_DISCARD,
    OBS_DEINTERLACE_MODE_RETRO,
    OBS_DEINTERLACE_MODE_BLEND,
    OBS_DEINTERLACE_MODE_BLEND_2X,
    OBS_DEINTERLACE_MODE_LINEAR,
    OBS_DEINTERLACE_MODE_LINEAR_2X,
    OBS_DEINTERLACE_MODE_YADIF,
    OBS_DEINTERLACE_MODE_YADIF_2X,
}

enum obs_deinterlace_field_order_t {
    OBS_DEINTERLACE_FIELD_ORDER_TOP,
    OBS_DEINTERLACE_FIELD_ORDER_BOTTOM,
}

export void obs_source_set_deinterlace_mode(obs_source_t* source,
    obs_deinterlace_mode_t mode);
export obs_deinterlace_mode_t obs_source_get_deinterlace_mode(const obs_source_t* source);
export void obs_source_set_deinterlace_field_order(
    obs_source_t* source, obs_deinterlace_field_order_t field_order);
export obs_deinterlace_field_order_t obs_source_get_deinterlace_field_order(const obs_source_t* source);

enum obs_monitoring_type_t {
    OBS_MONITORING_TYPE_NONE,
    OBS_MONITORING_TYPE_MONITOR_ONLY,
    OBS_MONITORING_TYPE_MONITOR_AND_OUTPUT,
}

export void obs_source_set_monitoring_type(obs_source_t* source,
    obs_monitoring_type_t type);
export obs_monitoring_type_t obs_source_get_monitoring_type(const obs_source_t* source);

/** Gets private front-end settings data.  This data is saved/loaded
 * automatically.  Returns an incremented reference. */
export obs_data_t* obs_source_get_private_settings(obs_source_t* item);

export obs_data_array_t* obs_source_backup_filters(obs_source_t* source);
export void obs_source_restore_filters(obs_source_t* source,
    obs_data_array_t* array);

/* ------------------------------------------------------------------------- */
/* Functions used by sources */

export void* obs_source_get_type_data(obs_source_t* source);

/**
 * Helper function to set the color matrix information when drawing the source.
 *
 * @param  color_matrix     The color matrix.  Assigns to the 'color_matrix'
 *                          effect variable.
 * @param  color_range_min  The minimum color range.  Assigns to the
 *                          'color_range_min' effect variable.  If NULL,
 *                          {0.0f, 0.0f, 0.0f} is used.
 * @param  color_range_max  The maximum color range.  Assigns to the
 *                          'color_range_max' effect variable.  If NULL,
 *                          {1.0f, 1.0f, 1.0f} is used.
 */
export void obs_source_draw_set_color_matrix(const mat4* color_matrix,
    const(vec3)* color_range_min,
    const(vec3)* color_range_max);

/**
 * Helper function to draw sprites for a source (synchronous video).
 *
 * @param  image   The sprite texture to draw.  Assigns to the 'image' variable
 *                 of the current effect.
 * @param  x       X position of the sprite.
 * @param  y       Y position of the sprite.
 * @param  cx      Width of the sprite.  If 0, uses the texture width.
 * @param  cy      Height of the sprite.  If 0, uses the texture height.
 * @param  flip    Specifies whether to flip the image vertically.
 */
export void obs_source_draw(gs_texture_t* image, int x, int y, uint cx,
    uint cy, bool flip);

/**
 * Outputs asynchronous video data.  Set to NULL to deactivate the texture
 *
 * NOTE: Non-YUV formats will always be treated as full range with this
 * function!  Use obs_source_output_video2 instead if partial range support is
 * desired for non-YUV video formats.
 */
export void obs_source_output_video(obs_source_t* source,
    const obs_source_frame_t* frame);
export void obs_source_output_video2(obs_source_t* source,
    const obs_source_frame2_t* frame);

export void obs_source_set_async_rotation(obs_source_t* source, long rotation);

export void obs_source_output_cea708(obs_source_t* source,
    const obs_source_cea_708_t* captions);

/**
 * Preloads asynchronous video data to allow instantaneous playback
 *
 * NOTE: Non-YUV formats will always be treated as full range with this
 * function!  Use obs_source_preload_video2 instead if partial range support is
 * desired for non-YUV video formats.
 */
export void obs_source_preload_video(obs_source_t* source,
    const obs_source_frame_t* frame);
export void obs_source_preload_video2(obs_source_t* source,
    const obs_source_frame2_t* frame);

/** Shows any preloaded video data */
export void obs_source_show_preloaded_video(obs_source_t* source);

/**
 * Sets current async video frame immediately
 *
 * NOTE: Non-YUV formats will always be treated as full range with this
 * function!  Use obs_source_preload_video2 instead if partial range support is
 * desired for non-YUV video formats.
 */
export void obs_source_set_video_frame(obs_source_t* source,
    const obs_source_frame_t* frame);
export void obs_source_set_video_frame2(obs_source_t* source,
    const obs_source_frame2_t* frame);

/** Outputs audio data (always asynchronous) */
export void obs_source_output_audio(obs_source_t* source,
    const obs_source_audio_t* audio);

/** Signal an update to any currently used properties via 'update_properties' */
export void obs_source_update_properties(obs_source_t* source);

/** Gets the current async video frame */
export obs_source_frame_t* obs_source_get_frame(obs_source_t* source);

/** Releases the current async video frame */
export void obs_source_release_frame(obs_source_t* source,
    obs_source_frame_t* frame);

/**
 * Default RGB filter handler for generic effect filters.  Processes the
 * filter chain and renders them to texture if needed, then the filter is
 * drawn with
 *
 * After calling this, set your parameters for the effect, then call
 * obs_source_process_filter_end to draw the filter.
 *
 * Returns true if filtering should continue, false if the filter is bypassed
 * for whatever reason.
 */
export bool obs_source_process_filter_begin(obs_source_t* filter,
    gs_color_format_t format,
    obs_allow_direct_render_t allow_direct);

export bool obs_source_process_filter_begin_with_color_space(
    obs_source_t* filter, gs_color_format_t format,
    gs_color_space_t space, obs_allow_direct_render_t allow_direct);

/**
 * Draws the filter.
 *
 * Before calling this function, first call obs_source_process_filter_begin and
 * then set the effect parameters, and then call this function to finalize the
 * filter.
 */
export void obs_source_process_filter_end(obs_source_t* filter,
    gs_effect_t* effect, uint width,
    uint height);

/**
 * Draws the filter with a specific technique.
 *
 * Before calling this function, first call obs_source_process_filter_begin and
 * then set the effect parameters, and then call this function to finalize the
 * filter.
 */
export void obs_source_process_filter_tech_end(obs_source_t* filter,
    gs_effect_t* effect,
    uint width, uint height,
    const(char)* tech_name);

/** Skips the filter if the filter is invalid and cannot be rendered */
export void obs_source_skip_video_filter(obs_source_t* filter);

/**
 * Adds an active child source.  Must be called by parent sources on child
 * sources when the child is added and active.  This ensures that the source is
 * properly activated if the parent is active.
 *
 * @returns true if source can be added, false if it causes recursion
 */
export bool obs_source_add_active_child(obs_source_t* parent,
    obs_source_t* child);

/**
 * Removes an active child source.  Must be called by parent sources on child
 * sources when the child is removed or inactive.  This ensures that the source
 * is properly deactivated if the parent is no longer active.
 */
export void obs_source_remove_active_child(obs_source_t* parent,
    obs_source_t* child);

/** Sends a mouse down/up event to a source */
export void obs_source_send_mouse_click(obs_source_t* source,
    const obs_mouse_event_t* event,
    int type, bool mouse_up,
    uint click_count);

/** Sends a mouse move event to a source. */
export void obs_source_send_mouse_move(obs_source_t* source,
    const obs_mouse_event_t* event,
    bool mouse_leave);

/** Sends a mouse wheel event to a source */
export void obs_source_send_mouse_wheel(obs_source_t* source,
    const obs_mouse_event_t* event,
    int x_delta, int y_delta);

/** Sends a got-focus or lost-focus event to a source */
export void obs_source_send_focus(obs_source_t* source, bool focus);

/** Sends a key up/down event to a source */
export void obs_source_send_key_click(obs_source_t* source,
    const obs_key_event_t* event,
    bool key_up);

/** Sets the default source flags. */
export void obs_source_set_default_flags(obs_source_t* source, uint flags);

/** Gets the base width for a source (not taking in to account filtering) */
export uint obs_source_get_base_width(obs_source_t* source);

/** Gets the base height for a source (not taking in to account filtering) */
export uint obs_source_get_base_height(obs_source_t* source);

export bool obs_source_audio_pending(const obs_source_t* source);
export ulong obs_source_get_audio_timestamp(const obs_source_t* source);
export void obs_source_get_audio_mix(const obs_source_t* source,
    obs_source_audio_mix_t* audio);

export void obs_source_set_async_unbuffered(obs_source_t* source,
    bool unbuffered);
export bool obs_source_async_unbuffered(const obs_source_t* source);

/** Used to decouple audio from video so that audio doesn't attempt to sync up
 * with video.  I.E. Audio acts independently.  Only works when in unbuffered
 * mode. */
export void obs_source_set_async_decoupled(obs_source_t* source, bool decouple);
export bool obs_source_async_decoupled(const obs_source_t* source);

export void obs_source_set_audio_active(obs_source_t* source, bool show);
export bool obs_source_audio_active(const obs_source_t* source);

export uint obs_source_get_last_obs_version(const obs_source_t* source);

/** Media controls */
export void obs_source_media_play_pause(obs_source_t* source, bool pause);
export void obs_source_media_restart(obs_source_t* source);
export void obs_source_media_stop(obs_source_t* source);
export void obs_source_media_next(obs_source_t* source);
export void obs_source_media_previous(obs_source_t* source);
export long obs_source_media_get_duration(obs_source_t* source);
export long obs_source_media_get_time(obs_source_t* source);
export void obs_source_media_set_time(obs_source_t* source, long ms);
export obs_media_state_t obs_source_media_get_state(obs_source_t* source);
export void obs_source_media_started(obs_source_t* source);
export void obs_source_media_ended(obs_source_t* source);

/* ------------------------------------------------------------------------- */
/* Transition-specific functions */
enum obs_transition_target_t {
    OBS_TRANSITION_SOURCE_A,
    OBS_TRANSITION_SOURCE_B,
}

export obs_source_t* obs_transition_get_source(obs_source_t* transition,
    obs_transition_target_t target);
export void obs_transition_clear(obs_source_t* transition);

export obs_source_t* obs_transition_get_active_source(obs_source_t* transition);

enum obs_transition_mode_t {
    OBS_TRANSITION_MODE_AUTO,
    OBS_TRANSITION_MODE_MANUAL,
}

export bool obs_transition_start(obs_source_t* transition,
    obs_transition_mode_t mode,
    uint duration_ms, obs_source_t* dest);

export void obs_transition_set(obs_source_t* transition, obs_source_t* source);

export void obs_transition_set_manual_time(obs_source_t* transition, float t);
export void obs_transition_set_manual_torque(obs_source_t* transition,
    float torque, float clamp);

enum obs_transition_scale_type_t {
    OBS_TRANSITION_SCALE_MAX_ONLY,
    OBS_TRANSITION_SCALE_ASPECT,
    OBS_TRANSITION_SCALE_STRETCH,
}

export void obs_transition_set_scale_type(obs_source_t* transition,
    obs_transition_scale_type_t type);
export obs_transition_scale_type_t obs_transition_get_scale_type(const obs_source_t* transition);

export void obs_transition_set_alignment(obs_source_t* transition,
    uint alignment);
export uint obs_transition_get_alignment(const obs_source_t* transition);

export void obs_transition_set_size(obs_source_t* transition, uint cx,
    uint cy);
export void obs_transition_get_size(const obs_source_t* transition,
    uint* cx, uint* cy);

/* function used by transitions */

/**
 * Enables fixed transitions (videos or specific types of transitions that
 * are of fixed duration and linearly interpolated
 */
export void obs_transition_enable_fixed(obs_source_t* transition, bool enable,
    uint duration_ms);
export bool obs_transition_fixed(obs_source_t* transition);

alias obs_transition_video_render_callback_t = void function(void* data,
    gs_texture_t* a,
    gs_texture_t* b, float t,
    uint cx,
    uint cy);
alias obs_transition_audio_mix_callback_t = float function(void* data, float t);

export float obs_transition_get_time(obs_source_t* transition);

export void obs_transition_force_stop(obs_source_t* transition);

export void obs_transition_video_render(obs_source_t* transition,
    obs_transition_video_render_callback_t callback);

export void obs_transition_video_render2(obs_source_t* transition,
    obs_transition_video_render_callback_t callback,
    gs_texture_t* placeholder_texture);

export gs_color_space_t obs_transition_video_get_color_space(obs_source_t* transition);

/** Directly renders its sub-source instead of to texture.  Returns false if no
 * longer transitioning */
export bool obs_transition_video_render_direct(obs_source_t* transition,
    obs_transition_target_t target);

export bool obs_transition_audio_render(obs_source_t* transition, ulong* ts_out,
    obs_source_audio_mix_t* audio, uint mixers,
    size_t channels, size_t sample_rate,
    obs_transition_audio_mix_callback_t mix_a_callback,
    obs_transition_audio_mix_callback_t mix_b_callback);

/* swaps transition sources and textures as an optimization and to reduce
 * memory usage when switching between transitions */
export void obs_transition_swap_begin(obs_source_t* tr_dest,
    obs_source_t* tr_source);
export void obs_transition_swap_end(obs_source_t* tr_dest,
    obs_source_t* tr_source);

/* ------------------------------------------------------------------------- */
/* Scenes */

/**
 * Creates a scene.
 *
 *   A scene is a source which is a container of other sources with specific
 * display orientations.  Scenes can also be used like any other source.
 */
export obs_scene_t* obs_scene_create(const(char)* name);

export obs_scene_t* obs_scene_create_private(const(char)* name);

enum obs_scene_duplicate_type_t {
    OBS_SCENE_DUP_REFS, /**< Source refs only */
    OBS_SCENE_DUP_COPY, /**< Fully duplicate */
    OBS_SCENE_DUP_PRIVATE_REFS, /**< Source refs only (as private) */
    OBS_SCENE_DUP_PRIVATE_COPY, /**< Fully duplicate (as private) */



}

/**
 * Duplicates a scene.
 */
export obs_scene_t* obs_scene_duplicate(obs_scene_t* scene, const(char)* name,
    obs_scene_duplicate_type_t type);

export void obs_scene_release(obs_scene_t* scene);

export obs_scene_t* obs_scene_get_ref(obs_scene_t* scene);

/** Gets the scene's source context */
export obs_source_t* obs_scene_get_source(const obs_scene_t* scene);

/** Gets the scene from its source, or NULL if not a scene */
export obs_scene_t* obs_scene_from_source(const obs_source_t* source);

/** Determines whether a source is within a scene */
export obs_sceneitem_t* obs_scene_find_source(obs_scene_t* scene,
    const(char)* name);

export obs_sceneitem_t* obs_scene_find_source_recursive(obs_scene_t* scene,
    const(char)* name);

export obs_sceneitem_t* obs_scene_find_sceneitem_by_id(obs_scene_t* scene,
    long id);

/** Gets scene by name, increments the reference */
pragma(inline)
static obs_scene_t* obs_get_scene_by_name(const(char)* name) {
    obs_source_t* source = obs_get_source_by_name(name);
    obs_scene_t* scene = obs_scene_from_source(source);
    if (!scene) {
        obs_source_release(source);
        return null;
    }
    return scene;
}

/** Enumerates sources within a scene */
export void obs_scene_enum_items(obs_scene_t* scene,
    bool function(obs_scene_t*,
        obs_sceneitem_t*, void*) callback,
    void* param);

export bool obs_scene_reorder_items(obs_scene_t* scene,
    const(obs_sceneitem_t*)* item_order,
    size_t item_order_size);

struct obs_sceneitem_order_info {
    obs_sceneitem_t* group;
    obs_sceneitem_t* item;
}

export bool obs_scene_reorder_items2(obs_scene_t* scene,
    obs_sceneitem_order_info* item_order,
    size_t item_order_size);

export bool obs_source_is_scene(const obs_source_t* source);

/** Adds/creates a new scene item for a source */
export obs_sceneitem_t* obs_scene_add(obs_scene_t* scene, obs_source_t* source);

alias obs_scene_atomic_update_func = void function(void*, obs_scene_t* scene);
export void obs_scene_atomic_update(obs_scene_t* scene,
    obs_scene_atomic_update_func func,
    void* data);

export void obs_sceneitem_addref(obs_sceneitem_t* item);
export void obs_sceneitem_release(obs_sceneitem_t* item);

/** Removes a scene item. */
export void obs_sceneitem_remove(obs_sceneitem_t* item);

/** Adds a scene item. */
export void obs_sceneitems_add(obs_scene_t* scene, obs_data_array_t* data);

/** Saves Sceneitem into an array, arr **/
export void obs_sceneitem_save(obs_sceneitem_t* item, obs_data_array_t* arr);

/** Set the ID of a sceneitem */
export void obs_sceneitem_set_id(obs_sceneitem_t* sceneitem, long id);

/** Tries to find the sceneitem of the source in a given scene. Returns NULL if not found */
export obs_sceneitem_t* obs_scene_sceneitem_from_source(obs_scene_t* scene,
    obs_source_t* source);

/** Save all the transform states for a current scene's sceneitems */
export obs_data_t* obs_scene_save_transform_states(obs_scene_t* scene,
    bool all_items);

/** Load all the transform states of sceneitems in that scene */
export void obs_scene_load_transform_states(const(char)* state);

/**  Gets a sceneitem's order in its scene */
export int obs_sceneitem_get_order_position(obs_sceneitem_t* item);

/** Gets the scene parent associated with the scene item. */
export obs_scene_t* obs_sceneitem_get_scene(const obs_sceneitem_t* item);

/** Gets the source of a scene item. */
export obs_source_t* obs_sceneitem_get_source(const obs_sceneitem_t* item);

/* FIXME: The following functions should be deprecated and replaced with a way
 * to specify saveable private user data. -Lain */
export void obs_sceneitem_select(obs_sceneitem_t* item, bool select);
export bool obs_sceneitem_selected(const obs_sceneitem_t* item);
export bool obs_sceneitem_locked(const obs_sceneitem_t* item);
export bool obs_sceneitem_set_locked(obs_sceneitem_t* item, bool lock);

/* Functions for getting/setting specific orientation of a scene item */
export void obs_sceneitem_set_pos(obs_sceneitem_t* item,
    const vec2* pos);
export void obs_sceneitem_set_rot(obs_sceneitem_t* item, float rot_deg);
export void obs_sceneitem_set_scale(obs_sceneitem_t* item,
    const vec2* scale);
export void obs_sceneitem_set_alignment(obs_sceneitem_t* item,
    uint alignment);
export void obs_sceneitem_set_order(obs_sceneitem_t* item,
    obs_order_movement_t movement);
export void obs_sceneitem_set_order_position(obs_sceneitem_t* item,
    int position);
export void obs_sceneitem_set_bounds_type(obs_sceneitem_t* item,
    obs_bounds_type_t type);
export void obs_sceneitem_set_bounds_alignment(obs_sceneitem_t* item,
    uint alignment);
export void obs_sceneitem_set_bounds_crop(obs_sceneitem_t* item, bool crop);
export void obs_sceneitem_set_bounds(obs_sceneitem_t* item,
    const vec2* bounds);

export long obs_sceneitem_get_id(const obs_sceneitem_t* item);

export void obs_sceneitem_get_pos(const obs_sceneitem_t* item,
    vec2* pos);
export float obs_sceneitem_get_rot(const obs_sceneitem_t* item);
export void obs_sceneitem_get_scale(const obs_sceneitem_t* item,
    vec2* scale);
export uint obs_sceneitem_get_alignment(const obs_sceneitem_t* item);

export obs_bounds_type_t obs_sceneitem_get_bounds_type(const obs_sceneitem_t* item);
export uint obs_sceneitem_get_bounds_alignment(const obs_sceneitem_t* item);
export bool obs_sceneitem_get_bounds_crop(const obs_sceneitem_t* item);
export void obs_sceneitem_get_bounds(const obs_sceneitem_t* item,
    vec2* bounds);
export void obs_sceneitem_get_info2(const obs_sceneitem_t* item,
    obs_transform_info_t* info);
export void obs_sceneitem_set_info2(obs_sceneitem_t* item,
    const obs_transform_info_t* info);

export void obs_sceneitem_get_draw_transform(const obs_sceneitem_t* item,
    mat4* transform);
export void obs_sceneitem_get_box_transform(const obs_sceneitem_t* item,
    mat4* transform);
export void obs_sceneitem_get_box_scale(const obs_sceneitem_t* item,
    vec2* scale);

export bool obs_sceneitem_visible(const obs_sceneitem_t* item);
export bool obs_sceneitem_set_visible(obs_sceneitem_t* item, bool visible);

struct obs_sceneitem_crop_t {
    int left;
    int top;
    int right;
    int bottom;
}

export void obs_sceneitem_set_crop(obs_sceneitem_t* item,
    const obs_sceneitem_crop_t* crop);
export void obs_sceneitem_get_crop(const obs_sceneitem_t* item,
    obs_sceneitem_crop_t* crop);

export void obs_sceneitem_set_scale_filter(obs_sceneitem_t* item,
    obs_scale_type_t filter);
export obs_scale_type_t obs_sceneitem_get_scale_filter(obs_sceneitem_t* item);

export void obs_sceneitem_set_blending_method(obs_sceneitem_t* item,
    obs_blending_method_t method);
export obs_blending_method_t obs_sceneitem_get_blending_method(obs_sceneitem_t* item);

export void obs_sceneitem_set_blending_mode(obs_sceneitem_t* item,
    obs_blending_type_t type);
export obs_blending_type_t obs_sceneitem_get_blending_mode(obs_sceneitem_t* item);

export void obs_sceneitem_force_update_transform(obs_sceneitem_t* item);

export void obs_sceneitem_defer_update_begin(obs_sceneitem_t* item);
export void obs_sceneitem_defer_update_end(obs_sceneitem_t* item);

/** Gets private front-end settings data.  This data is saved/loaded
 * automatically.  Returns an incremented reference. */
export obs_data_t* obs_sceneitem_get_private_settings(obs_sceneitem_t* item);

export obs_sceneitem_t* obs_scene_add_group(obs_scene_t* scene,
    const(char)* name);
export obs_sceneitem_t* obs_scene_insert_group(obs_scene_t* scene,
    const(char)* name,
    obs_sceneitem_t** items,
    size_t count);

export obs_sceneitem_t* obs_scene_add_group2(obs_scene_t* scene,
    const(char)* name, bool signal);
export obs_sceneitem_t* obs_scene_insert_group2(obs_scene_t* scene,
    const(char)* name,
    obs_sceneitem_t** items,
    size_t count, bool signal);

export obs_sceneitem_t* obs_scene_get_group(obs_scene_t* scene,
    const(char)* name);

export bool obs_sceneitem_is_group(obs_sceneitem_t* item);

export obs_scene_t* obs_sceneitem_group_get_scene(const obs_sceneitem_t* group);

export void obs_sceneitem_group_ungroup(obs_sceneitem_t* group);
export void obs_sceneitem_group_ungroup2(obs_sceneitem_t* group, bool signal);

export void obs_sceneitem_group_add_item(obs_sceneitem_t* group,
    obs_sceneitem_t* item);
export void obs_sceneitem_group_remove_item(obs_sceneitem_t* group,
    obs_sceneitem_t* item);

export obs_sceneitem_t* obs_sceneitem_get_group(obs_scene_t* scene,
    obs_sceneitem_t* item);

export bool obs_source_is_group(const obs_source_t* source);
export bool obs_scene_is_group(const obs_scene_t* scene);

export void obs_sceneitem_group_enum_items(obs_sceneitem_t* group,
    bool function(obs_scene_t*,
        obs_sceneitem_t*,
        void*) callback,
    void* param);

/** Gets the group from its source, or NULL if not a group */
export obs_scene_t* obs_group_from_source(const obs_source_t* source);

pragma(inline)
static obs_scene_t* obs_group_or_scene_from_source(const obs_source_t* source) {
    obs_scene_t* s = obs_scene_from_source(source);
    return s ? s : obs_group_from_source(source);
}

export void obs_sceneitem_defer_group_resize_begin(obs_sceneitem_t* item);
export void obs_sceneitem_defer_group_resize_end(obs_sceneitem_t* item);

export void obs_sceneitem_set_show_transition(obs_sceneitem_t* item,
    obs_source_t* transition);
export void obs_sceneitem_set_show_transition_duration(obs_sceneitem_t* item,
    uint duration_ms);

export void obs_sceneitem_set_transition(obs_sceneitem_t* item, bool show,
    obs_source_t* transition);
export obs_source_t* obs_sceneitem_get_transition(obs_sceneitem_t* item,
    bool show);
export void obs_sceneitem_set_transition_duration(obs_sceneitem_t* item,
    bool show,
    uint duration_ms);
export uint obs_sceneitem_get_transition_duration(obs_sceneitem_t* item,
    bool show);
export void obs_sceneitem_do_transition(obs_sceneitem_t* item, bool visible);
export void obs_sceneitem_transition_load(obs_sceneitem_t* item,
    obs_data_t* data, bool show);
export obs_data_t* obs_sceneitem_transition_save(obs_sceneitem_t* item,
    bool show);
export void obs_scene_prune_sources(obs_scene_t* scene);

/* ------------------------------------------------------------------------- */
/* Outputs */

export const(char)* obs_output_get_display_name(const(char)* id);

/**
 * Creates an output.
 *
 *   Outputs allow outputting to file, outputting to network, outputting to
 * directshow, or other custom outputs.
 */
export obs_output_t* obs_output_create(const(char)* id, const(char)* name,
    obs_data_t* settings,
    obs_data_t* hotkey_data);

/**
 * Adds/releases a reference to an output.  When the last reference is
 * released, the output is destroyed.
 */
export void obs_output_release(obs_output_t* output);

export void obs_weak_output_addref(obs_weak_output_t* weak);
export void obs_weak_output_release(obs_weak_output_t* weak);

export obs_output_t* obs_output_get_ref(obs_output_t* output);
export obs_weak_output_t* obs_output_get_weak_output(obs_output_t* output);
export obs_output_t* obs_weak_output_get_output(obs_weak_output_t* weak);

export bool obs_weak_output_references_output(obs_weak_output_t* weak,
    obs_output_t* output);

export const(char)* obs_output_get_name(const obs_output_t* output);

/** Starts the output. */
export bool obs_output_start(obs_output_t* output);

/** Stops the output. */
export void obs_output_stop(obs_output_t* output);

/**
 * On reconnection, start where it left of on reconnection.  Note however that
 * this option will consume extra memory to continually increase delay while
 * waiting to reconnect.
 */
enum OBS_OUTPUT_DELAY_PRESERVE = (1 << 0);

/**
 * Sets the current output delay, in seconds (if the output supports delay).
 *
 * If delay is currently active, it will set the delay value, but will not
 * affect the current delay, it will only affect the next time the output is
 * activated.
 */
export void obs_output_set_delay(obs_output_t* output, uint delay_sec,
    uint flags);

/** Gets the currently set delay value, in seconds. */
export uint obs_output_get_delay(const obs_output_t* output);

/** If delay is active, gets the currently active delay value, in seconds. */
export uint obs_output_get_active_delay(const obs_output_t* output);

/** Forces the output to stop.  Usually only used with delay. */
export void obs_output_force_stop(obs_output_t* output);

/** Returns whether the output is active */
export bool obs_output_active(const obs_output_t* output);

/** Returns output capability flags */
export uint obs_output_get_flags(const obs_output_t* output);

/** Returns output capability flags */
export uint obs_get_output_flags(const(char)* id);

/** Gets the default settings for an output type */
export obs_data_t* obs_output_defaults(const(char)* id);

/** Returns the property list, if any.  Free with obs_properties_destroy */
export obs_properties_t* obs_get_output_properties(const(char)* id);

/**
 * Returns the property list of an existing output, if any.  Free with
 * obs_properties_destroy
 */
export obs_properties_t* obs_output_properties(const obs_output_t* output);

/** Updates the settings for this output context */
export void obs_output_update(obs_output_t* output, obs_data_t* settings);

/** Specifies whether the output can be paused */
export bool obs_output_can_pause(const obs_output_t* output);

/** Pauses the output (if the functionality is allowed by the output */
export bool obs_output_pause(obs_output_t* output, bool pause);

/** Returns whether output is paused */
export bool obs_output_paused(const obs_output_t* output);

/* Gets the current output settings string */
export obs_data_t* obs_output_get_settings(const obs_output_t* output);

/** Returns the signal handler for an output  */
export signal_handler_t* obs_output_get_signal_handler(const obs_output_t* output);

/** Returns the procedure handler for an output */
export proc_handler_t* obs_output_get_proc_handler(const obs_output_t* output);

/**
 * Sets the current audio/video media contexts associated with this output,
 * required for non-encoded outputs.  Can be null.
 */
export void obs_output_set_media(obs_output_t* output, video_t* video,
    audio_t* audio);

/** Returns the video media context associated with this output */
export video_t* obs_output_video(const obs_output_t* output);

/** Returns the audio media context associated with this output */
export audio_t* obs_output_audio(const obs_output_t* output);

/** Sets the current audio mixer for non-encoded outputs */
export void obs_output_set_mixer(obs_output_t* output, size_t mixer_idx);

/** Gets the current audio mixer for non-encoded outputs */
export size_t obs_output_get_mixer(const obs_output_t* output);

/** Sets the current audio mixes (mask) for a non-encoded multi-track output */
export void obs_output_set_mixers(obs_output_t* output, size_t mixers);

/** Gets the current audio mixes (mask) for a non-encoded multi-track output */
export size_t obs_output_get_mixers(const obs_output_t* output);

/**
 * Sets the current video encoder associated with this output,
 * required for encoded outputs
 */
export void obs_output_set_video_encoder(obs_output_t* output,
    obs_encoder_t* encoder);

/**
 * Sets the current video encoder associated with this output,
 * required for encoded outputs.
 *
 * The idx parameter specifies the video encoder index.
 * Only used with outputs that have multiple video outputs (FFmpeg typically),
 * otherwise the parameter is ignored.
 */
export void obs_output_set_video_encoder2(obs_output_t* output,
    obs_encoder_t* encoder, size_t idx);

/**
 * Sets the current audio encoder associated with this output,
 * required for encoded outputs.
 *
 * The idx parameter specifies the audio encoder index to set the encoder to.
 * Only used with outputs that have multiple audio outputs (RTMP typically),
 * otherwise the parameter is ignored.
 */
export void obs_output_set_audio_encoder(obs_output_t* output,
    obs_encoder_t* encoder, size_t idx);

/** Returns the current video encoder associated with this output */
export obs_encoder_t* obs_output_get_video_encoder(const obs_output_t* output);

/**
 * Returns the current video encoder associated with this output.
 *
 * The idx parameter specifies the video encoder index.
 * Only used with outputs that have multiple video outputs (FFmpeg typically),
 * otherwise specifying an idx > 0 returns a NULL.
 * */
export obs_encoder_t* obs_output_get_video_encoder2(const obs_output_t* output,
    size_t idx);

/**
 * Returns the current audio encoder associated with this output
 *
 * The idx parameter specifies the audio encoder index.  Only used with
 * outputs that have multiple audio outputs, otherwise the parameter is
 * ignored.
 */
export obs_encoder_t* obs_output_get_audio_encoder(const obs_output_t* output,
    size_t idx);

/** Sets the current service associated with this output. */
export void obs_output_set_service(obs_output_t* output,
    obs_service_t* service);

/** Gets the current service associated with this output. */
export obs_service_t* obs_output_get_service(const obs_output_t* output);

/**
 * Sets the reconnect settings.  Set retry_count to 0 to disable reconnecting.
 */
export void obs_output_set_reconnect_settings(obs_output_t* output,
    int retry_count, int retry_sec);

export ulong obs_output_get_total_bytes(const obs_output_t* output);
export int obs_output_get_frames_dropped(const obs_output_t* output);
export int obs_output_get_total_frames(const obs_output_t* output);

/**
 * Sets the preferred scaled resolution for this output.  Set width and height
 * to 0 to disable scaling.
 *
 * If this output uses an encoder, it will call obs_encoder_set_scaled_size on
 * the encoder before the stream is started.  If the encoder is already active,
 * then this function will trigger a warning and do nothing.
 */
export void obs_output_set_preferred_size(obs_output_t* output, uint width,
    uint height);

/**
 * Sets the preferred scaled resolution for this output.  Set width and height
 * to 0 to disable scaling.
 *
 * If this output uses an encoder, it will call obs_encoder_set_scaled_size on
 * the encoder before the stream is started.  If the encoder is already active,
 * then this function will trigger a warning and do nothing.
 *
 * The idx parameter specifies the video encoder index to apply the scaling to.
 * Only used with outputs that have multiple video outputs (FFmpeg typically),
 * otherwise the parameter is ignored.
 */
export void obs_output_set_preferred_size2(obs_output_t* output, uint width,
    uint height, size_t idx);

/** For video outputs, returns the width of the encoded image */
export uint obs_output_get_width(const obs_output_t* output);

/**
 * For video outputs, returns the width of the encoded image.
 *
 * The idx parameter specifies the video encoder index.
 * Only used with outputs that have multiple video outputs (FFmpeg typically),
 * otherwise the parameter is ignored and returns 0.
 */
export uint obs_output_get_width2(const obs_output_t* output, size_t idx);

/** For video outputs, returns the height of the encoded image */
export uint obs_output_get_height(const obs_output_t* output);

/**
 * For video outputs, returns the height of the encoded image.
 *
 * The idx parameter specifies the video encoder index.
 * Only used with outputs that have multiple video outputs (FFmpeg typically),
 * otherwise the parameter is ignored and returns 0.
 */
export uint obs_output_get_height2(const obs_output_t* output, size_t idx);

export const(char)* obs_output_get_id(const obs_output_t* output);

export void obs_output_caption(obs_output_t* output,
    const obs_source_cea_708_t* captions);

export void obs_output_output_caption_text1(obs_output_t* output,
    const(char)* text);
export void obs_output_output_caption_text2(obs_output_t* output,
    const(char)* text,
    double display_duration);

export float obs_output_get_congestion(obs_output_t* output);
export int obs_output_get_connect_time_ms(obs_output_t* output);

export bool obs_output_reconnecting(const obs_output_t* output);

/** Pass a string of the last output error, for UI use */
export void obs_output_set_last_error(obs_output_t* output,
    const(char)* message);
export const(char)* obs_output_get_last_error(obs_output_t* output);

export const(char)* obs_output_get_supported_video_codecs(const obs_output_t* output);
export const(char)* obs_output_get_supported_audio_codecs(const obs_output_t* output);

export const(char)* obs_output_get_protocols(const obs_output_t* output);

export bool obs_is_output_protocol_registered(const(char)* protocol);

export bool obs_enum_output_protocols(size_t idx, char** protocol);

export void obs_enum_output_types_with_protocol(
    const(char)* protocol, void* data,
    bool function(void* data, const(char)* id) enum_cb);

export const(char)* obs_get_output_supported_video_codecs(const(char)* id);

export const(char)* obs_get_output_supported_audio_codecs(const(char)* id);

/* ------------------------------------------------------------------------- */
/* Functions used by outputs */

export void* obs_output_get_type_data(obs_output_t* output);

/** Gets the video conversion info.  Used only for raw output */
export const(video_scale_info_t)* obs_output_get_video_conversion(obs_output_t* output);

/** Optionally sets the video conversion info.  Used only for raw output */
export void obs_output_set_video_conversion(obs_output_t* output,
    const video_scale_info_t* conversion);

/** Optionally sets the audio conversion info.  Used only for raw output */
export void obs_output_set_audio_conversion(obs_output_t* output,
    const audio_convert_info_t* conversion);

/** Returns whether data capture can begin  */
export bool obs_output_can_begin_data_capture(const obs_output_t* output,
    uint flags);

/** Initializes encoders (if any) */
export bool obs_output_initialize_encoders(obs_output_t* output,
    uint flags);

/**
 * Begins data capture from media/encoders.
 *
 * @param  output  Output context
 * @return         true if successful, false otherwise.
 */
export bool obs_output_begin_data_capture(obs_output_t* output, uint flags);

/** Ends data capture from media/encoders */
export void obs_output_end_data_capture(obs_output_t* output);

/**
 * Signals that the output has stopped itself.
 *
 * @param  output  Output context
 * @param  code    Error code (or OBS_OUTPUT_SUCCESS if not an error)
 */
export void obs_output_signal_stop(obs_output_t* output, int code);

export ulong obs_output_get_pause_offset(obs_output_t* output);

/* ------------------------------------------------------------------------- */
/* Encoders */

// export const(char)* obs_encoder_get_display_name(const(char)* id);

// /**
//  * Creates a video encoder context
//  *
//  * @param  id        Video encoder ID
//  * @param  name      Name to assign to this context
//  * @param  settings  Settings
//  * @return           The video encoder context, or NULL if failed or not found.
//  */
// export obs_encoder_t* obs_video_encoder_create(const(char)* id, const(char)* name,
//     obs_data_t* settings,
//     obs_data_t* hotkey_data);

// /**
//  * Creates an audio encoder context
//  *
//  * @param  id        Audio Encoder ID
//  * @param  name      Name to assign to this context
//  * @param  settings  Settings
//  * @param  mixer_idx Index of the mixer to use for this audio encoder
//  * @return           The video encoder context, or NULL if failed or not found.
//  */
// export obs_encoder_t* obs_audio_encoder_create(const(char)* id, const(char)* name,
//     obs_data_t* settings,
//     size_t mixer_idx,
//     obs_data_t* hotkey_data);

// /**
//  * Adds/releases a reference to an encoder.  When the last reference is
//  * released, the encoder is destroyed.
//  */
// export void obs_encoder_release(obs_encoder_t* encoder);

// export void obs_weak_encoder_addref(obs_weak_encoder_t* weak);
// export void obs_weak_encoder_release(obs_weak_encoder_t* weak);

// export obs_encoder_t* obs_encoder_get_ref(obs_encoder_t* encoder);
// export obs_weak_encoder_t* obs_encoder_get_weak_encoder(obs_encoder_t* encoder);
// export obs_encoder_t* obs_weak_encoder_get_encoder(obs_weak_encoder_t* weak);

// export bool obs_weak_encoder_references_encoder(obs_weak_encoder_t* weak,
//     obs_encoder_t* encoder);

// export void obs_encoder_set_name(obs_encoder_t* encoder, const(char)* name);
// export const(char)* obs_encoder_get_name(const obs_encoder_t* encoder);

// /** Returns the codec of an encoder by the id */
// export const(char)* obs_get_encoder_codec(const(char)* id);

// /** Returns the type of an encoder by the id */
// export obs_encoder_type_t obs_get_encoder_type(const(char)* id);

// /** Returns the codec of the encoder */
// export const(char)* obs_encoder_get_codec(const obs_encoder_t* encoder);

// /** Returns the type of an encoder */
// export obs_encoder_type_t obs_encoder_get_type(const obs_encoder_t* encoder);

// /**
//  * Sets the scaled resolution for a video encoder.  Set width and height to 0
//  * to disable scaling.  If the encoder is active, this function will trigger
//  * a warning, and do nothing.
//  */
// export void obs_encoder_set_scaled_size(obs_encoder_t* encoder, uint width,
//     uint height);

// /**
//  * Enable/disable GPU based scaling for a video encoder.
//  * OBS_SCALE_DISABLE disables GPU based scaling (default),
//  * any other value enables GPU based scaling. If the encoder
//  * is active, this function will trigger a warning, and do nothing.
//  */
// export void obs_encoder_set_gpu_scale_type(obs_encoder_t* encoder,
//     obs_scale_type gpu_scale_type);

// /**
//  * Set frame rate divisor for a video encoder. This allows recording at
//  * a partial frame rate compared to the base frame rate, e.g. 60 FPS with
//  * divisor = 2 will record at 30 FPS, with divisor = 3 at 20, etc.
//  *
//  * Can only be called on stopped encoders, changing this on the fly is not supported
//  */
// export bool obs_encoder_set_frame_rate_divisor(obs_encoder_t* encoder,
//     uint divisor);

// /**
//  * Adds region of interest (ROI) for an encoder. This allows prioritizing
//  * quality of regions of the frame.
//  * If regions overlap, regions added earlier take precedence.
//  *
//  * Returns false if the encoder does not support ROI or region is invalid.
//  */
// export bool obs_encoder_add_roi(obs_encoder_t* encoder,
//     const obs_encoder_roi* roi);
// /** For video encoders, returns true if any ROIs were set */
// export bool obs_encoder_has_roi(const obs_encoder_t* encoder);
// /** Clear all regions */
// export void obs_encoder_clear_roi(obs_encoder_t* encoder);
// /** Enumerate regions with callback (reverse order of addition) */
// export void obs_encoder_enum_roi(obs_encoder_t* encoder,
//     void function(void*,
//         obs_encoder_roi*) enum_proc,
//     void* param);
// /** Get ROI increment, encoders must rebuild their ROI map if it has changed */
// export uint obs_encoder_get_roi_increment(const obs_encoder_t* encoder);

// /** For video encoders, returns true if pre-encode scaling is enabled */
// export bool obs_encoder_scaling_enabled(const obs_encoder_t* encoder);

// /** For video encoders, returns the width of the encoded image */
// export uint obs_encoder_get_width(const obs_encoder_t* encoder);

// /** For video encoders, returns the height of the encoded image */
// export uint obs_encoder_get_height(const obs_encoder_t* encoder);

// /** For video encoders, returns whether GPU scaling is enabled */
// export bool obs_encoder_gpu_scaling_enabled(obs_encoder_t* encoder);

// /** For video encoders, returns GPU scaling type */
// export obs_scale_type obs_encoder_get_scale_type(obs_encoder_t* encoder);

// /** For video encoders, returns the frame rate divisor (default is 1) */
// export uint obs_encoder_get_frame_rate_divisor(const obs_encoder_t* encoder);

// /** For audio encoders, returns the sample rate of the audio */
// export uint obs_encoder_get_sample_rate(const obs_encoder_t* encoder);

// /** For audio encoders, returns the frame size of the audio packet */
// export size_t obs_encoder_get_frame_size(const obs_encoder_t* encoder);

// /**
//  * Sets the preferred video format for a video encoder.  If the encoder can use
//  * the format specified, it will force a conversion to that format if the
//  * obs output format does not match the preferred format.
//  *
//  * If the format is set to video_format_t_NONE, will revert to the default
//  * functionality of converting only when absolutely necessary.
//  */
// export void obs_encoder_set_preferred_video_format_t(obs_encoder_t* encoder,
//     video_format_t format);
// export video_format_t obs_encoder_get_preferred_video_format_t(const obs_encoder_t* encoder);

// /** Gets the default settings for an encoder type */
// export obs_data_t* obs_encoder_defaults(const(char)* id);
// export obs_data_t* obs_encoder_get_defaults(const obs_encoder_t* encoder);

// /** Returns the property list, if any.  Free with obs_properties_destroy */
// export obs_properties_t* obs_get_encoder_properties(const(char)* id);

// /**
//  * Returns the property list of an existing encoder, if any.  Free with
//  * obs_properties_destroy
//  */
// export obs_properties_t* obs_encoder_properties(const obs_encoder_t* encoder);

// /**
//  * Updates the settings of the encoder context.  Usually used for changing
//  * bitrate while active
//  */
// export void obs_encoder_update(obs_encoder_t* encoder, obs_data_t* settings);

// /** Gets extra data (headers) associated with this context */
// export bool obs_encoder_get_extra_data(const obs_encoder_t* encoder,
//     ubyte** extra_data, size_t* size);

// /** Returns the current settings for this encoder */
// export obs_data_t* obs_encoder_get_settings(const obs_encoder_t* encoder);

// /** Sets the video output context to be used with this encoder */
// export void obs_encoder_set_video(obs_encoder_t* encoder, video_t* video);

// /** Sets the audio output context to be used with this encoder */
// export void obs_encoder_set_audio(obs_encoder_t* encoder, audio_t* audio);

// /**
//  * Returns the video output context used with this encoder, or NULL if not
//  * a video context
//  */
// export video_t* obs_encoder_video(const obs_encoder_t* encoder);

// /**
//  * Returns the audio output context used with this encoder, or NULL if not
//  * a audio context
//  */
// export audio_t* obs_encoder_audio(const obs_encoder_t* encoder);

// /** Returns true if encoder is active, false otherwise */
// export bool obs_encoder_active(const obs_encoder_t* encoder);

// export void* obs_encoder_get_type_data(obs_encoder_t* encoder);

// export const(char)* obs_encoder_get_id(const obs_encoder_t* encoder);

// export uint obs_get_encoder_caps(const(char)* encoder_id);
// export uint obs_encoder_get_caps(const obs_encoder_t* encoder);

// export void obs_encoder_packet_ref(encoder_packet_t* dst,
//     encoder_packet_t* src);
// export void obs_encoder_packet_release(encoder_packet_t* packet);

// export void* obs_encoder_create_rerouted(obs_encoder_t* encoder,
//     const(char)* reroute_id);

// /** Returns whether encoder is paused */
// export bool obs_encoder_paused(const obs_encoder_t* output);

// export const(char)* obs_encoder_get_last_error(obs_encoder_t* encoder);
// export void obs_encoder_set_last_error(obs_encoder_t* encoder,
//     const(char)* message);

// export ulong obs_encoder_get_pause_offset(const obs_encoder_t* encoder);

/* ------------------------------------------------------------------------- */
/* Stream Services */

// export const(char)* obs_service_get_display_name(const(char)* id);

// export obs_service_t* obs_service_create(const(char)* id, const(char)* name,
//     obs_data_t* settings,
//     obs_data_t* hotkey_data);

// export obs_service_t* obs_service_create_private(const(char)* id,
//     const(char)* name,
//     obs_data_t* settings);

// /**
//  * Adds/releases a reference to a service.  When the last reference is
//  * released, the service is destroyed.
//  */
// export void obs_service_release(obs_service_t* service);

// export void obs_weak_service_addref(obs_weak_service_t* weak);
// export void obs_weak_service_release(obs_weak_service_t* weak);

// export obs_service_t* obs_service_get_ref(obs_service_t* service);
// export obs_weak_service_t* obs_service_get_weak_service(obs_service_t* service);
// export obs_service_t* obs_weak_service_get_service(obs_weak_service_t* weak);

// export bool obs_weak_service_references_service(obs_weak_service_t* weak,
//     obs_service_t* service);

// export const(char)* obs_service_get_name(const obs_service_t* service);

// /** Gets the default settings for a service */
// export obs_data_t* obs_service_defaults(const(char)* id);

// /** Returns the property list, if any.  Free with obs_properties_destroy */
// export obs_properties_t* obs_get_service_properties(const(char)* id);

// /**
//  * Returns the property list of an existing service context, if any.  Free with
//  * obs_properties_destroy
//  */
// export obs_properties_t* obs_service_properties(const obs_service_t* service);

// /** Gets the service type */
// export const(char)* obs_service_get_type(const obs_service_t* service);

// /** Updates the settings of the service context */
// export void obs_service_update(obs_service_t* service, obs_data_t* settings);

// /** Returns the current settings for this service */
// export obs_data_t* obs_service_get_settings(const obs_service_t* service);

// /**
//  * Applies service-specific video encoder settings.
//  *
//  * @param  video_encoder_settings  Video encoder settings.  Optional.
//  * @param  audio_encoder_settings  Audio encoder settings.  Optional.
//  */
// export void obs_service_apply_encoder_settings(obs_service_t* service,
//     obs_data_t* video_encoder_settings,
//     obs_data_t* audio_encoder_settings);

// export void* obs_service_get_type_data(obs_service_t* service);

// export const(char)* obs_service_get_id(const obs_service_t* service);

// export void obs_service_get_supported_resolutions(
//     const obs_service_t* service,
//     obs_service_resolution** resolutions, size_t* count);
// export void obs_service_get_max_fps(const obs_service_t* service, int* fps);

// export void obs_service_get_max_bitrate(const obs_service_t* service,
//     int* video_bitrate, int* audio_bitrate);

// export const(char)** obs_service_get_supported_video_codecs(const obs_service_t* service);

// export const(char)** obs_service_get_supported_audio_codecs(const obs_service_t* service);

// /** Returns the protocol for this service context */
// export const(char)* obs_service_get_protocol(const obs_service_t* service);

// export const(char)* obs_service_get_preferred_output_type(const obs_service_t* service);

// export const(char)* obs_service_get_connect_info(const obs_service_t* service,
//     uint type);

// export bool obs_service_can_try_to_connect(const obs_service_t* service);

/* ------------------------------------------------------------------------- */
/* Source frame allocation functions */
export void obs_source_frame_init(obs_source_frame_t* frame,
    video_format_t format, uint width,
    uint height);

pragma(inline)
static void obs_source_frame_free(obs_source_frame_t* frame) {
    if (frame) {
        bfree(frame.data[0]);
        memset(frame, 0, (*frame).sizeof);
    }
}

pragma(inline)
static obs_source_frame_t* obs_source_frame_create(video_format_t format, uint width,
    uint height) {
    obs_source_frame_t* frame;

    frame = cast(obs_source_frame_t*) bzalloc((*frame).sizeof);
    obs_source_frame_init(frame, format, width, height);
    return frame;
}

pragma(inline)
static void obs_source_frame_destroy(obs_source_frame_t* frame) {
    if (frame) {
        bfree(frame.data[0]);
        bfree(frame);
    }
}

export void obs_source_frame_copy(obs_source_frame_t* dst,
    const obs_source_frame_t* src);

/* ------------------------------------------------------------------------- */
/* Get source icon type */
export obs_icon_type_t obs_source_get_icon_type(const(char)* id);
