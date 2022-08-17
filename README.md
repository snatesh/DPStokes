# A spectral force coupling method for Stokes mobility problems with the ES kernel

## About this repository 

This repository implements a variant on the Force Coupling Method for Stokes suspensions, based on the exponential of a semicircle (ES) kernel, see:
[CITE THE ARTICLE HERE]
This repo also contains code and scripts to reproduce the data for the figures in the applications section of the article (see the README inside each folder for information about each simulation).

We provide a simple python interface, but the key performance-sensitive pieces (namely FFTs, BVP solvers, and spreading and interpolation) are implemented in C++/CUDA using FFTW/cuFFT and LAPACK. One can use either the GPU and CPU versions as needed without changing calls. (NOTE: this release does not include GPU version)

The solver can be used to solve mobility problems for colloidal layers in doubly periodic systems (in x,y), including those which are unbounded in z (DP), containing a bottom wall (DPBW) or the doubly periodic slit channel (DPSC). For the confined geometries, a no-slip B.c. is prescribed at the walls, and this is all we expose in this initial release.

The CPU version of the solver is included in `source/cpu`. In particular, this implements an OpenMP-based C++ spreading and interpolation library in 3D that supports also non-uniform grids in the z direction. One can use the C++ library directly if desired, but there is a python interface wrapping it as well.

## Installation

To be able to use either the GPU or CPU versions on demand, you will need to have reasonably new versions of CUDA, GNU or Intel C++ compilers, and python 3. For example, on Courant machines you can use something like:
```shell
module load cuda-10.2
module load intel-2019
module load gcc-6.4.0
module load python-3.8
```
From DoublyPeriodicStokes, Running 
```shell
make 
```
will compile and set up both the CPU and GPU python interfaces for the solver.

The top level `Makefile` in DPStokes contains a section where a user
can specify the dependency library names/paths, install paths and the like.
Users should source the bash script `cpuconfig.sh` before using either 
the GPU or CPU Python interface in a new shell, and can edit the thread environment 
settings therin as needed. The PYTHONPATH and LD_LIBRARY_PATH environment variables
are appeneded to so that the modules can be used anywhere within the filesystem.
By default, the script will exist in the $INSTALL_DIR specified in the top Makefile.

If you want to use the Intel compiler for the CPU code, prefix the call to make as
```shell
CPU=Intel make
``` 
Note, even if using the Intel compiler, you must load the module for gcc-6.4.0 or higher, 
as the compiler relies on GNU headers. Also, note that by default with Intel compilers, the [MKL library](https://en.wikipedia.org/wiki/Math_Kernel_Library) is used to provide LAPACK/BLAS functionality. MKL (or other LAPACK/BLAS implementations) can be used with GNU compilers as well by specifying the relevant paths in the top level `Makefile`.
 
You can compile both CPU and GPU libraries in debug mode through
```shell
DEBUG=True make
```
Both CPU and DEBUG can also be set from within the `Makefile`, though the 
command line setting will override the ones in the `Makefile`.

## Python Interface

A common python interface is provided that allows one to compute the hydrodynamic displacements for a group of positions with forces and/or torques acting on them in different geometries, mainly:  

	* Triply periodic, using a standard FFT-based spectral Stokes solver.
	* Doubly periodic (either with no walls, a bottom wall or a slit channel), see paper for details.

Hydrodynamic displacements coming from forces and torques can be computed. 
For the GPU interface, if the torque-related arguments are ommited, the computations related to them are skipped entirely.
For the CPU interface, the user must specify whether torques are involved with a boolean swith, like `has_torque=True`.
        
The file `python_interface/common_interface_wrapper.py` is the joint CPU-GPU interface. 
Usage examples for the joint interface are availabe in the `mobility` and `benchmark` folders.

### CPU Python interface

See the `source/cpu/README.md` for details. Note, the build instructions contained therein are for using cmake3 as the build system. 
The section can be ignored, or followed analogously through the provided top level Makefile. The file `python_interface/dpstokesCPU.py` contains an example.
One can specify particles with differing radii in the CPU Python interface, though we only expose single radius setting in the joint interface.  

OpenMP is used for parallelization and users should control the number of threads and thread pinning via the bash script `cpuconfig.sh`. This script is installed in the `python_interface` folder when the library is compiled. Importantly, efficient plans for FFTs are precomputed for a given grid size the first time that size is encountered. They are saved to a folder in the working directory `./fftw_wisdom`. These plans, once precomputed, dramatically improve the initialization and execution time, though users should  select the appropriate thread settings in `cpuconfig.sh` prior to plan creation. See the `FFTW Settings` section in `source/cpu/README.md` for more details.  

