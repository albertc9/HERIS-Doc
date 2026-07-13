Bendis Installation
===================

1. Install Bender with its recommended installer:

.. code-block:: sh

   curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh

2. Install Rust for the current user, then install Bendis:

.. code-block:: sh

   curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
   source "$HOME/.cargo/env"
   cargo install bendis

Do not use ``sudo`` with ``cargo install``. The executable is installed for
the current user under ``~/.cargo/bin``.

If ``~/.cargo/bin`` is not already on ``PATH``, add it for the current shell:

.. code-block:: sh

   export PATH="$HOME/.cargo/bin:$PATH"

3. Verify both tools:

.. code-block:: sh

   bender --version
   bendis --version

