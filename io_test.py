import sounddevice as sd
import time
import numpy as np

SR = 22050
BLOCKSIZE = 128

class Sine():
    def __init__(self, freq=440, phase=0):
        self.freq = freq
        self.phase = phase
    
    def get_block(self):
        phases = (self.phase + (np.arange(BLOCKSIZE) * self.freq / SR)) % 1
        self.phase = (phases[-1] + self.freq/SR) % 1
        out = np.sin(phases * 2 * np.pi)
        return out.astype(np.float32)

sine1 = Sine(220, 0)
sine2 = Sine(110*3, 0)
sine3 = Sine(110*5, 0)

def callback(outdata, frame_count, time_info, status):
    data = sine1.get_block() * 0.2 + sine2.get_block() * 0.3 + sine3.get_block() * 0.4
    outdata[:] = data.reshape(outdata.shape)

out_stream = sd.OutputStream(samplerate=SR,
                             blocksize=BLOCKSIZE,
                             channels=1,
                             dtype=np.float32,
                             callback=callback)

time.sleep(1)
out_stream.start()

while True:
    time.sleep(0.1)