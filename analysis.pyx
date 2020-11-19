import numpy as np
cimport numpy as np
cimport stream as s

DTYPE = np.float32
ctypedef np.float32_t DTYPE_t

cdef class Oscilloscope:
    cdef s.stream input_stream
    cdef float sr
    cdef int buffer_size
    def __init__(self, input, sr=44100, buffer_size=128):
        self.input_stream = to_stream(input)
        self.sr = sr
        self.buffer_size = buffer_size
    
    def ar(self):
        buffer = np.zeros(self.buffer_size, dtype=DTYPE)
        # Do the printing and compute here
        return buffer
    
    def kr(self):
        buffer = np.zeros(1, dtype=DTYPE)
        # Do the printing and compute here
        return buffer[0]
    
    def set_input(self, input):
        self.input_stream = to_stream(input)
        self.state.input = self.input_stream
    
    def set_sr(self, sr):
        self.sr = sr
    
    def set_buffer_size(self, buffer_size):
        self.buffer_size = buffer_size
