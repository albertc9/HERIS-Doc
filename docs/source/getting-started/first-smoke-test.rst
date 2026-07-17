First Smoke Test
================

After setup, run the first validation commands from ``heris-soc``. Start with
the CV32E40P RTL smoke. Then run the KCU105 FPGA build.

Run The CV32E40P Smoke
----------------------

From the top-level HERIS checkout:

.. code-block:: sh

   cd heris-soc
   make smoke

This is the normal first validation command. It checks the required tools,
automatically builds or reuses the appropriate QuestaSim model under
``build/questasim``, and runs the bounded CV32E40P software smoke set.

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

Run One Test
------------

List the supported short names and run one test with the same CV32E40P profile:

.. code-block:: sh

   make test-list
   make test TEST=hello

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

Build The KCU105 FPGA Target
----------------------------

Run the KCU105 FPGA build from ``heris-soc``:

.. code-block:: sh

   make kcu105

The build produces:

* ``target/fpga/kcu105.bit``
* ``target/fpga/kcu105.bin``

This checks the Vivado FPGA flow. It does not program the board or prove
physical boot. However, this at least shows that you can move forward.
