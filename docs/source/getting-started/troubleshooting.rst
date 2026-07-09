Troubleshooting
===============

Missing Submodules
------------------

If expected directories under ``heris-soc/sw/`` are empty or incomplete, run:

.. code-block:: sh

   git submodule update --init --recursive

If a submodule itself has local work, inspect it before changing pointers:

.. code-block:: sh

   git -C heris-soc status --short --branch
   git -C heris-soc submodule status --recursive

Tool Not Found
--------------

The smoke script expects ``vsim`` and ``riscv64-unknown-elf-gcc`` on ``PATH``.
Check:

.. code-block:: sh

   command -v vsim
   command -v riscv64-unknown-elf-gcc

If the RISC-V tools are installed under ``/opt/riscv``, export:

.. code-block:: sh

   export PULP_RISCV_GCC_TOOLCHAIN=/opt/riscv
   export PATH=$PULP_RISCV_GCC_TOOLCHAIN/bin:$PATH

Stale Simulator Build
---------------------

If the simulator was built for a different core configuration, force a rebuild:

.. code-block:: sh

   cd heris-soc
   ./run_cv32e40p_smoke.sh --rebuild

The expected current build configuration is:

* ``CORE_TYPE=0``
* ``USE_FPU=1``
* ``USE_ZFINX=0``
* ``USE_VIPS=0``

Wrong Test For The Configuration
--------------------------------

Some tests assume XPULP-only instructions, cluster features, external VIPs, or
peripheral models that are not part of the default smoke path. Start from
``hello``, ``fpu_smoke``, UART, and the integer tests listed in the smoke
script before debugging larger regressions.

FPGA Build Used Too Early
-------------------------

Use Vivado only when the change affects the KCU105 target, board constraints,
clocking, pad mapping, or FPGA wrapper. A passing bitstream is not a substitute
for a software smoke test, and the smoke test is not a substitute for board
debug.

Generated Files
---------------

Do not hand-edit generated ROM, padframe, or Bender output. Regenerate through
the relevant make target, then review the generated diff.

