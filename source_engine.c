#include <math.h>
#include <stdio.h>
#include "source_engine.h"

// Utils

float lerp(float x, float x0, float x1, float y0, float y1)
{
    return (y0 + ((x - x0) / (x1 - x0)) * (y1 - y0));
}

int truemod(int x, int y)
{
    return ((x % y) + y) % y;
}

float truemodf(float x, float y)
{
    return fmodf((fmodf(x, y) + y), y);
}

// Sine

sine_state init_sine(stream freq, stream phase)
{
    sine_state state;
    state.freq = freq;
    state.phase = phase;
    state.curphase = 0.0;
    return (state);
}

void process_sine(float buffer[], float sr, int buffer_size, sine_state *state)
{
    float freq, phase;
    for (int i = 0; i < buffer_size; i++)
    {
        freq = state->freq.isarray ? state->freq.array[i] : state->freq.value;
        phase = state->phase.isarray ? state->phase.array[i] : state->phase.value;
        buffer[i] = sin((state->curphase + phase) * 2.0 * M_PI);
        state->curphase = (float)fmod((state->curphase) + freq / sr, 1.0);
    }
}

// Bandlimited wavetable oscillator

osc_state init_osc(stream freq, stream phase, float **matrix, int table_size_x, int table_size_y)
{
    osc_state state;
    state.freq = freq;
    state.phase = phase;
    state.matrix = matrix;
    state.table_size_x = table_size_x;
    state.table_size_y = table_size_y;
    state.curphase = 0.0;
    return (state);
}

void process_osc(float buffer[], float sr, int buffer_size, osc_state *state)
{
    // TODO : There is an audio glitch when freq = 0 !
    float freq, phase;
    float phase_increment, sample_fid, freq_fid;
    int freq_id0, freq_id1, freq_sign;
    float fx_sx, fx_sy, fy_sx, fy_sy;
    float interp_f0, interp_f1;
    
    for (int i = 0; i < buffer_size; i++)
    {
        freq = state->freq.isarray ? state->freq.array[i] : state->freq.value;
        phase = state->phase.isarray ? state->phase.array[i] : state->phase.value;
        phase_increment = freq / sr;
        freq_sign = freq > 0 ? 1 : 0; 
        // Get sample float id and frequency float id
        sample_fid = truemodf(state->curphase + phase, 1.0) * ((float)(state->table_size_x) - 1.0);
        freq_fid = 12.0 * log2f(fabsf(freq) / 440.0) + 48.0;
        freq_id0 = (int)fmaxf(fminf(freq_fid, 87), 0);
        freq_id1 = (int)fmaxf(fminf(freq_fid + 1, 87), 0);
        // Get the four data points. Be wary to fold back positively and negatively.
        fx_sx = state->matrix[freq_id0][(int)sample_fid];
        fx_sy = state->matrix[freq_id0][truemod(((int)sample_fid + freq_sign), state->table_size_x)];
        fy_sx = state->matrix[freq_id1][(int)sample_fid];
        fy_sy = state->matrix[freq_id1][truemod(((int)sample_fid + freq_sign), state->table_size_x)];
        // Get the two samples interpolations
        interp_f0 = lerp(sample_fid, (float)((int)sample_fid), (float)((int)sample_fid + 1), fx_sx, fx_sy);
        interp_f1 = lerp(sample_fid, (float)((int)sample_fid), (float)((int)sample_fid + 1), fy_sx, fy_sy);
        // Write the freq interpolation in the buffer
        buffer[i] = lerp(freq_fid, (float)((int)freq_fid), (float)((int)freq_fid + 1), interp_f0, interp_f1);
        // Update curphase
        state->curphase = truemodf(state->curphase + phase_increment, 1.0);
    }
}
