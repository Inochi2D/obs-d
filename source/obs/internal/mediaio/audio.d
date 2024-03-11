module obs.internal.mediaio.audio;
import obs.internal.mediaio;
extern(C):

enum MAX_AUDIO_MIXES = 6;
enum MAX_AUDIO_CHANNELS = 8;
enum MAX_DEVICE_INPUT_CHANNELS = 64;
enum AUDIO_OUTPUT_FRAMES = 1024;

enum TOTAL_AUDIO_SIZE = (MAX_AUDIO_MIXES * MAX_AUDIO_CHANNELS * AUDIO_OUTPUT_FRAMES * float.sizeof);

/*
 * Base audio output component.  Use this to create an audio output track
 * for the media.
 */

struct audio_output_t;
alias audio_t = audio_output_t;

enum audio_format_t {
    AUDIO_FORMAT_UNKNOWN,

    AUDIO_FORMAT_U8BIT,
    AUDIO_FORMAT_16BIT,
    AUDIO_FORMAT_32BIT,
    AUDIO_FORMAT_FLOAT,

    AUDIO_FORMAT_U8BIT_PLANAR,
    AUDIO_FORMAT_16BIT_PLANAR,
    AUDIO_FORMAT_32BIT_PLANAR,
    AUDIO_FORMAT_FLOAT_PLANAR,
};

/**
 * The speaker layout describes where the speakers are located in the room.
 * For OBS it dictates:
 *  *  how many channels are available and
 *  *  which channels are used for which speakers.
 *
 * Standard channel layouts where retrieved from ffmpeg documentation at:
 *     https://trac.ffmpeg.org/wiki/AudioChannelManipulation
 */
enum speaker_layout_t {
    SPEAKERS_UNKNOWN, /**< Unknown setting, fallback is stereo. */
    SPEAKERS_MONO, /**< Channels: MONO */
    SPEAKERS_STEREO, /**< Channels: FL, FR */
    SPEAKERS_2POINT1, /**< Channels: FL, FR, LFE */
    SPEAKERS_4POINT0, /**< Channels: FL, FR, FC, RC */
    SPEAKERS_4POINT1, /**< Channels: FL, FR, FC, LFE, RC */
    SPEAKERS_5POINT1, /**< Channels: FL, FR, FC, LFE, RL, RR */
    SPEAKERS_7POINT1 = 8, /**< Channels: FL, FR, FC, LFE, RL, RR, SL, SR */

}

struct audio_data_t {
    ubyte[MAX_AV_PLANES]* data;
    uint frames;
    ulong timestamp;
}

struct audio_output_data_t {
    float[MAX_AUDIO_CHANNELS]* data;
}

alias audio_input_callback_t = bool function(void* param, ulong start_ts,
    ulong end_ts, ulong* new_ts,
    uint active_mixers,
    audio_output_data_t* mixes);

struct audio_output_info_t {
    const char* name;

    uint samples_per_sec;
    audio_format_t format;
    speaker_layout_t speakers;

    audio_input_callback_t input_callback;
    void* input_param;
};

struct audio_convert_info_t {
    uint samples_per_sec;
    audio_format_t format;
    speaker_layout_t speakers;
    bool allow_clipping;
};

pragma(inline, true)
static uint get_audio_channels(speaker_layout_t speakers) {
    switch (speakers) {
    case speaker_layout_t.SPEAKERS_MONO:
        return 1;
    case speaker_layout_t.SPEAKERS_STEREO:
        return 2;
    case speaker_layout_t.SPEAKERS_2POINT1:
        return 3;
    case speaker_layout_t.SPEAKERS_4POINT0:
        return 4;
    case speaker_layout_t.SPEAKERS_4POINT1:
        return 5;
    case speaker_layout_t.SPEAKERS_5POINT1:
        return 6;
    case speaker_layout_t.SPEAKERS_7POINT1:
        return 8;
    case speaker_layout_t.SPEAKERS_UNKNOWN:
    default:
        return 0;
    }

    return 0;
}

pragma(inline, true)
static size_t get_audio_bytes_per_channel(audio_format_t format) {
    switch (format) {
    case audio_format_t.AUDIO_FORMAT_U8BIT:
    case audio_format_t.AUDIO_FORMAT_U8BIT_PLANAR:
        return 1;

    case audio_format_t.AUDIO_FORMAT_16BIT:
    case audio_format_t.AUDIO_FORMAT_16BIT_PLANAR:
        return 2;

    case audio_format_t.AUDIO_FORMAT_FLOAT:
    case audio_format_t.AUDIO_FORMAT_FLOAT_PLANAR:
    case audio_format_t.AUDIO_FORMAT_32BIT:
    case audio_format_t.AUDIO_FORMAT_32BIT_PLANAR:
        return 4;

    case audio_format_t.AUDIO_FORMAT_UNKNOWN:
    default:
        return 0;
    }

    return 0;
}

pragma(inline, true)
static bool is_audio_planar(audio_format_t format) {
    switch (format) {
    case audio_format_t.AUDIO_FORMAT_U8BIT:
    case audio_format_t.AUDIO_FORMAT_16BIT:
    case audio_format_t.AUDIO_FORMAT_32BIT:
    case audio_format_t.AUDIO_FORMAT_FLOAT:
        return false;

    case audio_format_t.AUDIO_FORMAT_U8BIT_PLANAR:
    case audio_format_t.AUDIO_FORMAT_FLOAT_PLANAR:
    case audio_format_t.AUDIO_FORMAT_16BIT_PLANAR:
    case audio_format_t.AUDIO_FORMAT_32BIT_PLANAR:
        return true;

    case audio_format_t.AUDIO_FORMAT_UNKNOWN:
    default:
        return false;
    }

    return false;
}

pragma(inline, true)
static size_t get_audio_planes(audio_format_t format,
    speaker_layout_t speakers) {
    return (is_audio_planar(format) ? get_audio_channels(speakers) : 1);
}

pragma(inline, true)

static size_t get_audio_size(audio_format_t format,
    speaker_layout_t speakers,
    uint frames) {
    bool planar = is_audio_planar(format);

    return (planar ? 1 : get_audio_channels(speakers)) *
        get_audio_bytes_per_channel(format) * frames;
}

pragma(inline, true)
static size_t get_total_audio_size(audio_format_t format,
    speaker_layout_t speakers,
    uint frames) {
    return get_audio_channels(speakers) *
        get_audio_bytes_per_channel(format) * frames;
}

// pragma(inline, true)
// static ulong audio_frames_to_ns(size_t sample_rate, ulong frames) {
//     return util_mul_div64(frames, 1000000000UL, sample_rate);
// }

// pragma(inline, true)
// static ulong ns_to_audio_frames(size_t sample_rate, ulong frames) {
//     return util_mul_div64(frames, sample_rate, 1000000000UL);
// }

enum AUDIO_OUTPUT_SUCCESS = 0;
enum AUDIO_OUTPUT_INVALIDPARAM = -1;
enum AUDIO_OUTPUT_FAIL = -2;

export int audio_output_open(audio_t** audio, audio_output_info_t* info);
export void audio_output_close(audio_t* audio);

alias audio_output_callback_t = void function(void* param, size_t mix_idx,
    audio_data_t* data);

export bool audio_output_connect(audio_t* video, size_t mix_idx,
    const(audio_convert_info_t*)* conversion,
    audio_output_callback_t callback, void* param);
export void audio_output_disconnect(audio_t* video, size_t mix_idx,
    audio_output_callback_t callback,
    void* param);

export bool audio_output_active(const audio_t* audio);

export size_t audio_output_get_block_size(const audio_t* audio);
export size_t audio_output_get_planes(const audio_t* audio);
export size_t audio_output_get_channels(const audio_t* audio);
export uint audio_output_get_sample_rate(const audio_t* audio);
export const(audio_output_info_t)* audio_output_get_info(const audio_t* audio);
