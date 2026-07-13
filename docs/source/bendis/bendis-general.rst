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
   Default: ``1``. Reports a warning when required entries are missing from
   ``bendis_workspace/.gitignore``. Set it to ``0`` to disable the warning.
   Bendis still maintains ignore entries for detected local dependency
   directories during an update.

The ``first_run`` and ``version`` fields are internal state used for the
welcome message and version-change notice. They normally do not need manual
changes.

Update Behavior
---------------

``bendis update`` performs the following operations:

1. Detect local ``path`` dependencies in ``bendis_workspace/Bender.yml`` and
   ``bendis_workspace/.bender.yml``. Their top-level directories are copied
   from the project root into the workspace. If no ``path`` dependency is found,
   Bendis uses ``hw/`` and ``target/``.
2. Run ``bender update`` in ``bendis_workspace/``. This is the dependency
   version-resolution step.
3. Convert matching PULP Platform GitHub sources to the IHEP mirrors and write
   the generated ``Bender.yml``, ``.bender.yml``, and exact ``Bender.lock`` to
   the project root.
4. Materialize the root checkout from local Bender data. Remote access is used
   only when the local checkout cannot be completed.
5. Verify the generated files and remove numbered conflict copies of generated
   Bender files. Possible conflict copies of editable workspace configuration
   are reported but not removed.

Keep ``storage_saving_mode = 0`` for normal development. Enable it only when
disk usage is more important than reusing the workspace cache.

Editable and Generated Files
----------------------------

Edit dependency declarations only in:

* ``bendis_workspace/Bender.yml``
* ``bendis_workspace/.bender.yml``

Edit project-local RTL and other local dependency files in their root-level
directories. Do not edit generated root configuration, lock files, or files
under ``.bender/``. A later update may replace them.

Other Bender Commands
---------------------

Commands other than ``init``, ``update``, and ``config`` are passed directly
to Bender without additional standard output. For example:

.. code-block:: sh

   bendis script vivado -t vivado > compiles.tcl

This is equivalent to running the same command with ``bender``.
