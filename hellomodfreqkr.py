import sounddevice as sd
import time
import numpy as np
from pytch import Sine
from player import Player
import random

SR = 44100
BUFFER_SIZE = 128

class MyPatch():
    def __init__(self):
        self.sr = None
        self.buffer_size = None
        self.modulator = Sine(0.5)
        self.carrier = Sine(220)
    
    def ar(self):
        mod_out = self.modulator.kr() * 400 + 400
        self.carrier.set_freq(mod_out)
        print(mod_out)
        return self.carrier.ar()
    
    def set_sr(self, sr):
        self.sr = sr

    def set_buffer_size(self, buffer_size):
        self.buffer_size = buffer_size

player = Player(SR, BUFFER_SIZE)
my_patch = MyPatch()
player.add(my_patch)


def callback(outdata, frame_count, time_info, status):
    data = player.play()
    outdata[:] = data.reshape(outdata.shape)

out_stream = sd.OutputStream(samplerate=SR,
                             blocksize=BUFFER_SIZE,
                             channels=1,
                             dtype=np.float32,
                             callback=callback)

time.sleep(1)
out_stream.start()

while True:
    time.sleep(1)
