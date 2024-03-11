module obs.internal.graphics;
extern(C):

struct gs_texture_t;

enum gs_draw_mode_t {
	GS_POINTS,
	GS_LINES,
	GS_LINESTRIP,
	GS_TRIS,
	GS_TRISTRIP,
}

enum gs_color_format_t {
	GS_UNKNOWN,
	GS_A8,
	GS_R8,
	GS_RGBA,
	GS_BGRX,
	GS_BGRA,
	GS_R10G10B10A2,
	GS_RGBA16,
	GS_R16,
	GS_RGBA16F,
	GS_RGBA32F,
	GS_RG16F,
	GS_RG32F,
	GS_R16F,
	GS_R32F,
	GS_DXT1,
	GS_DXT3,
	GS_DXT5,
	GS_R8G8,
	GS_RGBA_UNORM,
	GS_BGRX_UNORM,
	GS_BGRA_UNORM,
	GS_RG16,
}

enum gs_color_space_t {
	GS_CS_SRGB,         /* SDR */
	GS_CS_SRGB_16F,     /* High-precision SDR */
	GS_CS_709_EXTENDED, /* Canvas, Mac EDR (HDR) */
	GS_CS_709_SCRGB,    /* 1.0 = 80 nits, Windows/Linux HDR */
}


enum gs_zstencil_format_t {
	GS_ZS_NONE,
	GS_Z16,
	GS_Z24_S8,
	GS_Z32F,
	GS_Z32F_S8X24,
};

enum gs_index_type_t {
	GS_UNSIGNED_SHORT,
	GS_UNSIGNED_LONG,
};

enum gs_cull_mode_t {
	GS_BACK,
	GS_FRONT,
	GS_NEITHER,
};

enum gs_blend_type_t{
	GS_BLEND_ZERO,
	GS_BLEND_ONE,
	GS_BLEND_SRCCOLOR,
	GS_BLEND_INVSRCCOLOR,
	GS_BLEND_SRCALPHA,
	GS_BLEND_INVSRCALPHA,
	GS_BLEND_DSTCOLOR,
	GS_BLEND_INVDSTCOLOR,
	GS_BLEND_DSTALPHA,
	GS_BLEND_INVDSTALPHA,
	GS_BLEND_SRCALPHASAT,
};

enum gs_blend_op_type_t {
	GS_BLEND_OP_ADD,
	GS_BLEND_OP_SUBTRACT,
	GS_BLEND_OP_REVERSE_SUBTRACT,
	GS_BLEND_OP_MIN,
	GS_BLEND_OP_MAX
};

enum gs_depth_test_t {
	GS_NEVER,
	GS_LESS,
	GS_LEQUAL,
	GS_EQUAL,
	GS_GEQUAL,
	GS_GREATER,
	GS_NOTEQUAL,
	GS_ALWAYS,
};

enum gs_stencil_side_t {
	GS_STENCIL_FRONT = 1,
	GS_STENCIL_BACK,
	GS_STENCIL_BOTH,
};

enum gs_stencil_op_type_t {
	GS_KEEP,
	GS_ZERO,
	GS_REPLACE,
	GS_INCR,
	GS_DECR,
	GS_INVERT,
};

enum gs_cube_sides_t {
	GS_POSITIVE_X,
	GS_NEGATIVE_X,
	GS_POSITIVE_Y,
	GS_NEGATIVE_Y,
	GS_POSITIVE_Z,
	GS_NEGATIVE_Z,
};

enum gs_sample_filte_t {
	GS_FILTER_POINT,
	GS_FILTER_LINEAR,
	GS_FILTER_ANISOTROPIC,
	GS_FILTER_MIN_MAG_POINT_MIP_LINEAR,
	GS_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT,
	GS_FILTER_MIN_POINT_MAG_MIP_LINEAR,
	GS_FILTER_MIN_LINEAR_MAG_MIP_POINT,
	GS_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR,
	GS_FILTER_MIN_MAG_LINEAR_MIP_POINT,
};

enum gs_address_mode_t {
	GS_ADDRESS_CLAMP,
	GS_ADDRESS_WRAP,
	GS_ADDRESS_MIRROR,
	GS_ADDRESS_BORDER,
	GS_ADDRESS_MIRRORONCE,
};

enum gs_texture_type_t {
	GS_TEXTURE_2D,
	GS_TEXTURE_3D,
	GS_TEXTURE_CUBE,
};

export gs_texture_t* gs_texture_create(uint width, uint height,
				       gs_color_format_t color_format,
				       uint levels, const(ubyte*)* data,
				       uint flags);

export void gs_texture_set_image(gs_texture_t *tex, const(ubyte)* data, uint linesize, bool invert);