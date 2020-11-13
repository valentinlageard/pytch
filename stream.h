#ifndef STREAM
#define STREAM

typedef struct stream_t {
    float value;
    float *array;
    int isarray;
} stream;

stream init_stream(float value, float *array, int isarray);

#endif