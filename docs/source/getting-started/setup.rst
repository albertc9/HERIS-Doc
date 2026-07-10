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

The CV32E40P smoke flow expects a Linux environment with:

* Siemens QuestaSim, available as ``vsim``.
* A RISC-V GCC toolchain providing ``riscv64-unknown-elf-*`` tools. See the
  `HERIS toolchain guide <https://code.ihep.ac.cn/heris/heris-platform/riscv-gnu-toolchain>`_.
* `Bender <https://github.com/pulp-platform/bender>`_.
* `Bendis <https://crates.io/crates/bendis>`_.
* Python ``pyelftools`` for runtime ELF handling.
* GNU ``timeout`` and ``setsid``, used to bound simulation runs.

Put the toolchain, Bender, and QuestaSim executables on ``PATH``. Their install
directories do not need to match another developer's machine. Check the smoke
prerequisites with:

.. code-block:: sh

   command -v bender
   command -v vsim
   command -v riscv64-unknown-elf-gcc
   command -v riscv64-unknown-elf-ar
   command -v riscv64-unknown-elf-objdump
   command -v timeout
   command -v setsid
   python3 -c 'from elftools.elf.elffile import ELFFile'

If the RISC-V tools are installed outside the current ``PATH``, add their
``bin`` directory. For example:

.. code-block:: sh

   export PATH=/path/to/riscv-toolchain/bin:$PATH

Do not globally export HERIS-internal variables such as ``PULP_ARCH_CFLAGS``
or ``VSIM_PATH``. The repository test scripts select the CV32E40P ISA, ABI,
runtime target, and simulator build path.

Dependency Rules
----------------

Do not edit generated dependency checkouts under ``heris-soc/.bender/``.
Normal builds call Bender internally.

Use Bendis only when dependency declarations change, including a new version
release. Ordinary RTL, simulation, software, board-target, and documentation
changes do not require Bendis.

Generated files are part of the hardware flow. Regenerate them through make
targets instead of editing generated output by hand:

.. code-block:: sh

   cd heris-soc
   make hw
