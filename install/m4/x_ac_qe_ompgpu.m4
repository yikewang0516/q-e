# Copyright (C) 2001-2022 Quantum ESPRESSO Foundation
#####
#
# SYNOPSIS
#
# X_AC_QE_OMPGPU
#
# DESCRIPTION
#
# Simplified compilation for OpenMP offloading to GPUs using Cray of Intel-OneAPI compilers
# Assumes a standard installation of either of the two toolchains
# The following variables are substituted in the makefile
#    rocm_ldflags 
#    ompgpu_f90flags
#    hip_comp_suffix 
#    hip_comp_rule
#    
#
# LICENCE
# Public domain
#
#####

AC_DEFUN([X_AC_QE_OMPGPU], [

# Variables
rocm_ldflags=
ompgpu_f90flags=
hip_comp_suffixes=
hip_comp_rule_tag=
hip_comp_rule=
hip_offload_arch=
ompgpu_many_fft=
ompgpu_found="no" 
#none needed so far
ompgpu_extlibs=


#Enable OpenMPGPU compilations
AC_ARG_ENABLE(omp_gpu,
	[ --enable-omp_gpu    Enables GPU offlaoding using OpenMP],
	[omp_gpu="yes"
         ompgpu="yes"],
	[omp_gpu="no"]
)
AC_MSG_RESULT(checking if omp gpu is enabled ...  $enable-omp_gpu) 
if test "x$omp_gpu" == "xyes";then
 	ompgu="yes"
fi 


# Provide your ROCM path with this
AC_ARG_WITH([rocm],
   [AS_HELP_STRING([--with-rocm=PATH],[prefix where ROCM is installed @<:@default=no@:>@])],
   [rocm="$withval"],
   [rocm="no"])
   
AC_ARG_WITH([hip_offload_arch],
   [AS_HELP_STRING([--with-hip_offload_arch=VAL],[HIP target architecture (LUMI-G: gfx90a) @<:@default=gfx90a@:>@])],
   [hip_offload_arch=$withval],
   [hip_offload_arch="gfx90a"])

AC_ARG_WITH([omp_many_fft],
   [AS_HELP_STRING([--with-omp_many_fft=VAL],[enable/disable streamed FFTs @<:@default=yes@:>@])],
   [omp_many_fft=$withval],
   [omp_many_fft="yes"])
  
echo checking for OMPGPU with  "$arch"  "$f90"  "x$rocm" and "x$omp_many_fft" and "x$ompgpu" 
if test "x$arch"=="xcraype" && test "x$f90"=="xftn" && test "x$rocm" != "xno" && test "x$ompgpu" == "xyes"
then
   #
   # -----------------------------------
   # CHECKS
   # ------------------------------------------
   # no checks done  so far
   ompgpu_found="yes" 
   # -----------------------------------------
   # Headers and libraries
   # -----------------------------------------
   if test "$ompgpu_found"  == "yes"; then 
      try_dflags="$try_dflags -D_OPENMP -D__OPENMP_GPU -D__HIP -D__ROCBLAS"
      if test "x$omp_many_fft" == "xyes"; then   
         try_dflags="$try_dflags -D__OMP_MANY_FFT" 
      fi
      hip_comp_suffixes=".hip .o"
      hip_comp_rule_tag=".hip.o"
      hip_comp_rule="hipcc --offload-arch=$hip_offload_arch -c $<"
   fi  
   rocm_ldflags="-lstdc++ -L$rocm/hip/lib -lamdhip64 -lhsa-runtime64"
   rocm_ldflags="$rocm_ldflags -L$rocm/lib -lhipfft -lrocblas"
   rocm_ldflags="$rocm_ldflags \$(MOD_FLAG) $rocm/include/rocblas"
   
   # -----------------------------------------
   # Fortran flags
   # -----------------------------------------   
   #
   ompgpu_fflags="-fopenmp"
   ldflags="$ldflags $rocm_ldflags -fopenmp"
   f90flags="`echo $f90flags | sed 's/O3/O0/g'`" 
fi

# Announcing the new variables
AC_SUBST(rocm_ld_flags)
AC_SUBST(ompgpu_fflags)
AC_SUBST(f90flags)
AC_SUBST(hip_comp_suffixes)
AC_SUBST(hip_comp_rule_tag)
AC_SUBST(hip_comp_rule)
])
