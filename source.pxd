from stream cimport stream

cdef extern from "source_engine.h":
    ctypedef struct sine_state:
        stream freq
        stream phase
        float curphase
    sine_state init_sine(stream freq, stream phase)
    void process_sine(float *buffer, float sr, int buffer_size, sine_state *state)
    
'''
ctypedef struct osc_state:
    stream freq
    stream phase
    float **matrix
    int table_size_x
    int table_size_y
    float curphase
osc_state init_osc(stream freq, stream phase, float **matrix, int table_size_x, int table_size_y)
void process_osc(float buffer[], float sr, int buffer_size, osc_state *state)
'''