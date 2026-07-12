Bendis For RTL Hardening
========================

This document provides a brief guide to using ``bendis update --hard``. This
command prepares all RTL dependencies in AegisRTL, runs the hardening script,
and makes the project use the resulting local RTL.

Use this workflow when testing:

* RTL hardening algorithms and tools.
* Simulation results after hardening.
* FPGA resource usage, timing, and performance after hardening.

.. important::

   Always run ``bendis update --hard`` from the project root directory.

Requirements
------------

1. Install Bendis 0.5.0 or later and a Bender version that supports
   ``bender script template-json``.

2. Place the AegisRTL repository next to the project root. For HERIS, the
   directory structure is:

   .. code-block:: text

      heris/
      ├── aegisrtl/
      └── heris-soc/

3. Edit dependency configuration only under ``bendis_workspace/``, as in the
   normal Bendis development workflow.

Running Hard Mode
-----------------

Run the following command from ``heris-soc/``:

.. code-block:: zsh

   bendis update --hard

Bendis first performs the normal dependency update. It then prepares a clean
working copy under ``../aegisrtl/``, collects the RTL used by simulation and
KCU105 builds, and runs:

.. code-block:: zsh

   aegisrtl/scripts/harden.sh .aegis/effective-rtl.json

The script runs with ``aegisrtl/`` as its working directory. It may modify RTL
files listed as hardening candidates directly in place. It must not rename or
delete source files, or modify package ``Bender.yml`` files.

If ``scripts/harden.sh`` does not exist, Bendis reports that hardening was
skipped and continues with an unmodified local RTL copy.

After the command finishes, ``heris-soc/Bender.yml`` and
``heris-soc/.bender.yml`` point to RTL under ``../aegisrtl/``. Normal HERIS
commands then use this local RTL. For example:

.. code-block:: zsh

   make smoke
   make kcu105

Generated Files
---------------

Bendis writes hardening information under ``aegisrtl/.aegis/``:

* ``effective-rtl.json`` lists design RTL and other compilation inputs.
* ``source-Bender.lock`` preserves the dependency sources before local path
  replacement.
* ``source-packages.json`` records the resolved source path for each package.
* ``hardening-result.json`` records whether hardening ran and which RTL files
  changed.

These files, downloaded dependencies, and copied project files under
``aegisrtl/`` are generated working data and are ignored by Git.

Returning to Normal Development
-------------------------------

To stop using the local hardening workspace, run the normal update command
from ``heris-soc/``:

.. code-block:: zsh

   bendis update

This restores the standard IHEP dependency configuration. It does not delete
the generated AegisRTL working data.

.. warning::

   Do not edit the generated ``Bender.yml`` or ``.bender.yml`` in
   ``heris-soc/`` or ``aegisrtl/``. Edit the source configuration under
   ``heris-soc/bendis_workspace/`` and run Bendis again.
