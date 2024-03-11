module obs.internal.properties;
import obs.internal.mediaio;
import obs.internal.data;

/** Only update when the user presses OK or Apply */
enum OBS_PROPERTIES_DEFER_UPDATE = (1 << 0);

enum obs_property_type_t {
	OBS_PROPERTY_INVALID,
	OBS_PROPERTY_BOOL,
	OBS_PROPERTY_INT,
	OBS_PROPERTY_FLOAT,
	OBS_PROPERTY_TEXT,
	OBS_PROPERTY_PATH,
	OBS_PROPERTY_LIST,
	OBS_PROPERTY_COLOR,
	OBS_PROPERTY_BUTTON,
	OBS_PROPERTY_FONT,
	OBS_PROPERTY_EDITABLE_LIST,
	OBS_PROPERTY_FRAME_RATE,
	OBS_PROPERTY_GROUP,
	OBS_PROPERTY_COLOR_ALPHA,
}

enum obs_combo_format_t {
	OBS_COMBO_FORMAT_INVALID,
	OBS_COMBO_FORMAT_INT,
	OBS_COMBO_FORMAT_FLOAT,
	OBS_COMBO_FORMAT_STRING,
	OBS_COMBO_FORMAT_BOOL,
}

enum obs_combo_type_t {
	OBS_COMBO_TYPE_INVALID,
	OBS_COMBO_TYPE_EDITABLE,
	OBS_COMBO_TYPE_LIST,
	OBS_COMBO_TYPE_RADIO,
}

enum obs_editable_list_type_t {
	OBS_EDITABLE_LIST_TYPE_STRINGS,
	OBS_EDITABLE_LIST_TYPE_FILES,
	OBS_EDITABLE_LIST_TYPE_FILES_AND_URLS,
}

enum obs_path_type_t {
	OBS_PATH_FILE,
	OBS_PATH_FILE_SAVE,
	OBS_PATH_DIRECTORY,
}

enum obs_text_type_t {
	OBS_TEXT_DEFAULT,
	OBS_TEXT_PASSWORD,
	OBS_TEXT_MULTILINE,
	OBS_TEXT_INFO,
}

enum obs_text_info_type_t {
	OBS_TEXT_INFO_NORMAL,
	OBS_TEXT_INFO_WARNING,
	OBS_TEXT_INFO_ERROR,
}

enum obs_number_type_t {
	OBS_NUMBER_SCROLLER,
	OBS_NUMBER_SLIDER,
}

enum obs_group_type_t {
	OBS_COMBO_INVALID,
	OBS_GROUP_NORMAL,
	OBS_GROUP_CHECKABLE,
}

enum obs_button_type_t {
	OBS_BUTTON_DEFAULT,
	OBS_BUTTON_URL,
}

enum OBS_FONT_BOLD      = (1 << 0);
enum OBS_FONT_ITALIC    = (1 << 1);
enum OBS_FONT_UNDERLINE = (1 << 2);
enum OBS_FONT_STRIKEOUT = (1 << 3);

struct obs_properties_t;
struct obs_property_t;

/* ------------------------------------------------------------------------- */

export obs_properties_t *obs_properties_create();
export obs_properties_t *
obs_properties_create_param(void *param, void function(void *param) destroy);
export void obs_properties_destroy(obs_properties_t *props);

export void obs_properties_set_flags(obs_properties_t *props, uint flags);
export uint obs_properties_get_flags(obs_properties_t *props);

export void obs_properties_set_param(obs_properties_t *props, void *param,
				     void function(void *param) destroy);
export void *obs_properties_get_param(obs_properties_t *props);

export obs_property_t *obs_properties_first(obs_properties_t *props);

export obs_property_t *obs_properties_get(obs_properties_t *props,
					  const(char)* property);

export obs_properties_t *obs_properties_get_parent(obs_properties_t *props);

/** Remove a property from a properties list.
 *
 * Removes a property from a properties list. Only valid in either
 * get_properties or modified_callback(2). modified_callback(2) must return
 * true so that all UI properties are rebuilt and returning false is undefined
 * behavior.
 *
 * @param props Properties to remove from.
 * @param property Name of the property to remove.
 */
export void obs_properties_remove_by_name(obs_properties_t *props,
					  const(char)* property);

/**
 * Applies settings to the properties by calling all the necessary
 * modification callbacks
 */
export void obs_properties_apply_settings(obs_properties_t *props,
					  obs_data_t *settings);

/* ------------------------------------------------------------------------- */

/**
 * Callback for when a button property is clicked.  If the properties
 * need to be refreshed due to changes to the property layout, return true,
 * otherwise return false.
 */
alias obs_property_clicked_t = bool function(obs_properties_t *props,
				       obs_property_t *property, void *data);

export obs_property_t *obs_properties_add_bool(obs_properties_t *props,
					       const(char)* name,
					       const(char)* description);

export obs_property_t *obs_properties_add_int(obs_properties_t *props,
					      const(char)* name,
					      const(char)* description, int min,
					      int max, int step);

export obs_property_t *obs_properties_add_float(obs_properties_t *props,
						const(char)* name,
						const(char)* description,
						double min, double max,
						double step);

export obs_property_t *obs_properties_add_int_slider(obs_properties_t *props,
						     const(char)* name,
						     const(char)* description,
						     int min, int max,
						     int step);

export obs_property_t *obs_properties_add_float_slider(obs_properties_t *props,
						       const(char)* name,
						       const(char)* description,
						       double min, double max,
						       double step);

export obs_property_t *obs_properties_add_text(obs_properties_t *props,
					       const(char)* name,
					       const(char)* description,
					       obs_text_type_t type);

/**
 * Adds a 'path' property.  Can be a directory or a file.
 *
 * If target is a file path, the filters should be this format, separated by
 * double semicolons, and extensions separated by space:
 *   "Example types 1 and 2 (*.ex1 *.ex2);;Example type 3 (*.ex3)"
 *
 * @param  props        Properties object
 * @param  name         Settings name
 * @param  description  Description (display name) of the property
 * @param  type         Type of path (directory or file)
 * @param  filter       If type is a file path, then describes the file filter
 *                      that the user can browse.  Items are separated via
 *                      double semicolons.  If multiple file types in a
 *                      filter, separate with space.
 */
export obs_property_t *
obs_properties_add_path(obs_properties_t *props, const(char)* name,
			const(char)* description, obs_path_type_t type,
			const(char)* filter, const(char)* default_path);

export obs_property_t *obs_properties_add_list(obs_properties_t *props,
					       const(char)* name,
					       const(char)* description,
					       obs_combo_type_t type,
					       obs_combo_format_t format);

export obs_property_t *obs_properties_add_color(obs_properties_t *props,
						const(char)* name,
						const(char)* description);

export obs_property_t *obs_properties_add_color_alpha(obs_properties_t *props,
						      const(char)* name,
						      const(char)* description);

export obs_property_t *
obs_properties_add_button(obs_properties_t *props, const(char)* name,
			  const(char)* text, obs_property_clicked_t callback);

export obs_property_t *
obs_properties_add_button2(obs_properties_t *props, const(char)* name,
			   const(char)* text, obs_property_clicked_t callback,
			   void *priv);

/**
 * Adds a font selection property.
 *
 * A font is an obs_data sub-object which contains the following items:
 *   face:   face name string
 *   style:  style name string
 *   size:   size integer
 *   flags:  font flags integer (OBS_FONT_* defined above)
 */
export obs_property_t *obs_properties_add_font(obs_properties_t *props,
					       const(char)* name,
					       const(char)* description);

export obs_property_t *
obs_properties_add_editable_list(obs_properties_t *props, const(char)* name,
				 const(char)* description,
				  obs_editable_list_type_t type,
				 const(char)* filter, const(char)* default_path);

export obs_property_t *obs_properties_add_frame_rate(obs_properties_t *props,
						     const(char)* name,
						     const(char)* description);

export obs_property_t *obs_properties_add_group(obs_properties_t *props,
						const(char)* name,
						const(char)* description,
						obs_group_type_t type,
						obs_properties_t *group);

/* ------------------------------------------------------------------------- */

/**
 * Optional callback for when a property is modified.  If the properties
 * need to be refreshed due to changes to the property layout, return true,
 * otherwise return false.
 */
alias obs_property_modified_t = bool function(obs_properties_t *props,
					obs_property_t *property,
					obs_data_t *settings);
alias obs_property_modified2_t = bool function(void *priv, obs_properties_t *props,
					 obs_property_t *property,
					 obs_data_t *settings);

export void
obs_property_set_modified_callback(obs_property_t *p,
				   obs_property_modified_t modified);
export void obs_property_set_modified_callback2(
	obs_property_t *p, obs_property_modified2_t modified, void *priv);

export bool obs_property_modified(obs_property_t *p, obs_data_t *settings);
export bool obs_property_button_clicked(obs_property_t *p, void *obj);

export void obs_property_set_visible(obs_property_t *p, bool visible);
export void obs_property_set_enabled(obs_property_t *p, bool enabled);

export void obs_property_set_description(obs_property_t *p,
					 const(char)* description);
export void obs_property_set_long_description(obs_property_t *p,
					      const(char)* long_description);

export const(char)* obs_property_name(obs_property_t *p);
export const(char)* obs_property_description(obs_property_t *p);
export const(char)* obs_property_long_description(obs_property_t *p);
export obs_property_type_t obs_property_get_type(obs_property_t *p);
export bool obs_property_enabled(obs_property_t *p);
export bool obs_property_visible(obs_property_t *p);

export bool obs_property_next(obs_property_t **p);

export int obs_property_int_min(obs_property_t *p);
export int obs_property_int_max(obs_property_t *p);
export int obs_property_int_step(obs_property_t *p);
export obs_number_type_t obs_property_int_type(obs_property_t *p);
export const(char)* obs_property_int_suffix(obs_property_t *p);
export double obs_property_float_min(obs_property_t *p);
export double obs_property_float_max(obs_property_t *p);
export double obs_property_float_step(obs_property_t *p);
export obs_number_type_t obs_property_float_type(obs_property_t *p);
export const(char)* obs_property_float_suffix(obs_property_t *p);
export obs_text_type_t obs_property_text_type(obs_property_t *p);
export bool obs_property_text_monospace(obs_property_t *p);
export obs_text_info_type_t obs_property_text_info_type(obs_property_t *p);
export bool obs_property_text_info_word_wrap(obs_property_t *p);
export obs_path_type_t obs_property_path_type(obs_property_t *p);
export const(char)* obs_property_path_filter(obs_property_t *p);
export const(char)* obs_property_path_default_path(obs_property_t *p);
export obs_combo_type_t obs_property_list_type(obs_property_t *p);
export obs_combo_format_t obs_property_list_format(obs_property_t *p);

export void obs_property_int_set_limits(obs_property_t *p, int min, int max,
					int step);
export void obs_property_float_set_limits(obs_property_t *p, double min,
					  double max, double step);
export void obs_property_int_set_suffix(obs_property_t *p, const(char)* suffix);
export void obs_property_float_set_suffix(obs_property_t *p,
					  const(char)* suffix);
export void obs_property_text_set_monospace(obs_property_t *p, bool monospace);
export void obs_property_text_set_info_type(obs_property_t *p,
					    obs_text_info_type_t type);
export void obs_property_text_set_info_word_wrap(obs_property_t *p,
						 bool word_wrap);

export void obs_property_button_set_type(obs_property_t *p,
					 obs_button_type_t type);
export void obs_property_button_set_url(obs_property_t *p, char *url);

export void obs_property_list_clear(obs_property_t *p);

export size_t obs_property_list_add_string(obs_property_t *p, const(char)* name,
					   const(char)* val);
export size_t obs_property_list_add_int(obs_property_t *p, const(char)* name,
					long val);
export size_t obs_property_list_add_float(obs_property_t *p, const(char)* name,
					  double val);
export size_t obs_property_list_add_bool(obs_property_t *p, const(char)* name,
					 bool val);

export void obs_property_list_insert_string(obs_property_t *p, size_t idx,
					    const(char)* name, const(char)* val);
export void obs_property_list_insert_int(obs_property_t *p, size_t idx,
					 const(char)* name, long val);
export void obs_property_list_insert_float(obs_property_t *p, size_t idx,
					   const(char)* name, double val);
export void obs_property_list_insert_bool(obs_property_t *p, size_t idx,
					  const(char)* name, bool val);

export void obs_property_list_item_disable(obs_property_t *p, size_t idx,
					   bool disabled);
export bool obs_property_list_item_disabled(obs_property_t *p, size_t idx);

export void obs_property_list_item_remove(obs_property_t *p, size_t idx);

export size_t obs_property_list_item_count(obs_property_t *p);
export const(char)* obs_property_list_item_name(obs_property_t *p, size_t idx);
export const(char)* obs_property_list_item_string(obs_property_t *p, size_t idx);
export long obs_property_list_item_int(obs_property_t *p, size_t idx);
export double obs_property_list_item_float(obs_property_t *p, size_t idx);
export bool obs_property_list_item_bool(obs_property_t *p, size_t idx);

export  obs_editable_list_type_t
obs_property_editable_list_type(obs_property_t *p);
export const(char)* obs_property_editable_list_filter(obs_property_t *p);
export const(char)* obs_property_editable_list_default_path(obs_property_t *p);

export void obs_property_frame_rate_clear(obs_property_t *p);
export void obs_property_frame_rate_options_clear(obs_property_t *p);
export void obs_property_frame_rate_fps_ranges_clear(obs_property_t *p);

export size_t obs_property_frame_rate_option_add(obs_property_t *p,
						 const(char)* name,
						 const(char)* description);
export size_t obs_property_frame_rate_fps_range_add(
	obs_property_t *p, media_frames_per_second_t min,
	media_frames_per_second_t max);

export void obs_property_frame_rate_option_insert(obs_property_t *p, size_t idx,
						  const(char)* name,
						  const(char)* description);
export void
obs_property_frame_rate_fps_range_insert(obs_property_t *p, size_t idx,
					 media_frames_per_second_t min,
					 media_frames_per_second_t max);

export size_t obs_property_frame_rate_options_count(obs_property_t *p);
export const(char)* obs_property_frame_rate_option_name(obs_property_t *p,
						       size_t idx);
export const(char)* obs_property_frame_rate_option_description(obs_property_t *p,
							      size_t idx);

export size_t obs_property_frame_rate_fps_ranges_count(obs_property_t *p);
export media_frames_per_second_t
obs_property_frame_rate_fps_range_min(obs_property_t *p, size_t idx);
export media_frames_per_second_t
obs_property_frame_rate_fps_range_max(obs_property_t *p, size_t idx);

export obs_group_type_t obs_property_group_type(obs_property_t *p);
export obs_properties_t *obs_property_group_content(obs_property_t *p);

export obs_button_type_t obs_property_button_type(obs_property_t *p);
export const(char)* obs_property_button_url(obs_property_t *p);
