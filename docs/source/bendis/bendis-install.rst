Bendis Installation
---------------------

1. Install Rust:

.. code-block:: sh

    curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh

2. You can then build and install Bender and Bendis for the current user with the following command:

.. code-block:: sh

    sudo apt update
    sudo apt install cargo
    cargo install bender
    cargo install bendis

Note that don't use ``sudo`` with ``cargo install``, as it installs to the home directory of the user.

For some Ubuntu Dist, the pre-installed rust and cargo versions tends to very old. You may need to update them first:

.. code-block:: sh

    sudo apt remove rustc cargo
    curl https://sh.rustup.rs -sSf | sh
    source $HOME/.cargo/env


And repeat the installation step again.

3. Verify installation:

.. code-block:: sh

    bender --version
    bendis --version


