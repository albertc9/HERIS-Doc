HERIS Documentation
===================

HERIS is a RISC-V SoC development platform for high-energy physics
front-end instrumentation. 
This document serves as the HERIS V2 development 
and user manual following the successful tape-out and testing of HERIS-V1. 
It covers simulation, FPGA debugging, software regression testing, and future SoC
development.

Milestone
-------------

TBD

Where To Start
--------------

* New developers: 
* RTL developers:
* Software developers: 
* Users:


Documentation Map
-----------------

The following map is the planned HERIS documentation structure. Section pages will be
added incrementally.

.. toctree::
   :maxdepth: 2
   :caption: Getting Started

   getting-started/overview
   getting-started/clone-and-submodules
   getting-started/toolchain-setup
   getting-started/environment-check
   getting-started/first-smoke-test
   getting-started/common-errors

.. toctree::
   :maxdepth: 2
   :caption: Architecture

   architecture/overview
   architecture/repository-layout
   architecture/pulpissimo-integration
   architecture/core-configuration
   architecture/memory-map
   architecture/clock-and-reset
   architecture/boot-flow

.. toctree::
   :maxdepth: 2
   :caption: RTL Development

   rtl-development/overview
   rtl-development/bender-and-bendis
   rtl-development/dependency-management
   rtl-development/generated-files
   rtl-development/local-ip-policy
   rtl-development/adding-ip
   rtl-development/modifying-pulp-ip

.. toctree::
   :maxdepth: 2
   :caption: Simulation

   simulation/overview
   simulation/questasim
   simulation/rtl-simulation-flow
   simulation/firmware-loading
   simulation/cv32e40p-smoke
   simulation/waveform-debugging

.. toctree::
   :maxdepth: 2
   :caption: Software Runtime

   software-runtime/overview
   software-runtime/riscv-gnu-toolchain
   software-runtime/runtime
   software-runtime/bootcode
   software-runtime/linker-script
   software-runtime/drivers
   software-runtime/regression-tests

.. toctree::
   :maxdepth: 2
   :caption: FPGA Flow

   fpga-flow/overview
   fpga-flow/kcu105
   fpga-flow/vivado-setup
   fpga-flow/bitstream-build
   fpga-flow/programming-the-board
   fpga-flow/fpga-debug

.. toctree::
   :maxdepth: 2
   :caption: Verification

   verification/overview
   verification/smoke-tests
   verification/software-regression
   verification/rtl-regression
   verification/pass-fail-policy

.. toctree::
   :maxdepth: 2
   :caption: Reference

   reference/tool-versions
   reference/memory-map
   reference/register-map
   reference/interrupt-map
   reference/glossary
   reference/known-limitations