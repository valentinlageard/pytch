# Ici on a le stream audio général

import sounddevice as sd
import time
import numpy as np
from pytch import Sine
from player import Player

SR = 22050
BUFFER_SIZE = 512

player = Player(SR, BUFFER_SIZE)
my_sine1 = Sine(220*2, 0)
player.add(my_sine1)
#my_sine2 = Sine(220, 0)
#player.add(my_sine2)

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

i = 0.0

while True:
    time.sleep(0.5)
