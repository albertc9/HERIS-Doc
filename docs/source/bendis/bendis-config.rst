Bendis Configuration and Behavior
=================================

Bendis keeps editable dependency declarations under ``bendis_workspace/`` and
writes the configuration used by Bender to the project root. Run Bendis from
the project root.

Global Configuration
--------------------

Open the global configuration with:

.. code-block:: sh

   bendis config

The default locations are:

* Linux: ``$XDG_CONFIG_HOME/bendis/config.toml``, or
  ``~/.config/bendis/config.toml`` when ``XDG_CONFIG_HOME`` is not set.
* macOS: ``~/Library/Application Support/bendis/config.toml``.
* Windows: ``%APPDATA%\bendis\config.toml``.

Bendis uses ``$EDITOR``, then ``$VISUAL``, and falls back to ``nano``.

The user-facing settings are:

``silent_mode``
   Default: ``1``. Suppresses Bender output while dependencies are resolved in
   ``bendis_workspace/``. Full command output is still shown when that step
   fails. Set it to ``0`` when diagnosing dependency or network problems.

``storage_saving_mode``
   Default: ``0``. Keeps ``bendis_workspace/.bender/`` so later updates can
   reuse the local cache. Set it to ``1`` to remove that directory after a
   successful dependency update. This setting does not remove the project
   root ``.bender/`` or the AegisRTL cache.

``gitignore_check``
   Default: ``1``. Retained for configuration compatibility. Bendis always
   maintains its delimited block in ``bendis_workspace/.gitignore`` during an
   update.

The ``first_run`` and ``version`` fields are internal compatibility state.
They do not need manual changes.

Initialization
--------------

Initialize a project from its root directory:

.. code-block:: sh

   bendis init

If ``bendis_workspace/`` already exists, interactive initialization asks for
confirmation and defaults to No. For an intentional non-interactive
replacement, use:

.. code-block:: sh

   bendis init --force

This replaces the complete workspace. Commit or back up editable workspace
configuration first.

Editable and Generated Files
----------------------------

Edit dependency declarations only in:

* ``bendis_workspace/Bender.yml``
* ``bendis_workspace/.bender.yml``

Edit project-local RTL and other local dependency files in their root-level
directories. Do not edit generated root configuration, lock files, or files
under ``.bender/``. A later update may replace them.

Inspect the active project-local input set without changing files:

.. code-block:: sh

   bendis local-inputs
   bendis local-inputs --json

The JSON form is intended for tools. Both forms read the authoritative
``bendis_workspace/Bender.yml`` and optional
``bendis_workspace/.bender.yml``.

Workspace Ignore Rules
----------------------

During ``bendis update``, Bendis maintains only a delimited block in
``bendis_workspace/.gitignore``. For example:

.. code-block:: text

   # BEGIN BENDIS MANAGED INPUTS
   /.bender/
   /.bendis/
   /hw/
   # END BENDIS MANAGED INPUTS

The mirrored input entries are derived from the active Bender configuration.
Bendis preserves user rules outside this block and does not modify the project-root ``.gitignore``.

Other Bender Commands
---------------------

Commands other than ``init``, ``update``, and ``config`` are passed directly
to Bender without additional standard output. For example:

.. code-block:: sh

   bendis script vivado -t vivado > compiles.tcl

This is equivalent to running the same command with ``bender``.
