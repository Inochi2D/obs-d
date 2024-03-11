module obs.internal.mediaio;
enum MAX_AV_PLANES = 8;

struct media_frames_per_second_t {
    uint numerator;
    uint denominator;

    double toFrameInterval() {
        return cast(double) denominator / cast(double) numerator;
    }

    double toFPS() {
        return cast(double) numerator / cast(double) denominator;
    }

    bool isValid() {
        return numerator && denominator;
    }
}
