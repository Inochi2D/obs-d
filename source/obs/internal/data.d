module obs.internal.data;
import inmath.linalg;
import obs.internal.mediaio;
extern(C):

struct obs_data_t;
struct obs_data_item_t;
struct obs_data_array_t;

enum obs_data_type_t {
	OBS_DATA_NULL,
	OBS_DATA_STRING,
	OBS_DATA_NUMBER,
	OBS_DATA_BOOLEAN,
	OBS_DATA_OBJECT,
	OBS_DATA_ARRAY
}

enum obs_data_number_type_t {
	OBS_DATA_NUM_INVALID,
	OBS_DATA_NUM_INT,
	OBS_DATA_NUM_DOUBLE
}

/* ------------------------------------------------------------------------- */
/* Main usage functions */

export obs_data_t *obs_data_create();
export obs_data_t *obs_data_create_from_json(const(char)* json_string);
export obs_data_t *obs_data_create_from_json_file(const(char)* json_file);
export obs_data_t *obs_data_create_from_json_file_safe(const(char)* json_file,
						       const(char)* backup_ext);
export void obs_data_addref(obs_data_t *data);
export void obs_data_release(obs_data_t *data);

export const(char)* obs_data_get_json(obs_data_t *data);
export const(char)* obs_data_get_json_pretty(obs_data_t *data);
export const(char)* obs_data_get_last_json(obs_data_t *data);
export bool obs_data_save_json(obs_data_t *data, const(char)* file);
export bool obs_data_save_json_safe(obs_data_t *data, const(char)* file,
				    const(char)* temp_ext,
				    const(char)* backup_ext);
export bool obs_data_save_json_pretty_safe(obs_data_t *data, const(char)* file,
					   const(char)* temp_ext,
					   const(char)* backup_ext);

export void obs_data_apply(obs_data_t *target, obs_data_t *apply_data);

export void obs_data_erase(obs_data_t *data, const(char)* name);
export void obs_data_clear(obs_data_t *data);

/* Set functions */
export void obs_data_set_string(obs_data_t *data, const(char)* name,
				const(char)* val);
export void obs_data_set_int(obs_data_t *data, const(char)* name, long val);
export void obs_data_set_double(obs_data_t *data, const(char)* name, double val);
export void obs_data_set_bool(obs_data_t *data, const(char)* name, bool val);
export void obs_data_set_obj(obs_data_t *data, const(char)* name,
			     obs_data_t *obj);
export void obs_data_set_array(obs_data_t *data, const(char)* name,
			       obs_data_array_t *array);

/*
 * Creates an obs_data_t * filled with all default values.
 */
export obs_data_t *obs_data_get_defaults(obs_data_t *data);

/*
 * Default value functions.
 */
export void obs_data_set_default_string(obs_data_t *data, const(char)* name,
					const(char)* val);
export void obs_data_set_default_int(obs_data_t *data, const(char)* name,
				     long val);
export void obs_data_set_default_double(obs_data_t *data, const(char)* name,
					double val);
export void obs_data_set_default_bool(obs_data_t *data, const(char)* name,
				      bool val);
export void obs_data_set_default_obj(obs_data_t *data, const(char)* name,
				     obs_data_t *obj);
export void obs_data_set_default_array(obs_data_t *data, const(char)* name,
				       obs_data_array_t *arr);

/*
 * Application overrides
 * Use these to communicate the actual values of settings in case the user
 * settings aren't appropriate
 */
export void obs_data_set_autoselect_string(obs_data_t *data, const(char)* name,
					   const(char)* val);
export void obs_data_set_autoselect_int(obs_data_t *data, const(char)* name,
					long val);
export void obs_data_set_autoselect_double(obs_data_t *data, const(char)* name,
					   double val);
export void obs_data_set_autoselect_bool(obs_data_t *data, const(char)* name,
					 bool val);
export void obs_data_set_autoselect_obj(obs_data_t *data, const(char)* name,
					obs_data_t *obj);
export void obs_data_set_autoselect_array(obs_data_t *data, const(char)* name,
					  obs_data_array_t *arr);

/*
 * Get functions
 */
export const(char)* obs_data_get_string(obs_data_t *data, const(char)* name);
export long obs_data_get_int(obs_data_t *data, const(char)* name);
export double obs_data_get_double(obs_data_t *data, const(char)* name);
export bool obs_data_get_bool(obs_data_t *data, const(char)* name);
export obs_data_t *obs_data_get_obj(obs_data_t *data, const(char)* name);
export obs_data_array_t *obs_data_get_array(obs_data_t *data, const(char)* name);

export const(char)* obs_data_get_default_string(obs_data_t *data,
					       const(char)* name);
export long obs_data_get_default_int(obs_data_t *data, const(char)* name);
export double obs_data_get_default_double(obs_data_t *data, const(char)* name);
export bool obs_data_get_default_bool(obs_data_t *data, const(char)* name);
export obs_data_t *obs_data_get_default_obj(obs_data_t *data, const(char)* name);
export obs_data_array_t *obs_data_get_default_array(obs_data_t *data,
						    const(char)* name);

export const(char)* obs_data_get_autoselect_string(obs_data_t *data,
						  const(char)* name);
export long obs_data_get_autoselect_int(obs_data_t *data,
					     const(char)* name);
export double obs_data_get_autoselect_double(obs_data_t *data,
					     const(char)* name);
export bool obs_data_get_autoselect_bool(obs_data_t *data, const(char)* name);
export obs_data_t *obs_data_get_autoselect_obj(obs_data_t *data,
					       const(char)* name);
export obs_data_array_t *obs_data_get_autoselect_array(obs_data_t *data,
						       const(char)* name);

/* Array functions */
export obs_data_array_t *obs_data_array_create();
export void obs_data_array_addref(obs_data_array_t *array);
export void obs_data_array_release(obs_data_array_t *array);

export size_t obs_data_array_count(obs_data_array_t *array);
export obs_data_t *obs_data_array_item(obs_data_array_t *array, size_t idx);
export size_t obs_data_array_push_back(obs_data_array_t *array,
				       obs_data_t *obj);
export void obs_data_array_insert(obs_data_array_t *array, size_t idx,
				  obs_data_t *obj);
export void obs_data_array_push_back_array(obs_data_array_t *array,
					   obs_data_array_t *array2);
export void obs_data_array_erase(obs_data_array_t *array, size_t idx);
export void obs_data_array_enum(obs_data_array_t *array,
				void function(obs_data_t *data, void *param) cb,
				void *param);

/* ------------------------------------------------------------------------- */
/* Item status inspection */

export bool obs_data_has_user_value(obs_data_t *data, const(char)* name);
export bool obs_data_has_default_value(obs_data_t *data, const(char)* name);
export bool obs_data_has_autoselect_value(obs_data_t *data, const(char)* name);

export bool obs_data_item_has_user_value(obs_data_item_t *data);
export bool obs_data_item_has_default_value(obs_data_item_t *data);
export bool obs_data_item_has_autoselect_value(obs_data_item_t *data);

/* ------------------------------------------------------------------------- */
/* Clearing data values */

export void obs_data_unset_user_value(obs_data_t *data, const(char)* name);
export void obs_data_unset_default_value(obs_data_t *data, const(char)* name);
export void obs_data_unset_autoselect_value(obs_data_t *data, const(char)* name);

export void obs_data_item_unset_user_value(obs_data_item_t *data);
export void obs_data_item_unset_default_value(obs_data_item_t *data);
export void obs_data_item_unset_autoselect_value(obs_data_item_t *data);

/* ------------------------------------------------------------------------- */
/* Item iteration */

export obs_data_item_t *obs_data_first(obs_data_t *data);
export obs_data_item_t *obs_data_item_byname(obs_data_t *data,
					     const(char)* name);
export bool obs_data_item_next(obs_data_item_t **item);
export void obs_data_item_release(obs_data_item_t **item);
export void obs_data_item_remove(obs_data_item_t **item);

/* Gets Item type */
export obs_data_type_t obs_data_item_gettype(obs_data_item_t *item);
export obs_data_number_type_t obs_data_item_numtype(obs_data_item_t *item);
export const(char)* obs_data_item_get_name(obs_data_item_t *item);

/* Item set functions */
export void obs_data_item_set_string(obs_data_item_t **item, const(char)* val);
export void obs_data_item_set_int(obs_data_item_t **item, long val);
export void obs_data_item_set_double(obs_data_item_t **item, double val);
export void obs_data_item_set_bool(obs_data_item_t **item, bool val);
export void obs_data_item_set_obj(obs_data_item_t **item, obs_data_t *val);
export void obs_data_item_set_array(obs_data_item_t **item,
				    obs_data_array_t *val);

export void obs_data_item_set_default_string(obs_data_item_t **item,
					     const(char)* val);
export void obs_data_item_set_default_int(obs_data_item_t **item,
					  long val);
export void obs_data_item_set_default_double(obs_data_item_t **item,
					     double val);
export void obs_data_item_set_default_bool(obs_data_item_t **item, bool val);
export void obs_data_item_set_default_obj(obs_data_item_t **item,
					  obs_data_t *val);
export void obs_data_item_set_default_array(obs_data_item_t **item,
					    obs_data_array_t *val);

export void obs_data_item_set_autoselect_string(obs_data_item_t **item,
						const(char)* val);
export void obs_data_item_set_autoselect_int(obs_data_item_t **item,
					     long val);
export void obs_data_item_set_autoselect_double(obs_data_item_t **item,
						double val);
export void obs_data_item_set_autoselect_bool(obs_data_item_t **item, bool val);
export void obs_data_item_set_autoselect_obj(obs_data_item_t **item,
					     obs_data_t *val);
export void obs_data_item_set_autoselect_array(obs_data_item_t **item,
					       obs_data_array_t *val);

/* Item get functions */
export const(char)* obs_data_item_get_string(obs_data_item_t *item);
export long obs_data_item_get_int(obs_data_item_t *item);
export double obs_data_item_get_double(obs_data_item_t *item);
export bool obs_data_item_get_bool(obs_data_item_t *item);
export obs_data_t *obs_data_item_get_obj(obs_data_item_t *item);
export obs_data_array_t *obs_data_item_get_array(obs_data_item_t *item);

export const(char)* obs_data_item_get_default_string(obs_data_item_t *item);
export long obs_data_item_get_default_int(obs_data_item_t *item);
export double obs_data_item_get_default_double(obs_data_item_t *item);
export bool obs_data_item_get_default_bool(obs_data_item_t *item);
export obs_data_t *obs_data_item_get_default_obj(obs_data_item_t *item);
export obs_data_array_t *obs_data_item_get_default_array(obs_data_item_t *item);

export const(char)* obs_data_item_get_autoselect_string(obs_data_item_t *item);
export long obs_data_item_get_autoselect_int(obs_data_item_t *item);
export double obs_data_item_get_autoselect_double(obs_data_item_t *item);
export bool obs_data_item_get_autoselect_bool(obs_data_item_t *item);
export obs_data_t *obs_data_item_get_autoselect_obj(obs_data_item_t *item);
export obs_data_array_t *
obs_data_item_get_autoselect_array(obs_data_item_t *item);

/* ------------------------------------------------------------------------- */
/* Helper functions for certain structures */
export void obs_data_set_vec2(obs_data_t *data, const(char)* name,
			      const vec2 *val);
export void obs_data_set_vec3(obs_data_t *data, const(char)* name,
			      const vec3 *val);
export void obs_data_set_vec4(obs_data_t *data, const(char)* name,
			      const vec4 *val);
export void obs_data_set_quat(obs_data_t *data, const(char)* name,
			      const quat *val);

export void obs_data_set_default_vec2(obs_data_t *data, const(char)* name,
				      const vec2 *val);
export void obs_data_set_default_vec3(obs_data_t *data, const(char)* name,
				      const vec3 *val);
export void obs_data_set_default_vec4(obs_data_t *data, const(char)* name,
				      const vec4 *val);
export void obs_data_set_default_quat(obs_data_t *data, const(char)* name,
				      const quat *val);

export void obs_data_set_autoselect_vec2(obs_data_t *data, const(char)* name,
					 const vec2 *val);
export void obs_data_set_autoselect_vec3(obs_data_t *data, const(char)* name,
					 const vec3 *val);
export void obs_data_set_autoselect_vec4(obs_data_t *data, const(char)* name,
					 const vec4 *val);
export void obs_data_set_autoselect_quat(obs_data_t *data, const(char)* name,
					 const quat *val);

export void obs_data_get_vec2(obs_data_t *data, const(char)* name,
			      vec2 *val);
export void obs_data_get_vec3(obs_data_t *data, const(char)* name,
			      vec3 *val);
export void obs_data_get_vec4(obs_data_t *data, const(char)* name,
			      vec4 *val);
export void obs_data_get_quat(obs_data_t *data, const(char)* name,
			      quat *val);

export void obs_data_get_default_vec2(obs_data_t *data, const(char)* name,
				      vec2 *val);
export void obs_data_get_default_vec3(obs_data_t *data, const(char)* name,
				      vec3 *val);
export void obs_data_get_default_vec4(obs_data_t *data, const(char)* name,
				      vec4 *val);
export void obs_data_get_default_quat(obs_data_t *data, const(char)* name,
				      quat *val);

export void obs_data_get_autoselect_vec2(obs_data_t *data, const(char)* name,
					 vec2 *val);
export void obs_data_get_autoselect_vec3(obs_data_t *data, const(char)* name,
					 vec3 *val);
export void obs_data_get_autoselect_vec4(obs_data_t *data, const(char)* name,
					 vec4 *val);
export void obs_data_get_autoselect_quat(obs_data_t *data, const(char)* name,
					 quat *val);

/* ------------------------------------------------------------------------- */
/* Helper functions for media_frames_per_second/OBS_PROPERTY_FRAME_RATE */
export void obs_data_set_frames_per_second(obs_data_t *data, const(char)* name,
					   media_frames_per_second_t fps,
					   const(char)* option);
export void
obs_data_set_default_frames_per_second(obs_data_t *data, const(char)* name,
				       media_frames_per_second_t fps,
				       const(char)* option);
export void
obs_data_set_autoselect_frames_per_second(obs_data_t *data, const(char)* name,
					  media_frames_per_second_t fps,
					  const(char)* option);

export bool obs_data_get_frames_per_second(obs_data_t *data, const(char)* name,
					   media_frames_per_second_t *fps,
					   const(char)* *option);
export bool
obs_data_get_default_frames_per_second(obs_data_t *data, const(char)* name,
				       media_frames_per_second_t *fps,
				       const(char)* *option);
export bool
obs_data_get_autoselect_frames_per_second(obs_data_t *data, const(char)* name,
					  media_frames_per_second_t *fps,
					  const(char)* *option);

export void
obs_data_item_set_frames_per_second(obs_data_item_t **item,
				    media_frames_per_second_t fps,
				    const(char)* option);
export void
obs_data_item_set_default_frames_per_second(obs_data_item_t **item,
					    media_frames_per_second_t fps,
					    const(char)* option);
export void obs_data_item_set_autoselect_frames_per_second(
	obs_data_item_t **item, media_frames_per_second_t fps,
	const(char)* option);

export bool
obs_data_item_get_frames_per_second(obs_data_item_t *item,
				    media_frames_per_second_t *fps,
				    const(char)* *option);
export bool
obs_data_item_get_default_frames_per_second(obs_data_item_t *item,
					    media_frames_per_second_t *fps,
					    const(char)* *option);
export bool obs_data_item_get_autoselect_frames_per_second(
	obs_data_item_t *item, media_frames_per_second_t *fps,
	const(char)* *option);

/* ------------------------------------------------------------------------- */
/* OBS-specific functions */

pragma(inline, true)
static obs_data_t* obs_data_newref(obs_data_t* data)
{
	if (data)
		obs_data_addref(data);
	else
		data = obs_data_create();

	return data;
}