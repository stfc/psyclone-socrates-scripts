# Usage
This contains the required build files to use PSyclone with Socrates (with the `runes_driver3` application).
This is a work in progress so no Licence is given and usage is entirely at the users own risk.

There are currently 2 options to use PSyclone with Socrates:

1. OpenMP using the `./test_omp_gpu.sh` script. This has been tested a little more and may do additional inlining and parallelism on the GPU.
2. OpenACC using the `./test_omp_acc.sh` script.

Both scripts require the user to update the `SOCRATES_BASE` to the base directory of the downloaded Socrates repository.

This will result in an `out_omp/acc` directory containing a CMakeLists.txt file to build. These files contain some hard-coded paths
to NetCDF and HDF5 locations and some hard-coded compiler flags. These will need to be modified to the correct locations for your
machine.

They can be built with `nvidia-hpcsdk/24.5` and
`Ninja`. Example usage is `mkdir build && cd build && cmake -GNinja ../` from these new directories.
