################ USAGE #########################

# [CPU=Intel] [DEBUG=True] make           

# i.e) make, CPU=Intel make, DEBUG=True make, CPU=Intel DEBUG=True make
# CPU=Intel will toggle the Intel compiler (icpc) for cpu code
# DEBUG=True will compile in debug mode for both gpu and cpu code
# These vars can be specified below as well.

# Users shoud edit the USER EDIT section as needed

########################## BEGIN USER EDIT ##############################
# specify location of DoublyPeriodicStokes directory
export DPSTOKES_ROOT    = $(PWD)
# specify desired location of shared libraries
export DPSTOKES_INSTALL = $(DPSTOKES_ROOT)/python_interface/lib
# name of the python3 executable
export PYTHON3          = python3
# if True, compilation will use debug mode for cpu and gpu code
export DEBUG           ?= False

#---------------------------------------------------
# CPU/OpenMP settings
#---------------------------------------------------
# specify compiler type - GNU|Intel (only used for cpu build)
export CPU             ?= GNU

# specify where lapacke.h and liblapacke.so 
# For openblas (see CPU=Intel below for Intel's MKL)
export LAPACKE_FLAGS    = -I/usr/include/openblas -L/usr/lib64
export LAPACKE_LIBS     = -lopenblas -llapacke

# specify where fftw*.h/.so are and select whether to use fftw wisdom (see README)
ifeq ($(CPU),Intel)
  # set fftw_install dir (custom install needed for intel cc)
  export FFTW_INSTALL   = $(DPSTOKES_ROOT)/source/cpu/fftw_install
  # set mkl install dir
  export MKLROOT       ?= /opt/intel/mkl
  export FFTW_FLAGS     = -I$(FFTW_INSTALL)/include -L$(FFTW_INSTALL)/lib -DENABLE_WISDOM -DUSE_FFTW_MEASURE
  # override lapack flags/libs to always use MKL for best performance
  export LAPACKE_FLAGS  = -I$(MKLROOT)/include -L$(MKLROOT)/lib/intel64 -DUSE_MKL
  export LAPACKE_LIBS   = -lmkl_rt -lpthread -ldl
else 
  # change USE_FFTW_MEASURE to USE_FFTW_PATIENT for more optimal fftw plans
  export FFTW_FLAGS     = -I/usr/include -L/usr/lib/x86_64-linux-gnu -DENABLE_WISDOM -DUSE_FFTW_MEASURE  
endif

# use stack instead of heap for part of cpu spreading algorithm
export SPREAD_FLAGS     = -DUSE_STACK

################################ END USER EDIT ##################################

export calling_from_parent = True
all: env_config
ifeq ($(CPU), GNU)
	make -f Makefile.GNU -C $(DPSTOKES_ROOT)/source/cpu; 
endif
ifeq ($(CPU), Intel)
	make -f Makefile.Intel -C $(DPSTOKES_ROOT)/source/cpu;
endif

env_config:
	@sed -i "/DPSTOKES_ROOT=/c DPSTOKES_ROOT=$(DPSTOKES_ROOT)" $(DPSTOKES_ROOT)/python_interface/cpuconfig.sh
	@sed -i "/DPSTOKES_INSTALL=/c DPSTOKES_INSTALL=$(DPSTOKES_INSTALL)" $(DPSTOKES_ROOT)/python_interface/cpuconfig.sh
	@sed -i "/CPU=/c CPU=$(CPU)" $(DPSTOKES_ROOT)/python_interface/cpuconfig.sh

clean:
	rm -rf $(DPSTOKES_INSTALL)/lib*.so
