HWPE MAC Engine
===============

The HWPE MAC engine is a small memory-to-memory accelerator used to exercise
the HERIS hardware-accelerator path. It reads signed 32-bit operands through
four TCDM ports, performs multiplication or multiply-accumulate operations,
writes the result to memory, and reports completion through the HWPE control
interface.

Unlike a DMA-fed accelerator, an HWPE operates directly on memory shared with
the core. Software exchanges pointers and configuration values with the engine
through a memory-mapped peripheral interface; input and output data remain in
shared L2 memory.

The design is intentionally compact. It is useful as an integration reference
and as a starting point for HWPE development; it is not intended to be a
high-performance MAC array.

Current Status
--------------

The current ``heris-soc`` integration pins ``hwpe-mac-engine`` 2.1.4 and
``pulp_soc`` 7.0.6. ``USE_HWPE`` is enabled by default for the generic SoC,
the two Questa simulation tops, and KCU105. KC705 remains disabled and is not
part of this integration.

The CPU-driven ``hwpe_mac_integration`` regression checks the control, event,
and shared-L2 paths. It is included in ``make full-test`` but not in the shorter
``make smoke`` suite. Module-level verification remains in the
``hwpe-mac-engine`` repository; it is a prerequisite, not a substitute for
this SoC test.

The recorded integration validation passes the focused Questa test and KCU105
implementation at an FC period of 10.000 ns. KCU105 reports setup WNS
0.000 ns, hold WHS 0.030 ns, pulse-width WPWS 0.500 ns, and no error-level DRC
violations. Setup meets the gate with no positive margin.

Operation
---------

The accelerator supports two modes. ``low32`` below means that only the low
32 bits are written; arithmetic is signed.

``simple_mult``
   Produces one output for each input pair:

   ``D[k][i] = low32((A[k][i] * B[k][i]) >>> shift)``

``scalar_prod``
   Produces one output for each vector iteration:

   ``D[k] = low32(((C[k] <<< shift) + sum(A[k][i] * B[k][i])) >>> shift)``

The left shift aligns ``C`` with the 64-bit products before accumulation. The
final right shift is arithmetic. There is no rounding, saturation, or clipping.
Overflow at the output is therefore handled by low-32-bit truncation.

Here, ``k`` selects the vector iteration and ``i`` selects an element within
that vector.

Vector length is supported from 1 through 1024. ``shift`` is supported from 0
through 31. Multiple iterations use the configured byte stride to advance the
A, B, C, and D base addresses.

Data Movement
-------------

The current streamer assigns one TCDM port to each stream:

.. list-table::
   :header-rows: 1

   * - Port
     - Stream
     - Direction
     - Transfer count per iteration
   * - 0
     - A
     - Read
     - ``length``
   * - 1
     - B
     - Read
     - ``length``
   * - 2
     - C
     - Read
     - One in ``scalar_prod``; unused in ``simple_mult``
   * - 3
     - D
     - Write
     - One in ``scalar_prod``; ``length`` in ``simple_mult``

Addresses and vector stride are byte addresses. A, B, C, and D must be
word-aligned. Each port uses request/grant flow control; read data returns on a
separate valid channel. A request that is not granted must remain asserted with
stable address, direction, byte enable, and write data.

This implementation uses the legacy HWPE-Mem/TCDM and ``hwpe-stream``
interfaces. It does not use HCI. Treat an HCI conversion as a separate design
change, not as part of enabling the existing MAC in HERIS.

Interface Contracts
~~~~~~~~~~~~~~~~~~~

Three protocols appear in the current design:

.. list-table::
   :header-rows: 1

   * - Protocol
     - Boundary
     - Transaction
   * - HWPE-Stream
     - Streamer to compute engine
     - ``valid && ready``
   * - HWPE-Mem
     - Streamer to L2/TCDM
     - ``req && gnt``, followed by a read response
   * - HWPE-Periph
     - SoC control interconnect to ``mac_ctrl``
     - ``req && gnt`` with ``id`` and ``r_id``

On HWPE-Stream, a valid payload must remain stable until it is accepted.
``valid`` must not depend combinationally on ``ready``, and it may deassert
only after a handshake. These rules apply to the A/B/C/D streams and the
pipeline handshakes inside ``mac_engine``.

An HWPE-Mem request is accepted only on ``req && gnt``. An accepted read must
return ``r_valid`` and ``r_data`` in the following cycle; a memory that cannot
meet this latency must delay ``gnt``. The accelerator must not depend on
``r_valid`` after a write because that behavior is not uniform across TCDM
implementations.

RTL Structure
-------------

.. figure:: /_static/hwpe-mac-rtl.svg
   :alt: HWPE MAC control and data paths
   :align: center
   :width: 100%

   Control and data paths of the current HWPE MAC implementation.

The main source files are in the ``hwpe-mac-engine`` repository:

.. list-table::
   :header-rows: 1

   * - File
     - Responsibility
   * - ``rtl/mac_package.sv``
     - Register indices, control structures, limits, and FSM states.
   * - ``rtl/mac_ctrl.sv``
     - HWPE register file, two contexts, uLoop setup, and control generation.
   * - ``rtl/mac_fsm.sv``
     - Stream start, compute, iteration update, termination, and completion.
   * - ``rtl/mac_streamer.sv``
     - A/B/C sources, D sink, stream FIFOs, and four TCDM adapters.
   * - ``rtl/mac_engine.sv``
     - Signed multiplier, accumulator, shift, output truncation, and
       valid/ready backpressure.
   * - ``rtl/mac_top.sv``
     - Connects the controller, streamer, and compute engine.
   * - ``wrap/mac_top_wrap.sv``
     - Converts HWPE interfaces into flat signals for SoC integration.

``mac_engine`` contains the arithmetic semantics. ``mac_fsm`` owns transaction
lifetime, but it does not move data directly. ``mac_streamer`` must report D as
complete only after the final buffered write has been accepted by TCDM.

Job Configuration
-----------------

The HWPE control block exposes generic control registers followed by job
registers. The complete layout is defined by
``heris-soc/sw/pulp-runtime/include/archi/hwme/hwme_v1.h``. The corresponding
accessors are in ``include/hal/hwme/hwme_v1.h``. Do not maintain another copy
of the register map in this manual.

The current programming rules are:

* Acquire a context before writing job registers.
* Program the current uLoop bytecode in the acquired context before triggering
  the job.
* Write byte addresses for A, B, C, and D.
* Write ``LEN_ITER`` as ``length - 1``.
* Write the requested iteration count to ``NB_ITER``.
* Pack ``shift`` into bits 31:16 of ``SHIFT_SIMPLEMUL`` and the operation mode
  into bit 0.
* Write vector stride in bytes.
* Trigger only after all configuration writes complete.
* Treat ``FINISHED`` as read-to-clear and read it only after completion.
* Poll ``STATUS`` until the context is idle, or wait for the completion event.

The module testbench keeps the current, verified programming sequence in
``hwpe-mac-engine/tb/rtl/tb_mac_top.sv`` under ``program_job``. This sequence
is the reference when adding the first HERIS software test. The uLoop words
should then be wrapped by a HERIS-owned helper instead of being repeated by
applications.

A polling implementation follows this order:

.. code-block:: c

   int context = hwme_acquire_job();
   if (context < 0) {
       /* No context is available. */
   }

   /* Load the verified uLoop program from tb_mac_top.sv::program_job. */
   hwme_a_addr_set(a_addr);
   hwme_b_addr_set(b_addr);
   hwme_c_addr_set(c_addr);
   hwme_d_addr_set(d_addr);
   hwme_nb_iter_set(iterations);
   hwme_len_iter_set(length - 1);
   hwme_shift_simplemul_set(hwme_shift_simplemul_value(shift, simple_mult));
   hwme_vectstride_set(vector_stride);
   hwme_trigger_job();

   while (hwme_status_get() != 0) {
       /* Wait for the context to become idle. */
   }
   if (hwme_finished_get() != 1) {
       /* Completion count mismatch. FINISHED is read-to-clear. */
   }

Do not poll ``FINISHED``: a read clears its completion count. The
``hwpe_mac_integration`` SoC regression uses the sequence above and separately
checks event-driven completion.

HERIS SoC Integration
---------------------

The integration path crosses the HERIS top and the ``pulp_soc`` dependency:

.. code-block:: text

   heris-soc/hw/pulpissimo.sv
       -> heris-soc/hw/soc_domain.sv
       -> pulp_soc/rtl/pulp_soc/pulp_soc.sv
       -> pulp_soc/rtl/fc/fc_subsystem.sv
       -> pulp_soc/rtl/fc/fc_hwpe.sv
       -> hwpe-mac-engine/wrap/mac_top_wrap.sv

``USE_HWPE`` is propagated through this chain. When it is zero,
``fc_subsystem`` does not instantiate ``fc_hwpe`` and ties off the HWPE APB,
event, and four TCDM paths.

The current HERIS address window is ``0x1A10_C000`` through ``0x1A10_CFFF``.
The definitions are in ``heris-soc/hw/includes/soc_mem_map.svh`` and
``periph_bus_defines.sv``. The software base address is derived from
``ARCHI_FC_HWPE_ADDR``. SoC event lines 140 and 141 are reserved for FC HWPE
events in the runtime properties.

The four HWPE TCDM masters enter the L2 interconnect. They are not private
memories, so SoC validation must cover contention with normal core traffic and
must use addresses visible through the interleaved L2 path.

Default Enablement
~~~~~~~~~~~~~~~~~~

``USE_HWPE`` is enabled by default at these integration points:

* ``heris-soc/hw/pulpissimo.sv``
* ``heris-soc/target/sim/tb/tb_pulp_simple.sv``
* ``heris-soc/target/sim/tb/tb_pulp.sv``
* ``heris-soc/target/fpga/kcu105/rtl/xilinx_pulpissimo.v``

The KCU105 wrapper sets the parameter explicitly. KC705 remains at zero.

Adapter Contract
~~~~~~~~~~~~~~~~

``pulp_soc/rtl/fc/fc_hwpe.sv`` owns the SoC adapter. It requires exactly four
TCDM master ports, assigns the FC core-0 peripheral ID, connects both core-0
completion events, and leaves the two hardware job contexts in the MAC
controller. The current HERIS integration does not expose a core-1 claim path.

Do not edit files under ``heris-soc/.bender``. They are generated dependency
checkouts. Change the owning dependency repository, update the dependency
through ``heris-soc/bendis_workspace``, and review ``Bender.yml`` and
``Bender.lock`` together. See :doc:`/bendis/bendis-for-development`.

Development Guide
-----------------

Use the change boundary to select the implementation and verification work:

.. list-table::
   :header-rows: 1

   * - Change
     - Primary code
     - Required focused coverage
   * - Arithmetic or output format
     - ``mac_engine.sv`` and ``tb/reference.py``
     - Signed boundary, shift, truncation, and both modes.
   * - Vector length or iteration behavior
     - ``mac_package.sv``, ``mac_ctrl.sv``, and ``mac_fsm.sv``
     - Length 1 and 1024, multiple iterations, and stride.
   * - TCDM or buffering
     - ``mac_streamer.sv`` and ``mac_top_wrap.sv``
     - Per-port stalls, stable requests, final D write, and canaries.
   * - Context or completion control
     - ``mac_ctrl.sv``, ``mac_fsm.sv``, and ``hwpe-ctrl``
     - Consecutive jobs, core/context queueing, events, and ``FINISHED``.
   * - SoC wrapper or address path
     - ``pulp_soc/rtl/fc`` and HERIS target tops
     - APB access, L2 traffic, event routing, and normal SoC smoke.
   * - Dependency version
     - ``heris-soc/bendis_workspace``
     - Clean Bender resolution, module acceptance, and enabled SoC simulation.

When behavior changes, update the Python reference model or add a directed test
before changing the RTL. Ordinary arithmetic cases belong in ``TEST_REGISTRY``
in ``tb/run.py``. Stateful behavior belongs in an explicit ``ScenarioCase``.

Module Verification
-------------------

Run fast, focused feedback locally from the ``hwpe-mac-engine`` repository:

.. code-block:: sh

   make test-list
   make test TEST=scalar_prod_basic SIM=verilator
   make smoke SIM=verilator

Verilator is a development backend. It does not replace the four-state
acceptance run. Run the complete gate on a server with Questa:

.. code-block:: sh

   make full-test SIM=vsim REBUILD=1

A passing result currently ends with:

.. code-block:: text

   COMPLETE TEST SET PASS passed=23 total=23

The complete set covers both modes, lengths 1 and 1024, shift 31, signed
extremes, truncation, per-port TCDM stalls, three jobs without reset, active
reset and recovery, core 1, two queued contexts, and the retained legacy
vectors. ``make test-list`` is the authoritative inventory.

Each Questa run writes its record under
``tb/results/vsim/<test-name>/run.log``. The backend summary is
``tb/results/vsim/summary.txt``. A valid acceptance run requires
``verdict: PASS``, process exit code zero, and ``timed_out: false`` for every
test.

SoC Integration Gate
--------------------

Module acceptance is a prerequisite, not the SoC gate. Integration is complete
only after all of the following are demonstrated:

#. ``heris-soc`` pins the intended verified MAC revision.
#. The Questa simulation top enables ``USE_HWPE`` and builds from a clean
   Bender checkout.
#. The ``hwpe_mac_integration`` regression programs both modes and checks exact
   D memory and guard words.
#. Polling completion and event 140 agree with the software-visible model.
#. HWPE traffic runs correctly through interleaved L2 while the core is active.
#. The existing HERIS smoke and full-test suites remain green.
#. KCU105 builds with HWPE enabled, produces its required artifacts, and passes
   setup, hold, pulse-width, and DRC gates.

Run the SoC test directly or through the complete regression:

.. code-block:: sh

   make test TEST=hwpe_mac_integration REBUILD=1
   make full-test REBUILD=1

The test verifies presence and reset state, acquires both context IDs, runs
``simple_mult`` by polling, and runs ``scalar_prod`` with event 140. Its exact
pass marker is ``HWPE MAC INTEGRATION PASS``.

For server acceptance, use the ordered validation command documented in
:doc:`/verification/ci-pipeline`. The current 2.1.4 integration has passed this
gate with Questa and Vivado. Re-run it after an RTL, dependency, target, or
validation change.
