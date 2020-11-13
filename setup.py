# The setup that compiles and links everything

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from numpy import get_include

ext_modules = [Extension("pytch",
                         sources=[
                                  "stream.c",
                                  "source.pyx",
                                  "source_engine.c"
                                  ],
                         include_dirs=['.', get_include()])]

setup(
    name = "pytch",
    cmdclass = {'build_ext': build_ext},
    ext_modules = ext_modules
    )
