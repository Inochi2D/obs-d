module obs.source;
import obs.internal.source;
import obs.internal.data;
import obs.internal.obs;
import obs.internal.graphics;
import std.traits;
import inmath;

public import obs.internal.obs : obs_source_t;
public import obs.internal.data : obs_data_t;
public import obs.internal.source : 
    OBS_SOURCE_AUDIO,
    OBS_SOURCE_VIDEO,
    OBS_SOURCE_ASYNC, 
    OBS_SOURCE_ASYNC_VIDEO;

enum OBSSourceType : obs_source_type_t {
    Input = obs_source_type_t.OBS_SOURCE_TYPE_INPUT,
    Filter = obs_source_type_t.OBS_SOURCE_TYPE_FILTER,
    Transition = obs_source_type_t.OBS_SOURCE_TYPE_TRANSITION,
    Scene = obs_source_type_t.OBS_SOURCE_TYPE_SCENE,
}

enum OBSBalanceType : obs_balance_type_t {
    SineLaw = obs_balance_type_t.OBS_BALANCE_TYPE_SINE_LAW,
    SquareLaw = obs_balance_type_t.OBS_BALANCE_TYPE_SQUARE_LAW,
    Linear = obs_balance_type_t.OBS_BALANCE_TYPE_LINEAR,
}

enum OBSIconType : obs_icon_type_t {
    Unknown = obs_icon_type_t.OBS_ICON_TYPE_UNKNOWN,
    Image = obs_icon_type_t.OBS_ICON_TYPE_IMAGE,
    Color = obs_icon_type_t.OBS_ICON_TYPE_COLOR,
    Slideshow = obs_icon_type_t.OBS_ICON_TYPE_SLIDESHOW,
    AudioInput = obs_icon_type_t.OBS_ICON_TYPE_AUDIO_INPUT,
    AudioOutput = obs_icon_type_t.OBS_ICON_TYPE_AUDIO_OUTPUT,
    DesktopCapture = obs_icon_type_t.OBS_ICON_TYPE_DESKTOP_CAPTURE,
    WindowCapture = obs_icon_type_t.OBS_ICON_TYPE_WINDOW_CAPTURE,
    GameCapture = obs_icon_type_t.OBS_ICON_TYPE_GAME_CAPTURE,
    Camera = obs_icon_type_t.OBS_ICON_TYPE_CAMERA,
    Text = obs_icon_type_t.OBS_ICON_TYPE_TEXT,
    Media = obs_icon_type_t.OBS_ICON_TYPE_MEDIA,
    Browser = obs_icon_type_t.OBS_ICON_TYPE_BROWSER,
    Custom = obs_icon_type_t.OBS_ICON_TYPE_CUSTOM,
    ProcessAudioOutput = obs_icon_type_t.OBS_ICON_TYPE_PROCESS_AUDIO_OUTPUT,
}

enum OBSMediaState : obs_media_state_t {
    None = obs_media_state_t.OBS_MEDIA_STATE_NONE,
    Playing = obs_media_state_t.OBS_MEDIA_STATE_PLAYING,
    Opening = obs_media_state_t.OBS_MEDIA_STATE_OPENING,
    Buffering = obs_media_state_t.OBS_MEDIA_STATE_BUFFERING,
    Paused = obs_media_state_t.OBS_MEDIA_STATE_PAUSED,
    Stopped = obs_media_state_t.OBS_MEDIA_STATE_STOPPED,
    Ended = obs_media_state_t.OBS_MEDIA_STATE_ENDED,
    Error = obs_media_state_t.OBS_MEDIA_STATE_ERROR,
}

/// UDA for source information
struct OBSSourceInfo {
    const(char)* id;
    const(char)* displayName;
    uint version_;
    OBSIconType iconType;
    OBSSourceType sourceType;
    uint flags;
}

struct OBSNoBind;

class OBSSource {
private:
    obs_data_t* data;
    
protected:
    obs_source_t* source;

public:

    this(obs_data_t* data, obs_source_t* source) {
        this.source = source;
        this.data = data;
    }

    abstract uint getWidth();
    abstract uint getHeight();

    /**
        Called when the source has been activated in the main view.
    */
    void onActivated() {
    }

    /**
        Called when the source has been deactivated from the main view.
    */
    void onDeactivated() {
    }

    /**
        Called when the source is visible.
    */
    void onShown() {
    }

    /**
        Called when the source is no longer visible.
    */
    void onHidden() {
    }

    /**
	 * Called each video frame with the time elapsed
	 *
	 * @param  seconds  Seconds elapsed since the last frame
	 */
    void onVideoTick(float seconds) {
    }

    /**
	 * Called when rendering the source with the graphics subsystem.
	 *
	 * If this is an input/transition source, this is called to draw the
	 * source texture with the graphics subsystem using the specified
	 * effect.
	 *
	 * If this is a filter source, it wraps source draw calls (for
	 * example applying a custom effect with custom parameters to a
	 * source).  In this case, it's highly recommended to use the
	 * obs_source_process_filter function to automatically handle
	 * effect-based filter processing.  However, you can implement custom
	 * draw handling as desired as well.
	 *
	 * If the source output flags do not include SOURCE_CUSTOM_DRAW, all
	 * a source needs to do is set the "image" parameter of the effect to
	 * the desired texture, and then draw.  If the output flags include
	 * SOURCE_COLOR_MATRIX, you may optionally set the "color_matrix"
	 * parameter of the effect to a custom 4x4 conversion matrix (by
	 * default it will be set to an YUV->RGB conversion matrix)
	 *
	 * @param effect  Effect to be used with this source.  If the source
	 *                output flags include SOURCE_CUSTOM_DRAW, this will
	 *                be NULL, and the source is expected to process with
	 *                an effect manually.
	 */
    void onVideoRender(gs_effect_t* effect) {
    }

    /**
	 * Called when saving a source.  This is a separate function because
	 * sometimes a source needs to know when it is being saved so it
	 * doesn't always have to update the current settings until a certain
	 * point.
	 *
	 * @param  settings  Settings
	 */
    void onSave(obs_data_t* settings) {

    }

    /**
	 * Called when loading a source from saved data.  This should be called
	 * after all the loading sources have actually been created because
	 * sometimes there are sources that depend on each other.
	 *
	 * @param  settings  Settings
	 */
    void onLoad(obs_data_t* settings) {

    }

final:
    /** Returns the current 'hidden' state on the source */
    bool hidden() {
        return obs_source_is_hidden(source);
    }

    /** The 'hidden' flag is not the same as a sceneitem's visibility. It is a
    * property the determines if it can be found through searches. **/
    /** Simply sets a 'hidden' flag when the source is still alive but shouldn't be found */
    bool hidden(bool value) {
        obs_source_set_hidden(source, value);
        return hidden();
    }

    /** Returns capability flags of a source */
    uint outputFlags() {
        return obs_source_get_output_flags(source);
    }

    /** Returns whether the source has custom properties or not */
    bool isConfigurable() {
        return obs_source_configurable(source);
    }

    /**
    * Returns the properties list for a specific existing source.  Free with
    * obs_properties_destroy
    */
    obs_properties_t* properties() {
        return obs_source_properties(source);
    }

    /** Returns the ID of this source */
    const(char)* id() {
        return obs_source_get_id(source);
    }

    /** Gets the name of a source */
    const(char)* name() {
        return obs_source_get_name(source);
    }

    /** Gets the name of a source */
    const(char)* name(const(char)* value) {
        obs_source_set_name(source, value);
        return value;
    }

    /** Gets the source type */
    OBSSourceType type() {
        return cast(OBSSourceType) obs_source_get_type(source);
    }

    /** Gets the user volume for a source that has audio output */
    float volume() {
        return obs_source_get_volume(source);
    }

    /** Sets the user volume for a source that has audio output */
    float volume(float value) {
        obs_source_set_volume(source, value);
        return value;
    }

    /** Returns true if active, false if not */
    bool isActive() {
        return obs_source_active(source);
    }

    /**
    * Returns true if currently displayed somewhere (active or not), false if not
    */
    bool isShowing() {
        return obs_source_showing(source);
    }

    /** Gets source flags. */
    uint flags() {
        return obs_source_get_flags(source);
    }

    /**
    * Sets source flags.  Note that these are different from the main output
    * flags.  These are generally things that can be set by the source or user,
    * while the output flags are more used to determine capabilities of a source.
    */
    uint flags(uint value) {
        obs_source_set_flags(source, value);
        return value;
    }

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
    void drawSetColorMatrix(const mat4* colorMatrix, const(vec3)* rangeMin, const(vec3)* rangeMax) {
        obs_source_draw_set_color_matrix(colorMatrix, rangeMin, rangeMax);
    }
    
    /**
    * Outputs asynchronous video data.  Set to NULL to deactivate the texture
    *
    * NOTE: Non-YUV formats will always be treated as full range with this
    * function!  Use obs_source_output_video2 instead if partial range support is
    * desired for non-YUV video formats.
    */
    void outputVideo(const(obs_source_frame_t)* frame) {
        obs_source_output_video(source, frame);
    }
    
    /**
    * Outputs asynchronous video data.  Set to NULL to deactivate the texture
    *
    * NOTE: Non-YUV formats will always be treated as full range with this
    * function!  Use obs_source_output_video2 instead if partial range support is
    * desired for non-YUV video formats.
    */
    void outputVideo(const(obs_source_frame2_t)* frame) {
        obs_source_output_video2(source, frame);
    }
    
    /**
    * Preloads asynchronous video data to allow instantaneous playback
    *
    * NOTE: Non-YUV formats will always be treated as full range with this
    * function!  Use obs_source_preload_video2 instead if partial range support is
    * desired for non-YUV video formats.
    */
    void preloadVideo(const(obs_source_frame_t)* frame) {
        obs_source_preload_video(source, frame);
    }
    
    /**
    * Preloads asynchronous video data to allow instantaneous playback
    *
    * NOTE: Non-YUV formats will always be treated as full range with this
    * function!  Use obs_source_preload_video2 instead if partial range support is
    * desired for non-YUV video formats.
    */
    void preloadVideo(const(obs_source_frame2_t)* frame) {
        obs_source_preload_video2(source, frame);
    }

    /** Shows any preloaded video data */
    void showPreloadedVideo() {
        obs_source_show_preloaded_video(source);
    }
    
    /**
    * Sets current async video frame immediately
    *
    * NOTE: Non-YUV formats will always be treated as full range with this
    * function!  Use obs_source_preload_video2 instead if partial range support is
    * desired for non-YUV video formats.
    */
    void setVideoFrame(const(obs_source_frame_t)* frame) {
        obs_source_set_video_frame(source, frame);
    }
    
    /**
    * Sets current async video frame immediately
    *
    * NOTE: Non-YUV formats will always be treated as full range with this
    * function!  Use obs_source_preload_video2 instead if partial range support is
    * desired for non-YUV video formats.
    */
    void setVideoFrame(const(obs_source_frame2_t)* frame) {
        obs_source_set_video_frame2(source, frame);
    }
    
    /**
    * Sets current async video frame immediately
    *
    * NOTE: Non-YUV formats will always be treated as full range with this
    * function!  Use obs_source_preload_video2 instead if partial range support is
    * desired for non-YUV video formats.
    */
    void outputAudio(const(obs_source_audio_t)* frame) {
        obs_source_output_audio(source, frame);
    }
    
    /** Signal an update to any currently used properties via 'update_properties' */
    void updateProperties() {
        obs_source_update_properties(source);
    }

    /** Gets the current async video frame */
    obs_source_frame_t* getFrame() {
        return obs_source_get_frame(source);
    }

    /** Releases the current async video frame */
    void releaseFrame(obs_source_frame_t* frame) {
        obs_source_release_frame(source, frame);
    }

    void draw(gs_texture_t* tex, rect area, bool flip) {
        obs_source_draw(tex, cast(int)area.x, cast(int)area.y, cast(int)area.width, cast(int)area.height, flip);
    }
}

obs_source_info_t createSourceInfoFor(T)() if (is(T : OBSSource)) {
    obs_source_info_t info;
    const OBSSourceInfo sourceInfo = getUDAs!(T, OBSSourceInfo)[0];

    info.id = sourceInfo.id;
    info.version_ = sourceInfo.version_;
    info.icon_type = cast(obs_icon_type_t) sourceInfo.iconType;
    info.type = cast(obs_source_type_t) sourceInfo.sourceType;
    info.output_flags = sourceInfo.flags;

    info.create = function(obs_data_t* settings, obs_source_t* source) {
        import core.memory : GC;

        OBSSource src = new T(settings, source);
        GC.addRoot(cast(void*) src);

        return cast(void*) src;
    };

    info.destroy = (void* data) { 
        import core.memory : GC;

        destroy!false(cast(T)data);
        GC.removeRoot(data); 
    };

    info.get_width = (void* data) { return (cast(OBSSource) data).getWidth(); };

    info.get_height = (void* data) { return (cast(OBSSource) data).getHeight(); };

    info.activate = (void* data) { (cast(OBSSource) data).onActivated(); };

    info.deactivate = (void* data) { (cast(OBSSource) data).onDeactivated(); };

    info.show = (void* data) { (cast(OBSSource) data).onShown(); };

    info.hide = (void* data) { (cast(OBSSource) data).onHidden(); };

    static if (!hasUDA!(T.onVideoTick, OBSNoBind)) {
        info.video_tick = (void* data, float seconds) {
            (cast(OBSSource) data).onVideoTick(seconds);
        };
    }

    static if (!hasUDA!(T.onVideoRender, OBSNoBind)) {
        info.video_render = (void* data, gs_effect_t* effect) {
            (cast(OBSSource) data).onVideoRender(effect);
        };
    }

    info.save = (void* data, obs_data_t* settings) {
        (cast(OBSSource) data).onSave(settings);
    };

    info.load = (void* data, obs_data_t* settings) {
        (cast(OBSSource) data).onLoad(settings);
    };

    info.get_name = function(void* data) {
        return getUDAs!(T, OBSSourceInfo)[0].displayName;
    };

    return info;
}
