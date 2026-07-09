Overview
========

The current bring-up target is:

* board: Xilinx KCU105
* core: CV32E40P
* FPU: enabled
* Zfinx: disabled
* default validation path: QuestaSim RTL simulation

The top-level HERIS checkout
contains ``heris-soc`` and documentation submodules. Most RTL and software
work starts inside ``heris-soc``.

Use this section to get from a fresh checkout to a local smoke test. It does
not cover final FPGA signoff or hardware lab procedure.

Development Model
-----------------

Use simulation first. Build the RTL simulator, run a small software test, and
only then move to FPGA if the change affects board-level RTL, constraints,
clocking, pad mapping, or Vivado scripts.

The fast CV32E40P smoke test uses hierarchy preloading. It is a useful
RTL/runtime check, but it is not proof that JTAG loading or physical board boot
works.

Main Paths
----------

From the repository root:

.. list-table::
   :header-rows: 1

   * - Path
     - Purpose
   * - ``heris-soc/``
     - SoC RTL, simulation, FPGA targets, runtime tests.
   * - ``heris-soc/hw/``
     - Project-local RTL, top-level wrappers, generated ROM and padframe files.
   * - ``heris-soc/target/sim/``
     - QuestaSim testbench and simulator makefiles.
   * - ``heris-soc/target/fpga/kcu105/``
     - KCU105 Vivado target, constraints, clocking IP, and board wrapper.
   * - ``heris-soc/sw/pulp-runtime/``
     - Runtime used by smoke and regression tests.
   * - ``heris-soc/sw/regression_tests/``
     - Software tests used for bring-up and regression.

