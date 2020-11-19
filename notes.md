# pytch

A python, cython and C library for dsp.

## TODO

- **Ugens architecture :**
    - [!] add an `add` and a `mul` parameter for ugens for easy offset and scaling of the ouput.
- **Ugen implementation :**
    - Oscilloscope
    - Spectrum
- **Ugens modifications :**
    - wavetable synth : resolve audio glitch at freq = 0
- **Player :** 
    - player as a cdef and mixing as a C operation : faster mix of objects in the player pool.
    - optional compression of channels.

**DONE :**
- [x] manage optional channelization of ugens parameters using a stream type.
- [x] manage control rate : distinguish a `kr` function and rename the `process` function `ar`.
- [X] implement a bandlimited wavetable 
- [x] rename everything to have a ugen classification
- [x] manage modification of parameters on the fly
- [x] manage fast transmission of memory views

### Oscilloscope

Usage : 
```py
class Patch:
    def __init__(self):
        my_sine = Sine(20)
        my_oscilloscope = Oscilloscope()

    def play():
        sine_out = my_sine.ar()
        my_oscilloscope.set_input(sine_out)
        my_oscilloscope().view()
        return sine_out

patch = Patch()
player.add(patch)
player.play()
```

### Control rate and channel parametrization

There is a `stream` type defined as having :
- `float value` : to store a single value
- `float *array` : to store an array of values
- `int isarray` : to check if the stream is at control or audio rate (allowing to select value or array)

The `process` functions of ugens must get the value or the array's value using the isarray selector.

```py
class Patch:
    def __init__(self):
        my_sine = Sine(20)
        my_osc = Osc()
    def play():
        my_osc.set_freq(my_sine.ar())
        return my_osc.ar()
patch = Patch()
player.add(patch)
player.play()
```

### Channels

Kinds of connections :
- One to one
- One to many
- Many to one
- Many to many

## Ugens

### Ugen classification

- analysis : for analysis purposes.
    - [ ] peak detection
    - [ ] rms
    - [ ] spectrogram
    - [ ] oscilloscope
- control : for sources meant to control other ugens and to be used at control rates.
    - [ ] ar envelope
    - [ ] asr envelope
    - [ ] adsr envelope
    - [ ] arbitrary wavetable lfo
- filter : for filters of every kind.
    - [ ] biquad
    - [ ] allpass
- fx : for high-level effects
    - [ ] reverb
    - [ ] chorus
- operator : for mathematical operations and signal processing.
    - [ ] tanh
    - [ ] clip
    - [ ] waveshape
- spectral : for spectral processing
    - [ ] fft
    - [ ] ifft
- sampler : for sample based sources.
    - [ ] simple sampler
    - [ ] sampler with internal envelope, loop mode, pitch shifting and time stretching
    - [ ] granular synth
- source : for mostly audio rate sources.
    - [x] sine
    - [x] wavetable oscillator
    - [ ] arbitrary wavetable oscillator : fourier decomposition for bandlimiting
    - [ ] white noise
    - [ ] karplus strong synthesis

### Bandlimited wavetable oscillator

Assuming sr = 44100 Hz.
Assuming max harm = sr / 4 = 11025 Hz.
Assuming lowest note = A0 = 27.5 Hz.
Then we have max number of harmonics : 11025 / 27.5 = 400.99...
So we have minimum table_size of 400 * 2 + 1 = 801.
For good results with interpolation and use with fft, we'll oversample to 2048 samples.
Assuming max note = C8.
Assuming one row for each chromatic note from A0 to C8 (88 note range).
The matrix is then : 2048 samples × 88 fourier reconstructions = 180224 data points. Since it's float32, it means 720.896 kB of memory used to store the matrix.
To store it : Generate the matrix once at initialization using numpy and convert it to a memoryview for fast access.

## Design

On a des ugens qui ont trois composants :
- Un **cdef object** dans un **.pyx** qui :
    - contient les paramètres de l'ugen
    - contient la struct state qui stocke les paramètres variables
    - a une méthode `__init__()` qui :
        - initialise les paramètres
        - initialise la struct state C
    - a une méthode `process()` qui (TODO : renommer en `ar`):
        - crée une array numpy qui correpond au buffer à renvoyer
        - crée une memoryview sur cette array pour la passer à la fonction C `process()` correpondante
        - transmet le struct state C correpondant à la fonction C `process()` correspondante
        - renvoie l'array.
    - a une méthode `kr()` qui fait comme `ar` mais avec une seule valeur au lieu d'un buffer.
- Un **struct state C** contenant les paramètres variables et stockés nécessaires au fonctionnement de la fonction `process` C.
- Une **fonction C `process()`** opérant sur la memoryview récupérée
    - Elle récupère le buffer à remplir et le remplit.
    - Elle peut récupérer d'autres buffers comme entrées audio.

On peut créer des intruments / patchs en :
- Créant un objet correspondant contenant tous les paramètres et ugens nécessaires.
- Connectant les ugens en appelant leur méthode `process` dans une méthode `process`.

On a un objet `Player` qui :
- A une liste de tous les instruments/patchs en train de jouer.
- A une méthode `process` qui exécute la méthode `process` de chaque objet qu'elle contient, mix et renvoit le bloc résultant.

On a une fonction `callback` qui appelle `player.process()`.

## Problems

Comment est-ce que les ugens sont connectés les uns aux autres ?

Que se passe-t-il dans la callback de manière à ce qu'elle puisse prendre de multiples ugens connectés les uns aux autres ?

## Concept

pytch implements ugens usable in python allowing to create ugen patches.

ugens are implemented in C for efficiency and cython provides the interface between python code and C code.

**Example code :**

Saw in reverb.
``` py
saw = pytch.Saw(freq=440, phase=0.5)

reverb = pytch.Reverb(saw)

reverb.out()
```