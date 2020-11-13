# Ugens definitions as cdef classes

import numpy as np
cimport numpy as np
cimport source
cimport stream as s
from cpython.mem cimport PyMem_Malloc, PyMem_Free

DTYPE = np.float32
ctypedef np.float32_t DTYPE_t

def normalize(x):
    # Normalizes a numpy array
    return x / x.max()

# Wavetable oscillator matrix generation utilities

# TODO [Optimization] : Use cdef function to fasten the process ?

def sin_gen(size=2048, order=1, phase=0):
    # Generates an array of *size* with a sinusoidal harmonic of *order* and *phase*
    # Used to generate sinusoidals to be summed for wavetable additive synthesis of a waveshape
    x = np.linspace(0, (2 * np.pi) * order, size, dtype=np.float32)
    return np.sin(x + (2 * np.pi) * phase)

def sine_gen(size=2048, order=1):
    # Generates a sine wavetable of *size* and composed of a single harmonic
    return sin_gen(size, 1)

def square_gen(size=2048, order=1):
    # Generates a square wavetable of *size* and composed of harmonics up to *order*
    harmonics = np.zeros((order, size), dtype=np.float32)
    # TODO : Optimization : Creates twice as many necessary rows !
    for i in range(0, order, 2):
        harmonics[i] = (1 / (i + 1)) * sin_gen(size, i + 1)
    return normalize(harmonics.sum(0))

def saw_gen(size=2048, order=1):
    # Generates a saw up wavetable of *size* and composed of harmonics up to *order*
    harmonics = np.zeros((order, size), dtype=np.float32)
    for i in range(0, order):
        harmonics[i] = (1 / (i + 1)) * sin_gen(size, i + 1)
    return normalize(harmonics.sum(0))

def tri_gen(size=2048, order=1):
    # Generates a triangle wavetable of *size* and composed of harmonics up to *order*
    harmonics = np.zeros((order, size), dtype=np.float32)
    # TODO : Optimization : Creates twice as many necessary rows !
    for i in range(0, order, 2):
        if not (((i + 1) % 4) - 3):
            harmonics[i] = sin_gen(size, i + 1, 0.5) / ((i + 1) ** 2)
        else:
            harmonics[i] = sin_gen(size, i + 1, 0) / ((i + 1) ** 2)
    return normalize(harmonics.sum(0))

def matrix_gen(wave_gen, size=2048, col_size=88, min_freq=27.5, max_freq=11025):
    # For each chromatic note from min_freq, generate up to sr / note_freq harmonics and store every step in a matrix
    return np.array([wave_gen(size=size, order=int(max_freq / (min_freq * 2 ** (i / 12)))) for i in range(0, col_size)])

cdef s.stream to_stream(x):
    cdef s.stream stream
    cdef DTYPE_t[:] x_view
    if isinstance(x, int) or isinstance(x, float):
        stream = s.init_stream(<float> x, <float *> 0, <int> 0)
    else:
        x_view = x
        stream = s.init_stream(<float>0, <float *>&x_view[0], <int> 1)
    return stream

# Sine

cdef class Sine:
    cdef s.stream freq_stream
    cdef s.stream phase_stream
    cdef source.sine_state state
    cdef float sr
    cdef int buffer_size
    def __init__(self, freq=440, phase=0, sr=44100, buffer_size=128):
        self.freq_stream = to_stream(freq)
        self.phase_stream = to_stream(phase)
        self.state = source.init_sine(self.freq_stream, self.phase_stream)
        self.sr = sr
        self.buffer_size = buffer_size
    
    def ar(self):
        buffer = np.zeros(self.buffer_size, dtype=DTYPE)
        cdef DTYPE_t[:] buffer_view = buffer
        source.process_sine(&buffer_view[0], self.sr, self.buffer_size, <source.sine_state*>&self.state)
        return buffer
    
    def kr(self):
        buffer = np.zeros(1, dtype=DTYPE)
        cdef DTYPE_t[:] buffer_view = buffer
        source.process_sine(&buffer_view[0], self.sr / self.buffer_size, 1, <source.sine_state*>&self.state)
        return buffer[0]
    
    def set_freq(self, freq):
        self.state.freq = to_stream(freq)
    
    def set_phase(self, phase):
        self.state.phase = to_stream(phase)
    
    def set_sr(self, sr):
        self.sr = sr
    
    def set_buffer_size(self, buffer_size):
        self.buffer_size = buffer_size

# Basic shapes bandlimited thruzero wavetable oscillator

'''

cdef class Osc:
    cdef source.osc_state state
    cdef float sr
    cdef int buffer_size
    def __init__(self, freq=440, phase=0, shape="sine", sr=44100, buffer_size=128):
        cdef np.ndarray[float, ndim=2, mode="c"] matrix = self.generate_matrix(shape)
        cdef float** matrix_pointers = <float **>PyMem_Malloc(88 * sizeof(float*))
        if not matrix_pointers:
            raise MemoryError
        for i in range(88): 
            matrix_pointers[i] = &matrix[i, 0]
        self.state = source.init_osc(freq, phase, &matrix_pointers[0], 2048, 88)
        # When should I free the matrix pointers with PyMem_Free ?
        # I should keep it stored as an attribute and delete when the ugen is destroyed
        self.sr = sr
        self.buffer_size = buffer_size

    def ar(self):
        buffer = np.zeros(self.buffer_size, dtype=DTYPE)
        cdef DTYPE_t[:] buffer_view = buffer
        source.process_osc(&buffer_view[0], self.sr, self.buffer_size, <source.osc_state*>&self.state)
        return buffer

    def kr(self):
        buffer = np.zeros(1, dtype=DTYPE)
        cdef DTYPE_t[:] buffer_view = buffer
        source.process_osc(&buffer_view[0], self.sr / self.buffer_size, 1, <source.osc_state*>&self.state)
        return buffer[0]

    def generate_matrix(self, shape):
        if shape == "sine":
            return matrix_gen(sine_gen)
        elif shape == "triangle":
            return matrix_gen(tri_gen)
        elif shape == "square":
            return matrix_gen(square_gen)
        elif shape == "sawup":
            return matrix_gen(saw_gen)
    
    def set_freq(self, freq):
        self.state.freq = freq
    
    def set_phase(self, phase):
        self.state.phase = phase
    
    def set_sr(self, sr):
        self.sr = sr
    
    def set_buffer_size(self, buffer_size):
        self.buffer_size = buffer_size

'''