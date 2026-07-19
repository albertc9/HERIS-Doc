Overview
========

A HERIS application is a C program linked with the repository runtime. The
developer provides ``main()``. Before ``main()``, the runtime prepares the
stack, clears zero-initialized data, initializes basic SoC services, and starts
standard output. After ``main()`` returns, it flushes output and reports the
return value to the execution environment.

The current runtime is intended for bring-up, regression tests, and small
bare-metal applications. It is built into every application; there is no
separate runtime library to install.

Start Here
----------

Read :doc:`simple-runtime` for the application model and current interfaces.
Read :doc:`build-and-startup` to build, run, or add a software test. The
planned SDK entry point is described in :doc:`heris-sdk`.

Toolchain installation is documented in :doc:`/getting-started/setup`.
Hardware addresses, register fields, and peripheral behavior are documented in
``heris-soc/doc/datasheet/datasheet.pdf``. That datasheet predates the current
HERIS core and FPGA configuration; use the current RTL for changed hardware.
