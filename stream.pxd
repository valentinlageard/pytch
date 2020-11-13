cdef extern from "stream.h":
    ctypedef struct stream:
        float value
        float *array
        int isarray
    stream init_stream(float value, float *array, int isarray)