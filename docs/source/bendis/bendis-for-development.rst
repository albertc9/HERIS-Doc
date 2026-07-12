Bendis For Users
====================

This document provides a most brief overview of how to use Bendis, especially
for users who want to use it step by step without thinking too much about the
details. More details can be found in the
`Bendis Release Page <https://crates.io/crates/bendis>`_ and
`Bendis How To <https://code.ihep.ac.cn/heris/gitlab-profile/-/wikis/Bendis-How-To>`_.

.. important::

**One Word:** Edit configuration in ``bendis_workspace/``, and edit code
used only by your module in the root directory.

Always run ``bendis update`` in the root directory.

Handbook for Module Developers
-----------------------------------

Creating Sub-modules in HERIS-platform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. If you are creating and developing modules as sub-modules in HERIS-platform,
   follow the steps in this section. Otherwise, skip to
   `Inheriting Sub-modules in HERIS-platform`_ or `Tagging and Release`_.

2. Create a new blank project in the
   `HERIS-platform <https://code.ihep.ac.cn/heris/heris-platform>`_ subgroup.
   Clone it to your local machine using SSH. For example, assume that the code
   repository is named ``my-module``.

3. There are usually at least two parts of the code in your module: RTL code
   used only by this module, and RTL code used by this module as dependencies.

4. First, initialize the repository:

.. code-block:: sh

   cd ~/path_to_your_repository/my-module
   bendis init


Bendis creates a ``bendis_workspace/`` directory in the repository. This
directory is used to store the Bendis workspace. The repository will then
have a structure similar to:

.. code-block:: sh

   my-module/
   ├── bendis_workspace/       # Bendis working directory
   │   ├── .bender/            # (-) Bender cache folder, optional in Bendis configuration
   │   ├── Bender.yml          # (***) Configuration file that you need to edit
   │   ├── .bender.yml         # (***) Override configuration that you may need to edit
   │   ├── Bender.lock         # (-) Generated automatically by Bendis
   │   ├── hw/                 # (***) Some dependencies of Pulpissimo
   │   └── target/             # (***) Some dependencies of Pulpissimo
   ├── Bender.yml              # (-) Converted configuration
   ├── .bender.yml             # (-) Converted overrides using IHEP URLs
   ├── Bender.lock             # (-) Final lock file generated automatically
   ├── .bender/                # (-) Dependencies directory generated automatically
   ├── hw/                     # (-) Dependencies automatically updated from bendis_workspace/
   ├── target/                 # (-) Dependencies automatically updated from bendis_workspace/
   └── ...

Some directories and files may not be created automatically, but the final
project structure will look similar to this.

5. At the beginning, you may not need to use any other modules from
   HERIS-platform. Create a directory named ``hw/`` in the root directory
   ``my-module/`` to store RTL code used only by ``my-module``. It may contain
   top-level RTL files, testbench code, or other files used only by this
   module.

6. When starting development, you do not need to use other modules from
   HERIS-platform, so you can place all RTL code in the root-level ``hw/``
   directory.

7. If your module does not need to use other modules from HERIS-platform, skip
   to step 10.

8. When you need to use another module from HERIS-platform, such as
   ``platform-module1``, configure it in
   ``bendis_workspace/Bender.yml`` and, if necessary,
   ``bendis_workspace/.bender.yml``.

9. The
   `Pulpissimo Bender.yml example <https://code.ihep.ac.cn/heris/heris-platform/pulpissimo/-/blob/master/bendis_workspace/Bender.yml>`_
   shows a ``bendis_workspace/Bender.yml`` used in the
   `Pulpissimo <https://code.ihep.ac.cn/heris/heris-platform/pulpissimo>`_
   project.

   Read it carefully, especially the ``package`` and ``dependencies`` sections.
   These sections define what should be written in your own
   ``bendis_workspace/Bender.yml``.

   For example, to use ``platform-module1`` in your module, add an entry like
   the following:

   .. code-block:: yaml

      package:
        name: my-module
        authors:
          - "Your Name [your_email@example.com](mailto:your_email@example.com)"
          - "Cooperators [cooperators_email@example.com](mailto:cooperators_email@example.com)"

      dependencies:
        platform-module1: { git: "[git@code.ihep.ac.cn](mailto:git@code.ihep.ac.cn):heris/heris-platform/platform-module1.git", version: x.y.z }

10.  After editing ``bendis_workspace/Bender.yml`` and, if necessary,
    ``bendis_workspace/.bender.yml``, run:

    .. code-block:: zsh

       bendis update

    Run this command from the root directory, ``my-module/``.

11.  Bendis downloads dependencies from HERIS-platform. Dependencies are
    automatically updated in the root directory, ``my-module/``.

    The root-level ``hw/`` and ``target/`` directories are copied to and
    override ``bendis_workspace/hw/`` and ``bendis_workspace/target/``.

    .. warning::

       Never edit ``bendis_workspace/hw/`` or
       ``bendis_workspace/target/``. Changes in these directories will be lost
       after running ``bendis update``.

    In summary, edit RTL code used only by your module in the root directory,
    and edit Bendis configuration files in ``bendis_workspace/``.

12.  Run the following command from the root directory, ``my-module/``, to
    generate the Vivado compilation script ``compiles.tcl``:

    .. code-block:: zsh

       bendis script vivado -t vivado > compiles.tcl

13.  Open or create a Vivado project and run ``compiles.tcl`` from the Vivado
    Tcl console. The script automatically adds all RTL code from the
    sub-modules to the Vivado project as linked files:

    .. code-block:: tcl

       source ~/path_to_your_project/my-module/compiles.tcl

14.  Continue developing the module in Vivado. All RTL code and other files
    under ``hw/`` and ``target/``, together with dependencies downloaded from
    HERIS-platform and stored under ``.bender/git/``, are automatically linked
    and added to the Vivado project.

15.  Whenever you need to modify the module:

    * If the change affects only your module, edit the RTL code under the
      root-level ``hw/`` directory. There is no need to run
      ``bendis update``.

    * If you need to add dependencies or update dependency versions, edit
      ``bendis_workspace/Bender.yml`` and, if necessary,
      ``bendis_workspace/.bender.yml``. Then run ``bendis update``.

      * If no sub-modules were added or removed, and existing sub-modules do not
        need to be updated, there is no need to regenerate the Vivado script.

      * If the dependency source set changed, regenerate ``compiles.tcl`` as
        described in step 12.

Tagging and Release
~~~~~~~~~~~~~~~~~~~~~~

1. When your module is ready for release, create a Git tag. Tags are the primary
   mechanism used by Bendis to manage module versions.

2. Read the
   `GitLab tagging documentation <https://docs.gitlab.com/user/project/repository/tags/>`_
   for more information.

3. Name tags using the format ``vX.Y.Z``, where ``X``, ``Y``, and ``Z`` are
   integers. Examples include:

   * ``v0.1.0``
   * ``v1.0.0``
   * ``v2.3.4``

   A tag is a snapshot of a specific version of the module. A parent module can
   use the tag to refer to that exact version.

4. A Git tag is required. For a major version, you may also create a release on
   the GitLab Releases page.

   A tag is sufficient and is the mechanism used by Bendis to identify module
   versions. A GitLab release provides a more formal way to publish the module.

Daily Development Workflow
----------------------------

Bendis for Everyday
~~~~~~~~~~~~~~~~~~~~

During normal development, follow these steps:

1. Edit RTL code under the root-level ``hw/`` and ``target/`` directories.

2. Edit Bendis configuration files under ``bendis_workspace/`` when adding or
   updating dependencies.

3. Run the following command from the root directory, ``my-module/``, when
   dependencies need to be updated:

   .. code-block:: zsh

      bendis update

4. Run the following command from the root directory, ``my-module/``, when the
   Vivado compilation script needs to be regenerated:

   .. code-block:: zsh

      bendis script vivado -t vivado > compiles.tcl

Inheriting Sub-modules in HERIS-platform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. First, check whether the repository contains a ``bendis_workspace/``
   directory.

   If it does not, run:

   .. code-block:: zsh

      bendis init

   If it already exists, skip the rest of this section. The inherited module
   already has a valid Bendis configuration.

2. Carefully check whether the module contains RTL files outside the ``hw/``
   and ``target/`` directories. Check ``Bender.yml`` and ``.bender.yml`` to
   confirm the source paths.

   .. warning::

      If the module uses another path to store RTL files, report the issue to
      the Bendis maintainers immediately, for example Albert L. Cheung at
      ``albert.cheung@cernNOSPAMPLEASE.com``.

3. Copy ``Bender.yml`` and ``.bender.yml`` into ``bendis_workspace/`` and run:

   .. code-block:: zsh

      bendis update

4. Continue development as described in the previous section.

