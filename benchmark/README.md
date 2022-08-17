This folder contains a script for benchmarking the cpu solvers, along with data needed for the script.
The data archive must be unarchived before executing the script, and `cpuconfig.sh` must be sourced, like 
```shell
tar xvzf Test_Data_For_Rollers.tgz
source cpuconfig.sh
python3 fcm_multiblob_compare
```
If FFTW_WISDOM is enabled, expect the first run to take some time planning the FFTs. These plans will be saved
to disk for later reuse in a folder `./fftw_wisdom`, and dramatically reduce initialization time.
