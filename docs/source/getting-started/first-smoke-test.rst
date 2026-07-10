First Smoke Test
================

Run The CV32E40P Smoke
----------------------

From the top-level HERIS checkout:

.. code-block:: sh

   cd heris-soc
   make smoke

This is the normal first validation command. It checks the required tools,
builds or reuses the QuestaSim model under ``build/questasim``, and runs the
bounded CV32E40P software smoke set.

The current smoke profile is fixed to:

* ``CORE_TYPE=0``: CV32E40P.
* ``USE_FPU=1``: single-precision floating-point support enabled.
* ``USE_ZFINX=0``: a separate floating-point register file and ``ilp32f`` ABI.
* ``USE_VIPS=0``: optional peripheral VIP models disabled.
* ``bootmode=fast_debug``: testbench hierarchy preload for fast simulation.

The smoke set contains:

* ``hello``
* ``fpu_smoke``
* ``testALU``
* ``testMUL``
* ``testMisaligned``
* ``uart``
* ``fibonacci``
* ``bubblesort``
* ``crc32``

The platform build plus these nine tests produce the expected final summary:

.. code-block:: text

   Results: 10 passed, 0 failed
   SMOKE PASSED

Logs are written under ``heris-soc/notes/logs/``.

Rebuild The Simulation Model
----------------------------

The normal command reuses a cached ``vopt_tb`` when its profile matches. Force
RTL recompilation after changing RTL, the testbench, Bender source dependencies,
or the core/FPU/Zfinx configuration:

.. code-block:: sh

   make smoke REBUILD=1

Changing only a C regression test does not require ``REBUILD=1``. The test's
``clean all run`` flow recompiles the software and loads it into the existing
simulation model.

Run One Test
------------

List the supported short names and run one test with the same CV32E40P profile:

.. code-block:: sh

   make test-list
   make test TEST=hello

Use ``REBUILD=1`` only when the hardware simulation model also needs to be
rebuilt:

.. code-block:: sh

   make test TEST=hello REBUILD=1

Inspect The Effective Configuration
-----------------------------------

The test scripts own the compiler names, ISA and ABI flags, runtime target, and
simulator path. Inspect their effective values without building or running a
test:

.. code-block:: sh

   make test-env

The runtime included with HERIS still calls its compatible SoC target
``pulpissimo``. This is an internal compatibility identifier; it does not run
the separate legacy ``pulpissimo`` checkout.

What The Smoke Proves
---------------------

Passing the smoke test shows that the CV32E40P, FPU, basic memory and bus path,
runtime, software toolchain, QuestaSim model, and selected UART path work
together for the covered cases.

The smoke uses ``fast_debug`` hierarchy preload. It does not prove:

* OpenOCD or GDB loading through RISC-V debug JTAG.
* Physical KCU105 boot or FPGA timing closure.
* QSPI boot.
* External peripheral behavior or tests that require optional VIP models.
* Regression tests outside the listed bounded set.
