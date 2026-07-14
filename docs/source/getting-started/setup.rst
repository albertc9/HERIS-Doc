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

The HERIS software flow uses the PULP RISC-V GNU/Newlib cross compiler. Build
it from the HERIS toolchain repository with submodules enabled.

Install the build dependencies first. On Ubuntu:

.. code-block:: sh

   sudo apt-get install autoconf automake autotools-dev curl python3 \
     libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex \
     texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

On Fedora, CentOS, or RHEL:

.. code-block:: sh

   sudo yum install autoconf automake python3 libmpc-devel mpfr-devel \
     gmp-devel gawk bison flex texinfo patchutils gcc gcc-c++ \
     zlib-devel expat-devel

Get the sources:

.. code-block:: sh

   git clone --recursive git@code.ihep.ac.cn:heris/heris-platform/riscv-gnu-toolchain.git
   cd riscv-gnu-toolchain

If the repository was cloned without submodules:

.. code-block:: sh

   git submodule update --init --recursive

Choose an empty install prefix. Use a writable path unless you intend to install
under ``/opt`` with administrator permissions:

.. code-block:: sh

   export RISCV=$HOME/tools/heris-riscv
   mkdir -p "$RISCV"
   export PATH=$RISCV/bin:$PATH

Configure and build the Newlib toolchain:

.. code-block:: sh

   ./configure --prefix="$RISCV" --with-arch=rv32imfcxpulpv3 --with-abi=ilp32 --enable-multilib
   make -j$(nproc)

The build downloads upstream sources, patches them, and installs the toolchain
under ``$RISCV``. Reserve several GiB of disk space.

Check that the compiler is visible:

.. code-block:: sh

   command -v riscv64-unknown-elf-gcc
   riscv64-unknown-elf-gcc --target=help

Use a fresh prefix when rebuilding with a different ``--with-arch`` or
``--with-abi``. Reusing a prefix from another Newlib toolchain can leave
incompatible libraries in place.

Do not globally export HERIS-internal variables such as ``PULP_ARCH_CFLAGS``
or ``VSIM_PATH``. The repository test scripts select the CV32E40P ISA, ABI,
runtime target, and simulator build path.

See more details `here <https://code.ihep.ac.cn/heris/heris-platform/riscv-gnu-toolchain/-/blob/master/README.md>`_.

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
