First Smoke Test
================

Build The Simulator
-------------------

From ``heris-soc``:

.. code-block:: sh

   make -C target/sim/questasim build

This builds the QuestaSim platform under ``heris-soc/build/questasim``.

Run The CV32E40P Smoke
----------------------

From ``heris-soc``:

.. code-block:: sh

   ./run_cv32e40p_smoke.sh

Use ``--rebuild`` when the optimized simulator should be rebuilt:

.. code-block:: sh

   ./run_cv32e40p_smoke.sh --rebuild

The smoke script checks the environment, builds or reuses the QuestaSim
platform, and runs a bounded set of software tests:

* ``hello``
* ``fpu_smoke``
* ``riscv_tests/testALU``
* ``riscv_tests/testMUL``
* ``riscv_tests/testMisaligned``
* ``peripherals/uart``
* ``sequential_bare_tests/fibonacci``
* ``sequential_bare_tests/bubblesort``
* ``sequential_bare_tests/crc32``

The script pins ``PULPRT_HOME`` and ``PULP_SDK_HOME`` to the repo-local
``sw/pulp-runtime`` tree and uses ``PULPRT_TARGET=pulpissimo`` and
``PULPRUN_TARGET=pulpissimo``. The ``pulpissimo`` runtime target name is
intentional for this migrated repository.

To inspect the effective smoke environment without running the tests:

.. code-block:: sh

   ./run_cv32e40p_smoke.sh --print-env

Logs are written under ``heris-soc/notes/logs/``.

The current Ubuntu validation run passed the full bounded smoke set with
``Results: 10 passed, 0 failed``. The smoke path uses the short CRC32 setting
from the script, ``CRC32_REPEAT_FACTOR=32``.

KCU105 Bitstream Check
---------------------

From ``heris-soc``:

.. code-block:: sh

   make kcu105

The expected top-level outputs are ``target/fpga/kcu105.bit`` and
``target/fpga/kcu105.bin``. In the current validation run, Vivado completed
``write_bitstream`` successfully, met timing with ``WNS=2.060 ns`` and
``WHS=0.030 ns``, and reported ``0 Errors`` at bitstream DRC.

Run One Test
------------

Use the same variable pattern as the smoke script for a single test:

.. code-block:: sh

   PULPRT_HOME=$PWD/sw/pulp-runtime \
   PULP_SDK_HOME=$PWD/sw/pulp-runtime \
   PULPRT_TARGET=pulpissimo \
   PULPRUN_TARGET=pulpissimo \
   make -C sw/regression_tests/hello clean all run \
     USE_CV32E40P=1 \
     platform=rtl \
     runtime_platform=fpga \
     bootmode=fast_debug \
     CONFIG_IO_UART=0 \
     CONFIG_PLUSARG_SIM=1 \
     PULP_RISCV_GCC_TOOLCHAIN=/opt/riscv \
     PULP_CC=riscv64-unknown-elf-gcc \
     PULP_LD=riscv64-unknown-elf-gcc \
     PULP_AR=riscv64-unknown-elf-ar \
     PULP_OBJDUMP=riscv64-unknown-elf-objdump \
     PULP_ARCH_CFLAGS='-march=rv32imfc_xcorev -mabi=ilp32f -mno-pulp-hwloop' \
     PULP_ARCH_LDFLAGS='-march=rv32imfc_xcorev -mabi=ilp32f -mno-pulp-hwloop' \
     VSIM_PATH=/home/work1/Works/heris/heris-soc/build/questasim \
     VSIM=vsim

Not every regression test is valid for the current single-core KCU105/CV32E40P
configuration. Cluster-oriented tests and tests that require peripheral VIPs
need separate setup.

What The Smoke Does Not Prove
-----------------------------

The smoke script uses ``fast_debug`` preloading. It verifies a useful
RTL/runtime path, but it does not prove:

* OpenOCD or GDB loading through RISC-V debug JTAG.
* physical KCU105 boot.
* QSPI boot.
* external peripheral behavior.
