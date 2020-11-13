#include "stream.h"

stream init_stream(float value, float *array, int isarray)
{
    stream this_stream;
    this_stream.value = value;
    this_stream.array = array;
    this_stream.isarray = isarray;
    return (this_stream);
}