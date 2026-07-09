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

The runtime ELF utilities also require Python ``pyelftools``. Check:

.. code-block:: sh

   python3 -c 'from elftools.elf.elffile import ELFFile'

Wrong Runtime Target
--------------------

For this migrated repository, the CV32E40P smoke flow must use the repo-local
runtime and the ``pulpissimo`` runtime target:

.. code-block:: sh

   cd heris-soc
   ./run_cv32e40p_smoke.sh --print-env

If a log shows ``chips/pulp/config.h`` or ``chips/pulp/link.ld``, the runtime
target is wrong. Clear stale shell variables that point at the old
``pulpissimo`` checkout, or rely on ``run_cv32e40p_smoke.sh`` to set
``PULPRT_HOME``, ``PULP_SDK_HOME``, ``PULPRT_TARGET``, and
``PULPRUN_TARGET``.

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
