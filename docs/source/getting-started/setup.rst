Setup
=====

Clone
-----

Clone HERIS with submodules:

.. code-block:: sh

   git clone --recurse-submodules git@code.ihep.ac.cn:heris/heris.git
   cd heris

If the repository was cloned without submodules, initialize them before
building:

.. code-block:: sh

   git submodule update --init --recursive

The ``heris-soc`` tree also contains submodules, including the runtime and
regression tests. Keep submodule changes explicit: commit inside the submodule
first, then commit the updated pointer in the parent repository.

Required Tools
--------------

The normal local flow expects:

* Siemens QuestaSim, available as ``vsim``.
* A RISC-V GCC toolchain. The current local convention is ``/opt/riscv`` with
  ``riscv64-unknown-elf-*`` tools.
* Bender for RTL source-list generation and dependency resolution.
* Bendis when dependency declarations need to be changed.
* Xilinx Vivado for FPGA builds.
* Python ``pyelftools`` for runtime ELF handling.

Check the tool paths:

.. code-block:: sh

   vsim -version
   bender --version
   bendis --version
   /opt/riscv/bin/riscv64-unknown-elf-gcc --version
   python3 -c 'from elftools.elf.elffile import ELFFile'

Set the RISC-V toolchain path before running software tests:

.. code-block:: sh

   export PULP_RISCV_GCC_TOOLCHAIN=/opt/riscv
   export PATH=$PULP_RISCV_GCC_TOOLCHAIN/bin:$PATH

Dependency Rules
----------------

Do not edit generated dependency checkouts under ``heris-soc/.bender/``.
Normal builds call Bender internally.

Use Bendis only when dependency declarations change. Ordinary RTL, simulation,
software, board-target, and documentation changes do not require Bendis.

Generated files are part of the hardware flow. Regenerate them through make
targets instead of editing generated output by hand:

.. code-block:: sh

   cd heris-soc
   make hw
