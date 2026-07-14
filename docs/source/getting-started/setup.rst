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

* Siemens QuestaSim, available as ``vsim``. Ask maintainers for it.
* Xilinx Vivado v2023.2. Ask maintainers for the license. 
* A RISC-V GCC toolchain providing ``riscv64-unknown-elf-*`` tools. See below.
* `Bendis <https://crates.io/crates/bendis>`_. See
  :doc:`/bendis/bendis-install`.
* `Bender <https://github.com/pulp-platform/bender>`_ by ``cargo install bender``.
* Python ``pyelftools`` for runtime ELF handling.
* GNU ``timeout`` and ``setsid``, by ``sudo apt install -y coreutils util-linux``.

RISC-V Toolchain
----------------

Use the HERIS GCC11 PULP RISC-V GNU toolchain for the current CV32E40P target.
It is built for the ``xpulpv3`` extension set.

Install the build dependencies on Ubuntu:

.. code-block:: sh

   sudo apt-get install autoconf automake autotools-dev curl python3 \
     libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex \
     texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

Build and install the Newlib toolchain:

.. code-block:: sh

   git clone --recursive git@code.ihep.ac.cn:heris/heris-platform/riscv-gnu-toolchain.git
   cd riscv-gnu-toolchain
   ./configure --prefix=/opt/heris-riscv --with-arch=rv32imfcxpulpv3 --with-abi=ilp32 --enable-multilib
   make -j$(nproc)

Use an empty install prefix. Reusing a prefix from another RISC-V toolchain can
mix incompatible libraries.

Add the installed tools to ``PATH``:

.. code-block:: sh

   export PATH=/opt/heris-riscv/bin:$PATH

Do not globally export HERIS-internal variables such as ``PULP_ARCH_CFLAGS``
or ``VSIM_PATH``. The repository test scripts select the CV32E40P ISA, ABI,
runtime target, and simulator build path.

Environment Check
-----------------

Put the toolchain, QuestaSim, and Vivado executables on ``PATH``. Check the
setup with:

.. code-block:: sh

   command -v bendis
   command -v bender
   command -v vsim
   command -v vivado
   command -v riscv64-unknown-elf-gcc
   command -v riscv64-unknown-elf-ar
   command -v riscv64-unknown-elf-objdump
   command -v timeout
   command -v setsid
   python3 -c 'from elftools.elf.elffile import ELFFile'

If ``pyelftools`` is missing, install it for the Python used above:

.. code-block:: sh

   python3 -m pip install --user pyelftools

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
