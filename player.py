import numpy as np

class Player:
    def __init__(self, sr, buffer_size):
        self.sr = sr
        self.buffer_size = buffer_size
        self.patches = []
    
    def add(self, patch):
        patch.set_sr(self.sr)
        patch.set_buffer_size(self.buffer_size)
        self.patches.append(patch)
    
    def play(self):
        # Process and mix every patches in the pool
        buffer = np.zeros(self.buffer_size, dtype=np.float32)
        # TODO : Optimize the mixing
        for patch in self.patches:
            buffer += patch.ar()
        return buffer