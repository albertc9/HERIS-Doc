Build and Startup
=================

Work from ``heris-soc``. List the registered software tests, run one test, then
run the full smoke set:

.. code-block:: sh

   make test-list
   make test TEST=hello
   make test-env
   make smoke

``make test-env`` prints the effective compiler, ISA, ABI, runtime profile, and
simulator path without building an application. The repository sets those
values for every test. Do not export internal runtime variables in shell startup
files.

Adding a Test
-------------

Use ``sw/regression_tests/hello`` as the smallest application example. Create a
new directory under ``sw/regression_tests``, keep its source and Makefile
together, and register its short name, directory, and pass string in
``scripts/smoke/cv32e40p.sh``. The new test can then run through:

.. code-block:: sh

   make test TEST=<name>

Do not add a test to the default smoke list until it passes reliably with the
current CV32E40P profile and finishes within a bounded timeout.

Build Flow
----------

Runtime sources are compiled and linked with each application:

.. code-block:: text

   application sources
       + runtime sources
       + target and linker configuration
       -> application ELF
       -> target loading data
       -> execution

The default flow builds a 32-bit CV32E40P application with
``-march=rv32imfc_xcorev`` and ``-mabi=ilp32f``. The compiler executable prefix
does not determine the generated program width. Toolchain setup is documented
in :doc:`/getting-started/setup`.

Startup
-------

The application enters the runtime at ``_start``:

.. code-block:: text

   _start
     -> clear zero-initialized data
     -> initialize the stack, SoC, interrupts, allocation, and I/O
     -> run constructors
     -> call main()
     -> flush I/O and run destructors
     -> report the exit status

The linker places vectors, code, data, and the stack in L2 memory. The linker
configuration defines software section placement; the SoC datasheet defines
the physical memory map. Applications should not define ``_start`` or replace
the vector table unless they also provide the complete initialization path.

Simulation Boundary
-------------------

The default smoke flow loads the application through the testbench. Runtime
startup uses fixed clock values and does not program the hardware FLLs.

This flow does not validate Boot ROM execution, debug loading, external flash
loading, or physical board boot.
