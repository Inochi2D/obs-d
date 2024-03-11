module obs.internal.mediaio.video;
import obs.internal.mediaio;

extern (C):

struct video_frame_t;

/* Base video output component.  Use this to create a video output track. */

struct video_output_t;
alias video_t = video_output_t;

enum video_format_t {
    VIDEO_FORMAT_NONE,

    /* planar 4:2:0 formats */
    VIDEO_FORMAT_I420, /* three-plane */
    VIDEO_FORMAT_NV12, /* two-plane, luma and packed chroma */

    /* packed 4:2:2 formats */
    VIDEO_FORMAT_YVYU,
    VIDEO_FORMAT_YUY2, /* YUYV */
    VIDEO_FORMAT_UYVY,

    /* packed uncompressed formats */
    VIDEO_FORMAT_RGBA,
    VIDEO_FORMAT_BGRA,
    VIDEO_FORMAT_BGRX,
    VIDEO_FORMAT_Y800, /* grayscale */

    /* planar 4:4:4 */
    VIDEO_FORMAT_I444,

    /* more packed uncompressed formats */
    VIDEO_FORMAT_BGR3,

    /* planar 4:2:2 */
    VIDEO_FORMAT_I422,

    /* planar 4:2:0 with alpha */
    VIDEO_FORMAT_I40A,

    /* planar 4:2:2 with alpha */
    VIDEO_FORMAT_I42A,

    /* planar 4:4:4 with alpha */
    VIDEO_FORMAT_YUVA,

    /* packed 4:4:4 with alpha */
    VIDEO_FORMAT_AYUV,

    /* planar 4:2:0 format, 10 bpp */
    VIDEO_FORMAT_I010, /* three-plane */
    VIDEO_FORMAT_P010, /* two-plane, luma and packed chroma */

    /* planar 4:2:2 format, 10 bpp */
    VIDEO_FORMAT_I210,

    /* planar 4:4:4 format, 12 bpp */
    VIDEO_FORMAT_I412,

    /* planar 4:4:4:4 format, 12 bpp */
    VIDEO_FORMAT_YA2L,

    /* planar 4:2:2 format, 16 bpp */
    VIDEO_FORMAT_P216, /* two-plane, luma and packed chroma */

    /* planar 4:4:4 format, 16 bpp */
    VIDEO_FORMAT_P416, /* two-plane, luma and packed chroma */

    /* packed 4:2:2 format, 10 bpp */
    VIDEO_FORMAT_V210,

    /* packed uncompressed 10-bit format */
    VIDEO_FORMAT_R10L,
};

enum video_trc_t {
    VIDEO_TRC_DEFAULT,
    VIDEO_TRC_SRGB,
    VIDEO_TRC_PQ,
    VIDEO_TRC_HLG,
};

enum video_colorspace_t {
    VIDEO_CS_DEFAULT,
    VIDEO_CS_601,
    VIDEO_CS_709,
    VIDEO_CS_SRGB,
    VIDEO_CS_2100_PQ,
    VIDEO_CS_2100_HLG,
};

enum video_range_type_t {
    VIDEO_RANGE_DEFAULT,
    VIDEO_RANGE_PARTIAL,
    VIDEO_RANGE_FULL,
};

struct video_data_t {
    ubyte*[MAX_AV_PLANES] data;
    uint[MAX_AV_PLANES] linesize;
    ulong timestamp;
};

struct video_output_info_t {
    const(char)* name;

    video_format_t format;
    uint fps_num;
    uint fps_den;
    uint width;
    uint height;
    size_t cache_size;

    video_colorspace_t colorspace;
    video_range_type_t range;
};

pragma(inline, true)
static bool format_is_yuv(video_format_t format) {
    final switch (format) {
    case video_format_t.VIDEO_FORMAT_I420:
    case video_format_t.VIDEO_FORMAT_NV12:
    case video_format_t.VIDEO_FORMAT_I422:
    case video_format_t.VIDEO_FORMAT_I210:
    case video_format_t.VIDEO_FORMAT_YVYU:
    case video_format_t.VIDEO_FORMAT_YUY2:
    case video_format_t.VIDEO_FORMAT_UYVY:
    case video_format_t.VIDEO_FORMAT_I444:
    case video_format_t.VIDEO_FORMAT_I412:
    case video_format_t.VIDEO_FORMAT_I40A:
    case video_format_t.VIDEO_FORMAT_I42A:
    case video_format_t.VIDEO_FORMAT_YUVA:
    case video_format_t.VIDEO_FORMAT_YA2L:
    case video_format_t.VIDEO_FORMAT_AYUV:
    case video_format_t.VIDEO_FORMAT_I010:
    case video_format_t.VIDEO_FORMAT_P010:
    case video_format_t.VIDEO_FORMAT_P216:
    case video_format_t.VIDEO_FORMAT_P416:
    case video_format_t.VIDEO_FORMAT_V210:
        return true;
    case video_format_t.VIDEO_FORMAT_NONE:
    case video_format_t.VIDEO_FORMAT_RGBA:
    case video_format_t.VIDEO_FORMAT_BGRA:
    case video_format_t.VIDEO_FORMAT_BGRX:
    case video_format_t.VIDEO_FORMAT_Y800:
    case video_format_t.VIDEO_FORMAT_BGR3:
    case video_format_t.VIDEO_FORMAT_R10L:
        return false;
    }

    return false;
}

pragma(inline, true)
static const(char)* get_video_format_name(video_format_t format) {
    final switch (format) {
    case video_format_t.VIDEO_FORMAT_I420:
        return "I420";
    case video_format_t.VIDEO_FORMAT_NV12:
        return "NV12";
    case video_format_t.VIDEO_FORMAT_I422:
        return "I422";
    case video_format_t.VIDEO_FORMAT_I210:
        return "I210";
    case video_format_t.VIDEO_FORMAT_YVYU:
        return "YVYU";
    case video_format_t.VIDEO_FORMAT_YUY2:
        return "YUY2";
    case video_format_t.VIDEO_FORMAT_UYVY:
        return "UYVY";
    case video_format_t.VIDEO_FORMAT_RGBA:
        return "RGBA";
    case video_format_t.VIDEO_FORMAT_BGRA:
        return "BGRA";
    case video_format_t.VIDEO_FORMAT_BGRX:
        return "BGRX";
    case video_format_t.VIDEO_FORMAT_I444:
        return "I444";
    case video_format_t.VIDEO_FORMAT_I412:
        return "I412";
    case video_format_t.VIDEO_FORMAT_Y800:
        return "Y800";
    case video_format_t.VIDEO_FORMAT_BGR3:
        return "BGR3";
    case video_format_t.VIDEO_FORMAT_I40A:
        return "I40A";
    case video_format_t.VIDEO_FORMAT_I42A:
        return "I42A";
    case video_format_t.VIDEO_FORMAT_YUVA:
        return "YUVA";
    case video_format_t.VIDEO_FORMAT_YA2L:
        return "YA2L";
    case video_format_t.VIDEO_FORMAT_AYUV:
        return "AYUV";
    case video_format_t.VIDEO_FORMAT_I010:
        return "I010";
    case video_format_t.VIDEO_FORMAT_P010:
        return "P010";
    case video_format_t.VIDEO_FORMAT_P216:
        return "P216";
    case video_format_t.VIDEO_FORMAT_P416:
        return "P416";
    case video_format_t.VIDEO_FORMAT_V210:
        return "v210";
    case video_format_t.VIDEO_FORMAT_R10L:
        return "R10l";
    case video_format_t.VIDEO_FORMAT_NONE:
        return "";
    }

    return "None";
}

pragma(inline, true)
static const(char)* get_video_colorspace_name(video_colorspace_t cs) {
    final switch (cs) {
    case video_colorspace_t.VIDEO_CS_DEFAULT:
    case video_colorspace_t.VIDEO_CS_709:
        return "Rec. 709";
    case video_colorspace_t.VIDEO_CS_SRGB:
        return "sRGB";
    case video_colorspace_t.VIDEO_CS_601:
        return "Rec. 601";
    case video_colorspace_t.VIDEO_CS_2100_PQ:
        return "Rec. 2100 (PQ)";
    case video_colorspace_t.VIDEO_CS_2100_HLG:
        return "Rec. 2100 (HLG)";
    }

    return "Unknown";
}

pragma(inline, true)
static video_range_type_t resolve_video_range(video_format_t format, video_range_type_t range) {
    if (range == video_range_type_t.VIDEO_RANGE_DEFAULT) {
        range = format_is_yuv(format) ? video_range_type_t.VIDEO_RANGE_PARTIAL : video_range_type_t.VIDEO_RANGE_FULL;
    }

    return range;
}

pragma(inline, true)
static const(char)* get_video_range_name(video_format_t format,
    video_range_type_t range) {
    range = resolve_video_range(format, range);
    return range == video_range_type_t.VIDEO_RANGE_FULL ? "Full" : "Partial";
}

enum video_scale_type_t {
    VIDEO_SCALE_DEFAULT,
    VIDEO_SCALE_POINT,
    VIDEO_SCALE_FAST_BILINEAR,
    VIDEO_SCALE_BILINEAR,
    VIDEO_SCALE_BICUBIC,
};

struct video_scale_info_t {
    video_format_t format;
    uint width;
    uint height;
    video_range_type_t range;
    video_colorspace_t colorspace;
};

export video_format_t video_format_from_fourcc(uint fourcc);

export bool video_format_get_parameters(video_colorspace_t color_space,
    video_range_type_t range,
    float[16] matrix, float[3] min_range,
    float[3] max_range);
export bool video_format_get_parameters_for_format(
    video_colorspace_t color_space, video_range_type_t range,
    video_format_t format, float[16] matrix, float[3] min_range,
    float[3] max_range);

enum VIDEO_OUTPUT_SUCCESS = 0;
enum VIDEO_OUTPUT_INVALIDPARAM = -1;
enum VIDEO_OUTPUT_FAIL = -2;

export int video_output_open(video_t** video, video_output_info_t* info);
export void video_output_close(video_t* video);

export bool video_output_connect(video_t* video, const video_scale_info_t* conversion,
    void function(void* param, video_data_t* frame) callback,
    void* param);
export bool video_output_connect2(video_t* video, const video_scale_info_t* conversion,
    uint frame_rate_divisor,
    void function(void* param, video_data_t* frame) callback,
    void* param);
export void video_output_disconnect(video_t* video,
    void function(void* param,
        video_data_t* frame) callback,
    void* param);

export bool video_output_active(const video_t* video);

export const(video_output_info_t)* video_output_get_info(const video_t* video);
export bool video_output_lock_frame(video_t* video, video_frame_t* frame,
    int count, ulong timestamp);
export void video_output_unlock_frame(video_t* video);
export ulong video_output_get_frame_time(const video_t* video);
export void video_output_stop(video_t* video);
export bool video_output_stopped(video_t* video);

export video_format_t video_output_get_format(const video_t* video);
export uint video_output_get_width(const video_t* video);
export uint video_output_get_height(const video_t* video);
export double video_output_get_frame_rate(const video_t* video);

export uint video_output_get_skipped_frames(const video_t* video);
export uint video_output_get_total_frames(const video_t* video);

extern void video_output_inc_texture_encoders(video_t* video);
extern void video_output_dec_texture_encoders(video_t* video);
extern void video_output_inc_texture_frames(video_t* video);
extern void video_output_inc_texture_skipped_frames(video_t* video);

extern video_t* video_output_create_with_frame_rate_divisor(video_t* video,
    uint divisor);
extern void video_output_free_frame_rate_divisor(video_t* video);
