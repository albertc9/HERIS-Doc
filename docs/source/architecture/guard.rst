SoC Guard
=========

The guard watches the SoC and resets it when the firmware stops answering or
errors accumulate. It is the ``heris_guard`` package and is part of every
HERIS SoC build; no parameter removes it.

It has two modules. The monitor module holds a watchdog and records events
such as bus errors. The refresh module resets the SoC and keeps a record of
each reset. The guard is not reset with the SoC, so its records and a few
words of firmware state survive a reset that it issues.

Every register of the guard exists three times. Each copy is reloaded on
every clock edge from the value voted over the three.

Current Status
--------------

``heris-soc`` integrates ``heris_guard`` 1.0.0 at ``0x1A12_3000``. The board
wrappers and the simulation tops select service mode, in which the watchdog
starts only after the firmware has completed its first password round. A
program that does not use the guard runs as before.

Validation covers three layers:

* The module testbench passes its 38 tests in the Vivado simulator and in
  Questa.
* ``make smoke`` and ``make full-test`` include the two SoC tests
  ``guard_monitor`` and ``guard_restart``.
* KCU105 implementation meets timing with the guard: setup WNS 1.599 ns, hold
  WHS 0.030 ns, and no error-level DRC violations. The guard adds 6,748 LUTs
  and 2,613 flip-flops to the SoC. KC705 and Yehuo also build and meet
  timing.

The guard has not been run on a board.

Monitor Module
--------------

The watchdog is fed by rounds. A round is three passwords written in order to
``PASSWORD``. After one period without a completed round the first stage
fires: the guard raises its interrupt and stores a snapshot of the core, which
is the fetch address and four state flags. After a second period the watchdog
is expired and the refresh module resets the SoC.

The mode pin selects when the watchdog starts:

.. list-table::
   :header-rows: 1

   * - ``guard_mode_i``
     - Mode
     - Watchdog
   * - 0
     - Service
     - Armed by the first completed round. Held while the core is halted in
       debug.
   * - 1
     - Operation
     - Armed from reset. The first period is extended by the boot allowance.

The monitor module records nine events: data bus error, instruction bus
error, temperature fatal, reset of the SoC that the guard did not issue, bad
password, software alarm, and three lines reserved for the hardening (memory
word corrected, memory word uncorrectable, voter disagreement). Each event has
a sticky bit in ``CAUSE`` and a saturating 8-bit counter. Any sticky bit
raises the interrupt until the firmware clears it through ``CAUSE_CLEAR``.

Two conditions ask for a reset while the watchdog is armed:

* Too many: eight counted events more than completed rounds.
* Too long: a counted event that the firmware has not cleared. It fires
  between one and two watchdog periods after the event.

The counted events are the two bus errors, bad password, memory word
uncorrectable, and voter disagreement.

For the first data bus error the monitor module keeps the address of the
access and the fetch address at that time. For the first instruction bus
error it keeps the fetch address.

Refresh Module
--------------

Recovery is graded. The firmware carries out levels 1 and 2. The guard carries
out levels 3 and 4.

.. list-table::
   :header-rows: 1

   * - Level
     - Cleared
     - Carried out by
   * - 1
     - Nothing. Registers are rewritten, a channel is cleared, or an access is
       repeated.
     - Firmware, from the guard interrupt.
   * - 2
     - One uDMA peripheral.
     - Firmware, through the reset register of the uDMA.
   * - 3
     - The SoC. The guard keeps its records.
     - Refresh module.
   * - 4
     - The SoC and the monitor module.
     - Refresh module.

Level 3 follows an expired watchdog, "too many", "too long", or a request of
the firmware through ``RESET_REQUEST``. Level 4 follows an error in the
control path of the monitor module that the three copies cannot correct, or
one clock side of the guard that has stopped while its clock runs.

A request must be seen in four consecutive samples of the slow clock. The
reset then lasts four slow ticks, about 122 µs at 32.768 kHz. L2 accepts no
access from one tick before the reset to one tick after it, so the reset does
not interrupt a memory access. Resets do not overlap, and one request leads to
one reset.

A reset by the guard clears the core, the interconnect, the peripherals, the
uDMA, the SoC side of the debug module, the pad configuration, and the
hardware monitor. It does not clear the clock generator, the guard, the JTAG
TAPs, or the content of L2. Pad outputs return to their default state until
the firmware configures them again.

The refresh module keeps the following across its own resets:

* the causes of its resets and the first cause since the last clear;
* the number of resets since the pad reset;
* a start address for the core with its valid bit;
* a restart flag;
* four words for the firmware, ``SAVE0`` to ``SAVE3``.

After three resets in a row without a completed round the guard gives up. It
issues no further reset, drives the alarm pin high, and withdraws the start
address. A completed round ends this state.

Restart
~~~~~~~

After a reset the core starts at the address in ``ENTRY`` when ``ENTRY_VALID``
is set, and at the boot ROM otherwise. The program is still in L2, so a valid
start address makes it run again without being loaded. The runtime writes the
address and restores initialised data when an application is built with
``CONFIG_GUARD=1``. See :doc:`/software-runtime/build-and-startup`.

HERIS SoC Integration
---------------------

The guard is instantiated in ``heris-soc/hw/pulpissimo.sv`` as
``i_heris_guard``, outside the logic that it resets.

.. list-table::
   :header-rows: 1

   * - Connection
     - Implementation
   * - Register window
     - ``0x1A12_3000`` through ``0x1A12_3FFF``, defined in
       ``heris-soc/hw/includes/soc_mem_map.svh``.
   * - Interrupt
     - Line 21 of the core, in ``pulp_soc/rtl/pulp_soc/soc_peripherals.sv``.
   * - Clocks
     - The SoC clock carries the bus and the records. The slow clock carries
       the reset sequencer. Neither may be gated.
   * - Reset of the SoC
     - Three nets, voted and combined with the pad reset in
       ``heris-soc/hw/pulpissimo.sv`` ahead of the reset synchronisers.
   * - Core
     - Request, grant, error, and address of the instruction and data ports,
       the sleep line, and "halted in debug", from
       ``pulp_soc/rtl/fc/fc_subsystem.sv``.
   * - Start address
     - Selected in ``pulp_soc/rtl/pulp_soc/pulp_soc.sv``.
   * - L2
     - A quiet line, voted in ``pulp_soc.sv``. While it is high,
       ``l2_ram_multi_bank.sv`` grants no access.
   * - Temperature
     - The fatal trip of the hardware monitor.

The three hardening inputs are tied to zero until the hardened memories and
voters provide them.

Top-Level Ports
~~~~~~~~~~~~~~~

The guard adds four ports to ``pulpissimo``:

.. list-table::
   :header-rows: 1

   * - Port
     - Direction
     - Meaning
   * - ``guard_mode_i``
     - Input
     - 0 selects service mode, 1 selects operation mode.
   * - ``guard_running_o``
     - Output
     - Toggles every four slow ticks while the guard runs and no request is
       unanswered.
   * - ``guard_alarm_o``
     - Output
     - High when the chip cannot recover by itself: the guard has given up, a
       clock of the guard has stopped, the temperature is fatal, or the
       refresh module has an error that its three copies cannot correct.
   * - ``guard_rst_out_no``
     - Output
     - Low while the guard resets the SoC.

The KCU105, KC705, and Yehuo wrappers tie ``guard_mode_i`` to 0 and leave the
three outputs unconnected. No board pin is assigned. The two simulation tops
do the same; ``tb_pulp`` has the parameter ``GUARD_MODE`` for the mode pin.

Parameters
~~~~~~~~~~

.. list-table::
   :header-rows: 1

   * - Parameter of ``pulpissimo``
     - Default
     - Meaning
   * - ``GUARD_WDT_PERIOD``
     - 32768
     - Watchdog period in slow ticks.
   * - ``GUARD_BOOT_ALLOWANCE``
     - 131072
     - Slow ticks added to the first period after a reset.
   * - ``GUARD_SOC_DIV``
     - 610
     - Periods of the SoC clock in one slow tick.
   * - ``GUARD_RST_FILTER``
     - 1
     - 1: the pad reset clears the guard after three samples of the slow
       clock. 0: the pad reset clears the guard directly.

With a 32.768 kHz slow clock the defaults give a period of 1 s and a boot
allowance of 4 s.

The board wrappers set ``GUARD_RST_FILTER`` to 0, because no slow clock runs
on these boards while the reset is held. KCU105 and KC705 set
``GUARD_SOC_DIV`` to 610 and Yehuo sets it to 305. ``tb_pulp`` uses a period
of 64 ticks and a boot allowance of 256 ticks so that a directed test reaches
an expiry within milliseconds.

``GUARD_SOC_DIV`` is fixed at build time. It must match the SoC clock
frequency that the firmware runs with.

KCU105 Timing
~~~~~~~~~~~~~

The bypass mux of the slow clock has the 300 MHz board reference on its second
input. ``kcu105.xdc`` holds the select of this mux at 0 for timing analysis,
so the slow side of the guard is timed on the divided slow clock only. The
board cannot use the bypass.

Firmware Interface
------------------

The register map is in ``heris_guard/README.md``. Offsets, bit numbers,
passwords, and C accessors are in
``heris-soc/sw/pulp-runtime/include/guard.h``. Do not maintain another copy
of the register map in this manual.

The programming rules are:

* Write the three passwords of a round from different places of the main
  loop, with ``guard_password(0)``, ``guard_password(1)``, and
  ``guard_password(2)``. A loop that is stuck in one place then cannot
  complete a round.
* Use ``guard_write_protected()`` for protected registers. A protected write
  takes effect only with ``0x9E37`` in bits 31:16.
* In the interrupt handler, read ``CAUSE`` and clear the handled bits through
  ``CAUSE_CLEAR``. A counted event that stays uncleared leads to a reset.
* Ask for a reset with ``guard_request(GUARD_REQ_LEVEL3)``. The request is
  two protected writes.
* Keep state that must survive a reset in ``SAVE0`` to ``SAVE3``, with
  ``guard_save_set()`` and ``guard_save_get()``.

From one tick before a reset until one tick after it the guard accepts no
write.

Level 2 uses the reset register of the uDMA, at offset ``0x08`` of its
configuration block. It has one bit for each peripheral, and a peripheral is
held in reset while its bit is set. The UART is peripheral 0. The reset does
not stop the DMA channels of the peripheral; clear both channels first.

Verification
------------

Run the module testbench from the ``heris_guard`` repository:

.. code-block:: sh

   scripts/run_xsim.sh
   scripts/run_questa.sh

Each script runs all tests and prints one line for each failed check, a
summary, and ``RESULT: PASS`` or ``RESULT: FAIL``. The exit code is zero only
for a pass.

Run the SoC tests from ``heris-soc``:

.. code-block:: sh

   make test TEST=guard_monitor
   make test TEST=guard_restart

.. list-table::
   :header-rows: 1

   * - Test
     - Coverage
     - Pass marker
   * - ``sw/guard_monitor``
     - Password rounds, the first watchdog stage and its snapshot, the record
       of a bus error, the software alarm, test injection, the interrupt, and
       the reset of one uDMA peripheral.
     - ``GUARD MONITOR PASS``
   * - ``sw/guard_restart``
     - Four resets by the guard: expired watchdog, request of the firmware,
       "too many", and level 4 through its test hook. After each reset the
       program restarts by itself and finds its initialised data restored.
     - ``GUARD RESTART PASS``

Module verification is a prerequisite, not a substitute for the SoC tests.
After a change to the guard or to its connections, run both, then
``make kcu105``.

Known Limits
------------

* No SoC test observes the alarm pin, the running pin, or the reset-out pin.
* Level 2 has been tested only on an idle UART.
* Upsets of two copies in the same bit are not corrected.
* A debugger access that is under way when the guard resets the SoC leaves
  the debug transport waiting. The debugger has to reset it.
* The legacy JTAG memory access, used by the ``jtag_legacy`` simulation boot
  mode, can repeat its last transaction after a reset of the SoC when it has
  made an odd number of transactions since TRST. OpenOCD does not use this
  access.
* Timing of the guard in an ASIC flow has not been checked, nor that an ASIC
  synthesis keeps the three copies.
