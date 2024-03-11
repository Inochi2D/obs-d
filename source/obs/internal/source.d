module obs.internal.source;
import obs.internal.obs;
import obs.internal.mediaio.audio;
import obs.internal.mediaio.video;
import obs.internal.data;
import obs.internal.properties;
import obs.internal.graphics;

extern (C):

enum obs_source_type_t {
	OBS_SOURCE_TYPE_INPUT,
	OBS_SOURCE_TYPE_FILTER,
	OBS_SOURCE_TYPE_TRANSITION,
	OBS_SOURCE_TYPE_SCENE,
}

enum obs_balance_type_t {
	OBS_BALANCE_TYPE_SINE_LAW,
	OBS_BALANCE_TYPE_SQUARE_LAW,
	OBS_BALANCE_TYPE_LINEAR,
}

enum obs_icon_type_t {
	OBS_ICON_TYPE_UNKNOWN,
	OBS_ICON_TYPE_IMAGE,
	OBS_ICON_TYPE_COLOR,
	OBS_ICON_TYPE_SLIDESHOW,
	OBS_ICON_TYPE_AUDIO_INPUT,
	OBS_ICON_TYPE_AUDIO_OUTPUT,
	OBS_ICON_TYPE_DESKTOP_CAPTURE,
	OBS_ICON_TYPE_WINDOW_CAPTURE,
	OBS_ICON_TYPE_GAME_CAPTURE,
	OBS_ICON_TYPE_CAMERA,
	OBS_ICON_TYPE_TEXT,
	OBS_ICON_TYPE_MEDIA,
	OBS_ICON_TYPE_BROWSER,
	OBS_ICON_TYPE_CUSTOM,
	OBS_ICON_TYPE_PROCESS_AUDIO_OUTPUT,
}

enum obs_media_state_t {
	OBS_MEDIA_STATE_NONE,
	OBS_MEDIA_STATE_PLAYING,
	OBS_MEDIA_STATE_OPENING,
	OBS_MEDIA_STATE_BUFFERING,
	OBS_MEDIA_STATE_PAUSED,
	OBS_MEDIA_STATE_STOPPED,
	OBS_MEDIA_STATE_ENDED,
	OBS_MEDIA_STATE_ERROR,
}

/**
 * @name Source output flags
 *
 * These flags determine what type of data the source outputs and expects.
 * @{
 */

/**
 * Source has video.
 *
 * Unless SOURCE_ASYNC_VIDEO is specified, the source must include the
 * video_render callback in the source definition structure.
 */
enum OBS_SOURCE_VIDEO = (1 << 0);

/**
 * Source has audio.
 *
 * Use the obs_source_output_audio function to pass raw audio data, which will
 * be automatically converted and uploaded.  If used with SOURCE_ASYNC_VIDEO,
 * audio will automatically be synced up to the video output.
 */
enum OBS_SOURCE_AUDIO = (1 << 1);

/** Async video flag (use OBS_SOURCE_ASYNC_VIDEO) */
enum OBS_SOURCE_ASYNC = (1 << 2);

/**
 * Source passes raw video data via RAM.
 *
 * Use the obs_source_output_video function to pass raw video data, which will
 * be automatically uploaded at the specified timestamp.
 *
 * If this flag is specified, it is not necessary to include the video_render
 * callback.  However, if you wish to use that function as well, you must call
 * obs_source_getframe to get the current frame data, and
 * obs_source_releaseframe to release the data when complete.
 */
enum OBS_SOURCE_ASYNC_VIDEO = (OBS_SOURCE_ASYNC | OBS_SOURCE_VIDEO);

/**
 * Source uses custom drawing, rather than a default effect.
 *
 * If this flag is specified, the video_render callback will pass a NULL
 * effect, and effect-based filters will not use direct rendering.
 */
enum OBS_SOURCE_CUSTOM_DRAW = (1 << 3);

/**
 * Source supports interaction.
 *
 * When this is used, the source will receive interaction events
 * if they provide the necessary callbacks in the source definition structure.
 */
enum OBS_SOURCE_INTERACTION = (1 << 5);

/**
 * Source composites sub-sources
 *
 * When used specifies that the source composites one or more sub-sources.
 * Sources that render sub-sources must implement the audio_render callback
 * in order to perform custom mixing of sub-sources.
 *
 * This capability flag is always set for transitions.
 */
enum OBS_SOURCE_COMPOSITE = (1 << 6);

/**
 * Source should not be fully duplicated
 *
 * When this is used, specifies that the source should not be fully duplicated,
 * and should prefer to duplicate via holding references rather than full
 * duplication.
 */
enum OBS_SOURCE_DO_NOT_DUPLICATE = (1 << 7);

/**
 * Source is deprecated and should not be used
 */
enum OBS_SOURCE_DEPRECATED = (1 << 8);

/**
 * Source cannot have its audio monitored
 *
 * Specifies that this source may cause a feedback loop if audio is monitored
 * with a device selected as desktop audio.
 *
 * This is used primarily with desktop audio capture sources.
 */
enum OBS_SOURCE_DO_NOT_SELF_MONITOR = (1 << 9);

/**
 * Source type is currently disabled and should not be shown to the user
 */
enum OBS_SOURCE_CAP_DISABLED = (1 << 10);

/**
 * Source type is obsolete (has been updated with new defaults/properties/etc)
 */
enum OBS_SOURCE_CAP_OBSOLETE = OBS_SOURCE_CAP_DISABLED;

/**
 * Source should enable monitoring by default.  Monitoring should be set by the
 * frontend if this flag is set.
 */
enum OBS_SOURCE_MONITOR_BY_DEFAULT = (1 << 11);

/** Used internally for audio submixing */
enum OBS_SOURCE_SUBMIX = (1 << 12);

/**
 * Source type can be controlled by media controls
 */
enum OBS_SOURCE_CONTROLLABLE_MEDIA = (1 << 13);

/**
 * Source type provides cea708 data
 */
enum OBS_SOURCE_CEA_708 = (1 << 14);

/**
 * Source understands SRGB rendering
 */
enum OBS_SOURCE_SRGB = (1 << 15);

/**
 * Source type prefers not to have its properties shown on creation
 * (prefers to rely on defaults first)
 */
enum OBS_SOURCE_CAP_DONT_SHOW_PROPERTIES = (1 << 16);

/** @} */

alias obs_source_enum_proc_t = void function(obs_source_t* parent, obs_source_t* child, void* param);

struct obs_source_audio_mix_t {
	audio_output_data_t[MAX_AUDIO_MIXES] output;
}

/**
 * Source definition structure
 */
struct obs_source_info_t {
	/* ----------------------------------------------------------------- */
	/* Required implementation*/

	/** Unique string identifier for the source */
	const(char)* id;

	/**
	 * Type of source.
	 *
	 * OBS_SOURCE_TYPE_INPUT for input sources,
	 * OBS_SOURCE_TYPE_FILTER for filter sources, and
	 * OBS_SOURCE_TYPE_TRANSITION for transition sources.
	 */
	obs_source_type_t type;

	/** Source output flags */
	uint output_flags;

	/**
	 * Get the translated name of the source type
	 *
	 * @param  type_data  The type_data variable of this structure
	 * @return               The translated name of the source type
	 */
	const(char)* function(void* type_data) get_name;

	/**
	 * Creates the source data for the source
	 *
	 * @param  settings  Settings to initialize the source with
	 * @param  source    Source that this data is associated with
	 * @return           The data associated with this source
	 */
	void* function(obs_data_t* settings, obs_source_t* source) create;

	/**
	 * Destroys the private data for the source
	 *
	 * Async sources must not call obs_source_output_video after returning
	 * from destroy
	 */
	void function(void* data) destroy;

	/** Returns the width of the source.  Required if this is an input
	 * source and has non-async video */
	uint function(void* data) get_width;

	/** Returns the height of the source.  Required if this is an input
	 * source and has non-async video */
	uint function(void* data) get_height;

	/* ----------------------------------------------------------------- */
	/* Optional implementation */

	/**
	 * Gets the default settings for this source
	 *
	 * @param[out]  settings  Data to assign default settings to
	 * @deprecated            Use get_defaults2 if type_data is needed
	 */
	void function(obs_data_t* settings) get_defaults;

	/**
	 * Gets the property information of this source
	 *
	 * @return         The properties data
	 * @deprecated     Use get_properties2 if type_data is needed
	 */
	obs_properties_t* function(void* data) get_properties;

	/**
	 * Updates the settings for this source
	 *
	 * @param data      Source data
	 * @param settings  New settings for this source
	 */
	void function(void* data, obs_data_t* settings) update;

	/** Called when the source has been activated in the main view */
	void function(void* data) activate;

	/**
	 * Called when the source has been deactivated from the main view
	 * (no longer being played/displayed)
	 */
	void function(void* data) deactivate;

	/** Called when the source is visible */
	void function(void* data) show;

	/** Called when the source is no longer visible */
	void function(void* data) hide;

	/**
	 * Called each video frame with the time elapsed
	 *
	 * @param  data     Source data
	 * @param  seconds  Seconds elapsed since the last frame
	 */
	void function(void* data, float seconds) video_tick;

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
	 * @param data    Source data
	 * @param effect  Effect to be used with this source.  If the source
	 *                output flags include SOURCE_CUSTOM_DRAW, this will
	 *                be NULL, and the source is expected to process with
	 *                an effect manually.
	 */
	void function(void* data, gs_effect_t* effect) video_render;

	/**
	 * Called to filter raw async video data.
	 *
	 * @note          This function is only used with filter sources.
	 *
	 * @param  data   Filter data
	 * @param  frame  Video frame to filter
	 * @return        New video frame data.  This can defer video data to
	 *                be drawn later if time is needed for processing
	 */
	obs_source_frame_t* function(void* data, obs_source_frame_t* frame) filter_video;

	/**
	 * Called to filter raw audio data.
	 *
	 * @note          This function is only used with filter sources.
	 *
	 * @param  data   Filter data
	 * @param  audio  Audio data to filter.
	 * @return        Modified or new audio data.  You can directly modify
	 *                the data passed and return it, or you can defer audio
	 *                data for later if time is needed for processing.  If
	 *                you are returning new data, that data must exist
	 *                until the next call to the filter_audio callback or
	 *                until the filter is removed/destroyed.
	 */
	obs_audio_data_t* function(void* data, obs_audio_data_t* audio) filter_audio;

	/**
	 * Called to enumerate all active sources being used within this
	 * source.  If the source has children that render audio/video it must
	 * implement this callback.
	 *
	 * @param  data           Filter data
	 * @param  enum_callback  Enumeration callback
	 * @param  param          User data to pass to callback
	 */
	void function(void* data, obs_source_enum_proc_t enum_callback, void* param) enum_active_sources;

	/**
	 * Called when saving a source.  This is a separate function because
	 * sometimes a source needs to know when it is being saved so it
	 * doesn't always have to update the current settings until a certain
	 * point.
	 *
	 * @param  data      Source data
	 * @param  settings  Settings
	 */
	void function(void* data, obs_data_t* settings) save;

	/**
	 * Called when loading a source from saved data.  This should be called
	 * after all the loading sources have actually been created because
	 * sometimes there are sources that depend on each other.
	 *
	 * @param  data      Source data
	 * @param  settings  Settings
	 */
	void function(void* data, obs_data_t* settings) load;

	/**
	 * Called when interacting with a source and a mouse-down or mouse-up
	 * occurs.
	 *
	 * @param data         Source data
	 * @param event        Mouse event properties
	 * @param type         Mouse button pushed
	 * @param mouse_up     Mouse event type (true if mouse-up)
	 * @param click_count  Mouse click count (1 for single click, etc.)
	 */
	void function(void* data, const(obs_mouse_event_t)* event,
		int type, bool mouse_up, uint click_count) mouse_click;
	/**
	 * Called when interacting with a source and a mouse-move occurs.
	 *
	 * @param data         Source data
	 * @param event        Mouse event properties
	 * @param mouse_leave  Mouse leave state (true if mouse left source)
	 */
	void function(void* data, const(obs_mouse_event_t)* event,
		bool mouse_leave) mouse_move;

	/**
	 * Called when interacting with a source and a mouse-wheel occurs.
	 *
	 * @param data         Source data
	 * @param event        Mouse event properties
	 * @param x_delta      Movement delta in the horizontal direction
	 * @param y_delta      Movement delta in the vertical direction
	 */
	void function(void* data, const(obs_mouse_event_t)* event,
		int x_delta, int y_delta) mouse_wheel;
	/**
	 * Called when interacting with a source and gain focus/lost focus event
	 * occurs.
	 *
	 * @param data         Source data
	 * @param focus        Focus state (true if focus gained)
	 */
	void function(void* data, bool focus) focus;

	/**
	 * Called when interacting with a source and a key-up or key-down
	 * occurs.
	 *
	 * @param data         Source data
	 * @param event        Key event properties
	 * @param focus        Key event type (true if mouse-up)
	 */
	void function(void* data, const(obs_key_event_t)* event,
		bool key_up) key_click;

	/**
	 * Called when the filter is removed from a source
	 *
	 * @param  data    Filter data
	 * @param  source  Source that the filter being removed from
	 */
	void function(void* data, obs_source_t* source) filter_remove;

	/**
	 * Private data associated with this entry
	 */
	void* type_data;

	/**
	 * If defined, called to free private data on shutdown
	 */
	void function(void* type_data) free_type_data;

	bool function(void* data, ulong* ts_out,
		obs_source_audio_mix_t* audio_output,
		uint mixers, size_t channels,
		size_t sample_rate) audio_render;

	/**
	 * Called to enumerate all active and inactive sources being used
	 * within this source.  If this callback isn't implemented,
	 * enum_active_sources will be called instead.
	 *
	 * This is typically used if a source can have inactive child sources.
	 *
	 * @param  data           Filter data
	 * @param  enum_callback  Enumeration callback
	 * @param  param          User data to pass to callback
	 */
	void function(void* data,
		obs_source_enum_proc_t enum_callback,
		void* param) enum_all_sources;

	void function(void* data) transition_start;
	void function(void* data) transition_stop;

	/**
	 * Gets the default settings for this source
	 *
	 * If get_defaults is also defined both will be called, and the first
	 * call will be to get_defaults, then to get_defaults2.
	 *
	 * @param       type_data The type_data variable of this structure
	 * @param[out]  settings  Data to assign default settings to
	 */
	void function(void* type_data, obs_data_t* settings) get_defaults2;

	/**
	 * Gets the property information of this source
	 *
	 * @param data      Source data
	 * @param type_data The type_data variable of this structure
	 * @return          The properties data
	 */
	obs_properties_t* function(void* data, void* type_data) get_properties2;

	bool function(void* data, ulong* ts_out,
		audio_output_data_t* audio_output,
		size_t channels, size_t sample_rate) audio_mix;

	/** Icon type for the source */
	obs_icon_type_t icon_type;

	/** Media controls */
	void function(void* data, bool pause) media_play_pause;
	void function(void* data) media_restart;
	void function(void* data) media_stop;
	void function(void* data) media_next;
	void function(void* data) media_previous;
	long function(void* data) media_get_duration;
	long function(void* data) media_get_time;
	void function(void* data, long miliseconds) media_set_time;
	obs_media_state_t function(void* data) media_get_state;

	/* version-related stuff */
	uint version_; /* increment if needed to specify a new version */
	const(char)* unversioned_id; /* set internally, don't set manually */

	/** Missing files **/
	obs_missing_files_t* function(void* data) missing_files;

	/** Get color space **/
	gs_color_space_t function(
		void* data, size_t count,
		const(gs_color_space_t)* preferred_spaces) video_get_color_space;

	/**
	 * Called when the filter is added to a source
	 *
	 * @param  data    Filter data
	 * @param  source  Source that the filter is being added to
	 */
	void function(void* data, obs_source_t* source) filter_add;
}

export void obs_register_source_s(const(obs_source_info_t)* info, size_t size);

/**
 * Registers a source definition to the current obs context.  This should be
 * used in obs_module_load.
 *
 * @param  info  Pointer to the source definition structure
 */
void obs_register_source(const(obs_source_info_t)* info) {
	obs_register_source_s(info, obs_source_info_t.sizeof);
}
