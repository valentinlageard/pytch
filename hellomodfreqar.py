import sounddevice as sd
import time
import numpy as np
from pytch import Sine, Osc
from player import Player
import random

SR = 44100
BUFFER_SIZE = 128

class MyPatch():
    def __init__(self):
        self.sr = None
        self.buffer_size = None
        self.modulator = Sine(110)
        self.depth_modulator = Sine(0.1)
        self.carrier = Osc(shape="sawup")
    
    def ar(self):
        depth_out = (self.depth_modulator.kr() + 1) / 2 * 440
        mod_out = (self.modulator.ar() * depth_out) + 110
        self.carrier.set_freq(mod_out)
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
