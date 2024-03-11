module obs;
import obs.config;
import core.runtime;
import obs.internal.obs;

public import obs.source;
public import obs.log;

/**
    Instantiates OBS module
*/
class OBSModule {
private:
    obs_module_t* handle;
    obs_source_info_t[] sources;

public:

    /**
        * Required: Called when the module is loaded.  Use this function to load all
        * the sources/encoders/outputs/services for your module, or anything else that
        * may need loading.
        *
        * @return           Return true to continue loading the module, otherwise
        *                   false to indicate failure and unload the module
    */
    abstract bool load();

    /// Optional: Called when the module is unloaded.
    void unload() {}

    /// Called when the module is unloaded
    void postLoad() {}

    /// Called when the module is unloaded
    void setLocale(string locale) {}

    /// Called when the module is unloaded
    void freeLocale() {}

    const(char)* getAuthor() {
        return "unknown";
    }

    const(char)* getName() {
        return "Untitled OBS Plugin";
    }

    const(char)* getDescription() {
        return "My cool plugin";
    }

    final
    obs_module_t* getHandle() {
        return handle;
    }

    final
    void setHandle(obs_module_t* handle) {
        this.handle = handle;
    }

    /**
        Registers a source, should be called in constructor
    */
    final
    void registerSource(T)() if (is(T : OBSSource)) {
        sources ~= createSourceInfoFor!T();
        obs_register_source(&sources[$-1]);
    }
}

template EntryPoint(alias obsModuleType) if (is(obsModuleType : OBSModule)) {
extern(C):
    import obs.config;
    import core.runtime;
    import obs.internal.obs;

    // Internal info
    private {
        __gshared obs_module_t* __internal_obs_module_pointer;
    }

    __gshared OBSModule __internal_module;

    export void obs_module_set_pointer(obs_module_t* module_) {
        __internal_obs_module_pointer = module_;
    }

    obs_module_t* obs_current_module() {
        return __internal_obs_module_pointer;
    }

    export uint obs_module_ver() {
        return LIBOBS_API_VERSION;
    }

    export bool obs_module_load() {
        bool initialized = Runtime.initialize();
        if (initialized) {
            __internal_module = new obsModuleType();
            __internal_module.setHandle(__internal_obs_module_pointer);

            return __internal_module.load();
        }
        return false; // D runtime not initialized.
    }

    export void obs_module_unload() {
        if (__internal_module) {
            __internal_module.unload();
            destroy!false(__internal_module);
        }
        Runtime.terminate();
    }

    export void obs_module_post_load() {
        __internal_module.postLoad();
    }

    export const(char)* obs_module_author() {
        return __internal_module.getAuthor();
    }

    export const(char)* obs_module_name() {
        return __internal_module.getName();
    }

    export const(char)* obs_module_description() {
        return __internal_module.getDescription();
    }
}