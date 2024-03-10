module obs;
import obs.config;
import core.runtime;

/// Reference to C OBS module.
struct obs_module_t;

/**
    Instantiates OBS module
*/
class OBSModule {
private:
    obs_module_t* handle;

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

    string getAuthor() {
        return "unknown";
    }

    string getName() {
        return "Untitled OBS Plugin";
    }

    string getDescription() {
        return "My cool plugin";
    }

    final
    obs_module_t* getHandle() {
        return handle;
    }
}

mixin template EntryPoint(alias obsModuleType) if (is(obsModuleType : OBSModule)) {
    
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
        return LIBOBS_API_VER;
    }

    export bool obs_module_load() {
        bool initialized = Runtime.initialize();
        if (initialized) {
            __internal_module = new obsModuleType();
            __internal_module.handle = __internal_obs_module_pointer;

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
}