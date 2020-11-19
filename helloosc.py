# Ici on a le stream audio général

import sounddevice as sd
import time
import numpy as np
from pytch import Osc
from player import Player


from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter

SR = 44100
BUFFER_SIZE = 128

player = Player(SR, BUFFER_SIZE)
my_osc = Osc(freq=440, shape="sine")
player.add(my_osc)

'''matrix = my_osc.generate_matrix("square")
print(matrix.shape, matrix.dtype)
print(matrix[0])

# Gridlines based on minor ticks
plt.imshow(matrix, aspect='auto', cmap='Greys',interpolation="nearest")
'''


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
    time.sleep(0.5)
