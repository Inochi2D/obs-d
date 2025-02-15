module obs.log;

enum {
	/**
	 * Use if there's a problem that can potentially affect the program,
	 * but isn't enough to require termination of the program.
	 *
	 * Use in creation functions and core subsystem functions.  Places that
	 * should definitely not fail.
	 */
	LOG_ERROR = 100,

	/**
	 * Use if a problem occurs that doesn't affect the program and is
	 * recoverable.
	 *
	 * Use in places where failure isn't entirely unexpected, and can
	 * be handled safely.
	 */
	LOG_WARNING = 200,

	/**
	 * Informative message to be displayed in the log.
	 */
	LOG_INFO = 300,

	/**
	 * Debug message to be used mostly by developers.
	 */
	LOG_DEBUG = 400
}

private extern(C) {
    export void blog(int log_level, const char *format, ...);
}

/**
    Writes an entry to the OBS log.
*/
void OBSLog(Args...)(int logLevel, string formatStr, Args args) {
    import std.string : toStringz;
    import std.format : format;
    blog(logLevel, formatStr.format(args).toStringz);
}