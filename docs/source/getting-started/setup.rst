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

HERIS development expects a Linux environment with:

* Siemens QuestaSim, available as ``vsim``.
* A RISC-V GCC toolchain providing ``riscv64-unknown-elf-*`` tools. See the
  `HERIS toolchain guide <https://code.ihep.ac.cn/heris/heris-platform/riscv-gnu-toolchain>`_.
* `Bendis <https://crates.io/crates/bendis>`_. See
  :doc:`/bendis/bendis-install`.
* `Bender <https://github.com/pulp-platform/bender>`_ by ``cargo install bender``.
* Python ``pyelftools`` for runtime ELF handling.
* GNU ``timeout`` and ``setsid``, by ``sudo apt install -y coreutils util-linux``.

Put the toolchain and QuestaSim executables on ``PATH``. Check the
setup with:

.. code-block:: sh

   command -v bendis
   command -v bender
   command -v vsim
   command -v riscv64-unknown-elf-gcc
   command -v riscv64-unknown-elf-ar
   command -v riscv64-unknown-elf-objdump
   command -v timeout
   command -v setsid
   python3 -c 'from elftools.elf.elffile import ELFFile'

If ``pyelftools`` is missing, install it for the Python used above:

.. code-block:: sh

   python3 -m pip install --user pyelftools

If the RISC-V tools are installed outside the current ``PATH``, add their
``bin`` directory. For example:

.. code-block:: sh

   export PATH=/path/to/riscv-toolchain/bin:$PATH

Do not globally export HERIS-internal variables such as ``PULP_ARCH_CFLAGS``
or ``VSIM_PATH``. The repository test scripts select the CV32E40P ISA, ABI,
runtime target, and simulator build path.

Dependency Rules
----------------

Use ``heris-soc/bendis_workspace/`` as the editable system workspace. Bendis is
the main tool for HERIS dependency and package development.

Do not edit generated dependency checkouts under ``heris-soc/.bender/``.
Normal builds consume the Bender metadata generated from the Bendis workspace.

Generated files are part of the hardware flow. Regenerate them through make
targets instead of editing generated output by hand:

.. code-block:: sh

   cd heris-soc
   make hw

Setup Complete
--------------

After the environment is configured, the first checks are:

.. code-block:: sh

   cd heris-soc
   make test-env
