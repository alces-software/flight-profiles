#!/bin/bash

# Wrapper for Intel Parallel Studio XE installer.

if [[ -f /tmp/parallel_studio_xe_2017_update1.tgz ]]; then
  tempdir=$(mktemp -d -t customize-parallel-studio-XXXXXX)

  pushd "$tempdir"

  cat > silent.cfg <<EOF
ACCEPT_EULA=accept
CONTINUE_WITH_OPTIONAL_ERROR=yes
PSET_INSTALL_DIR=/opt/intel
CONTINUE_WITH_INSTALLDIR_OVERWRITE=yes
PSET_MODE=install
ACTIVATION_TYPE=trial_lic
AMPLIFIER_SAMPLING_DRIVER_INSTALL_TYPE=kit
AMPLIFIER_DRIVER_ACCESS_GROUP=vtune
AMPLIFIER_DRIVER_PERMISSIONS=666
AMPLIFIER_LOAD_DRIVER=no
AMPLIFIER_C_COMPILER=/bin/gcc
AMPLIFIER_KERNEL_SRC_DIR=/lib/modules/3.10.0-327.el7.x86_64/build
AMPLIFIER_MAKE_COMMAND=/bin/make
AMPLIFIER_INSTALL_BOOT_SCRIPT=no
AMPLIFIER_DRIVER_PER_USER_MODE=no
MPSS_RESTART_STACK=no
MPSS_INSTALL_STACK=no
PHONEHOME_SEND_USAGE_DATA=no
ARCH_SELECTED=ALL
COMPONENTS=;intel-itac-common__noarch;intel-ta__x86_64;intel-tc__x86_64;intel-tc-mic__x86_64;intel-itac-common-pset__noarch;intel_clck_common__x86_64;intel_clck_analyzer__x86_64;intel_clck_collector__x86_64;intel_clck_support__noarch;intel_clck_common-pset__noarch;intel-vtune-amplifier-xe-2017-cli__i486;intel-vtune-amplifier-xe-2017-cli__x86_64;intel-vtune-amplifier-xe-2017-common__noarch;intel-vtune-amplifier-xe-2017-cli-common__noarch;intel-vtune-amplifier-xe-2017-collector-32linux__i486;intel-vtune-amplifier-xe-2017-collector-64linux__x86_64;intel-vtune-amplifier-xe-2017-doc__noarch;intel-vtune-amplifier-xe-2017-sep__noarch;intel-vtune-amplifier-xe-2017-gui-common__noarch;intel-vtune-amplifier-xe-2017-gui__x86_64;intel-vtune-amplifier-xe-2017-common-pset__noarch;intel-inspector-2017-cli__i486;intel-inspector-2017-cli__x86_64;intel-inspector-2017-cli-common__noarch;intel-inspector-2017-doc__noarch;intel-inspector-2017-gui-common__noarch;intel-inspector-2017-gui__x86_64;intel-inspector-2017-cli-pset__noarch;intel-advisor-2017-cli__i486;intel-advisor-2017-cli__x86_64;intel-advisor-2017-cli-common__noarch;intel-advisor-2017-doc__noarch;intel-advisor-2017-gui-common__noarch;intel-advisor-2017-gui__i486;intel-advisor-2017-gui__x86_64;intel-advisor-2017-cli-pset__noarch;intel-comp-l-all-vars__noarch;intel-comp-l-all-common__noarch;intel-comp-l-ps-ss-bec-wrapper__x86_64;intel-comp-l-all-wrapper__x86_64;intel-comp-l-all__x86_64;intel-comp-l-ps-ss-bec__x86_64;intel-comp-l-ps__x86_64;intel-comp-l-ps-ss__x86_64;intel-openmp-l-all__i486;intel-openmp-l-ps-ss-bec__i486;intel-openmp-l-ps__i486;intel-openmp-l-ps-libs-jp__i486;intel-openmp-l-ps-jp__i486;intel-openmp-l-all__x86_64;intel-openmp-l-ps-ss-bec__x86_64;intel-openmp-l-ps-ss__x86_64;intel-openmp-l-ps-bec__x86_64;intel-openmp-l-ps-libs__x86_64;intel-openmp-l-ps__x86_64;intel-openmp-l-ps-libs-jp__x86_64;intel-openmp-l-ps-jp__x86_64;intel-tbb-libs__noarch;intel-comp-all-doc__noarch;intel-comp-ps-doc__noarch;intel-comp-ps-doc-jp__noarch;intel-icc-doc__noarch;intel-icc-ps-doc__noarch;intel-icc-ps-doc-jp__noarch;intel-icc-ps-ss-doc__noarch;intel-ifort-ps-doc__noarch;intel-ifort-ps-doc-jp__noarch;intel-icc-l-all-common__noarch;intel-icc-l-all-common-jp__noarch;intel-icc-l-ps-ss-bec-common__noarch;intel-icc-l-ps-common__noarch;intel-icc-l-all-wrapper__x86_64;intel-icc-l-ps-ss-bec-wrapper__x86_64;intel-icc-l-all__x86_64;intel-icc-l-ps-ss__x86_64;intel-icc-l-ps__x86_64;intel-icc-l-ps-ss-bec__x86_64;intel-ifort-l-ps-common__noarch;intel-ifort-l-ps-common-jp__noarch;intel-ifort-l-ps-wrapper__x86_64;intel-ifort-l-ps-wrapper-jp__x86_64;intel-mpirt-l-ps-wrapper__x86_64;intel-ifort-l-ps-jp__x86_64;intel-ifort-l-ps__x86_64;intel-mkl-common__noarch;intel-mkl__i486;intel-mkl__x86_64;intel-mkl-rt__i486;intel-mkl-ps-rt-jp__i486;intel-mkl-rt__x86_64;intel-mkl-ps-rt-jp__x86_64;intel-mkl-doc__noarch;intel-mkl-ps-doc__noarch;intel-mkl-ps-doc-jp__noarch;intel-mkl-gnu__i486;intel-mkl-gnu__x86_64;intel-mkl-gnu-rt__i486;intel-mkl-gnu-rt__x86_64;intel-mkl-ps-cluster-64bit__x86_64;intel-mkl-ps-cluster__noarch;intel-mkl-ps-cluster-rt__x86_64;intel-mkl-ps-common__noarch;intel-mkl-ps-common-jp__noarch;intel-mkl-ps-common__i486;intel-mkl-ps-common-64bit__x86_64;intel-mkl-ps-mic__x86_64;intel-mkl-ps-mic-rt__x86_64;intel-mkl-ps-mic-rt-jp__x86_64;intel-mkl-ps-mic-cluster__x86_64;intel-mkl-ps-mic-cluster-rt__x86_64;intel-mkl-common-c__noarch;intel-mkl-common-c__i486;intel-mkl-common-c-64bit__x86_64;intel-mkl-ps-common-c__noarch;intel-mkl-doc-c__noarch;intel-mkl-ps-doc-c-jp__noarch;intel-mkl-ps-mic-c__x86_64;intel-mkl-ps-cluster-c__noarch;intel-mkl-ps-ss-tbb__i486;intel-mkl-ps-ss-tbb__x86_64;intel-mkl-ps-ss-tbb-rt__i486;intel-mkl-ps-ss-tbb-rt__x86_64;intel-mkl-ps-tbb-mic__x86_64;intel-mkl-ps-tbb-mic-rt__x86_64;intel-mkl-gnu-c__i486;intel-mkl-gnu-c__x86_64;intel-mkl-ps-common-f__noarch;intel-mkl-ps-common-f__i486;intel-mkl-ps-common-f-64bit__x86_64;intel-mkl-ps-mic-f__x86_64;intel-mkl-ps-cluster-f__noarch;intel-mkl-ps-doc-f__noarch;intel-mkl-ps-doc-f-jp__noarch;intel-mkl-ps-gnu-f-rt__i486;intel-mkl-ps-gnu-f-rt__x86_64;intel-mkl-ps-gnu-f__x86_64;intel-mkl-ps-gnu-f__i486;intel-mkl-ps-f95-common__noarch;intel-mkl-ps-f__i486;intel-mkl-ps-f__x86_64;intel-mkl-ps-f95-mic__x86_64;intel-ipp-l-common__noarch;intel-ipp-l-ps-common__noarch;intel-ipp-l-st-devel__i486;intel-ipp-l-ps-st-devel__i486;intel-ipp-l-st__i486;intel-ipp-l-st__x86_64;intel-ipp-l-st-devel__x86_64;intel-ipp-l-ps-st-devel__x86_64;intel-ipp-l-doc__noarch;intel-ipp-l-ps-doc-jp__noarch;intel-tbb-devel__noarch;intel-tbb-common__noarch;intel-tbb-ps-common__noarch;intel-tbb-common-jp__noarch;intel-tbb-doc__noarch;intel-tbb-doc-jp__noarch;intel-daal__i486;intel-daal__x86_64;intel-daal-common__noarch;intel-daal-ps-common-jp__noarch;intel-daal-doc__noarch;intel-daal-ps-doc-jp__noarch;intel-imb__x86_64;intel-mpi-rt-core__x86_64;intel-mpi-rt-mic__x86_64;intel-mpi-sdk-core__x86_64;intel-mpi-sdk-mic__x86_64;intel-mpi-doc__x86_64;intel-mpi-samples__x86_64;intel-gdb-gt__x86_64;intel-gdb-gt-doc__noarch;intel-gdb-gt-doc-jp__noarch;intel-gdb__x86_64;intel-gdb-common__noarch;intel-gdb-doc__noarch;intel-ism__noarch;intel-icsxe__noarch;intel-psf-intel__x86_64;intel-gdb-ps-doc__noarch;intel-gdb-ps-doc-jp__noarch;intel-gdb-ps-mic__x86_64;intel-gdb-ps-mic-cdt__x86_64;intel-gdb-ps-mic-mpm__x86_64;intel-gdb-ps-mic-doc__noarch;intel-gdb-ps-mic-doc-jp__noarch;intel-psxe-common__noarch;intel-psxe-doc__noarch;intel-icsxe-doc__noarch;intel-icsxe-pset
EOF
  echo "Unpacking Parallel Studio install files..."
  tar -xf /tmp/parallel_studio_xe_2017_update1.tgz

  echo "Running Intel installer..."
  ./parallel_studio_xe_2017_update1/install.sh --silent=./silent.cfg
  if [[ $? -eq 0 ]]; then
    echo "Installation completed. Intel tools available in /opt/intel/bin"
  else
    echo "Installation failed. See above for error output."
  fi

  popd

  rm -rf "$tempdir"
else
  cat <<EOF
******************************
  Please download the Intel Parallel Studio XE all-in-one installer package
  from the following URL:

  https://registrationcenter.intel.com/en/forms/?productid=2774

  Then, please copy it to /tmp/parallel_studio_xe_2017_update1.tgz and run the
  following command:

  alces customize trigger configure profile-parallel-studio-xe

  Installation will then continue.

******************************
EOF
fi
