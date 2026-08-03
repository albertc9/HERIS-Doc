CI Pipeline
===========

The ``heris-soc`` pipeline validates merge requests to ``dev`` and ``master``.
It does not run after a maintainer pushes directly to ``dev``.

Pipeline Matrix
---------------

.. list-table::
   :header-rows: 1

   * - Merge request
     - Required jobs
   * - Any current branch to ``dev``
     - MR policy, KCU105, and Smoke
   * - ``dev`` to ``master``
     - MR policy, KCU105, and Full-test

All required jobs start in the same stage and can run in parallel. Draft and
ready merge requests use the same jobs. A new commit cancels obsolete
interruptible jobs.

The MR policy job requires the source branch to contain the current target
branch. Only ``dev`` may target ``master``.

Smoke And Full-test
-------------------

The simulation jobs always request a clean platform rebuild:

.. code-block:: sh

   make smoke REBUILD=1
   make full-test REBUILD=1

Smoke runs nine CV32E40P software tests. Full-test adds
``hwpe_mac_integration``, a CPU-driven SoC test of the HWPE control, event, and
shared-L2 paths. Its pass marker is ``HWPE MAC INTEGRATION PASS``.

Each simulation job writes a JUnit report for the GitLab merge request. Test
failures are collected before the suite fails. Environment or platform build
failures stop the suite and are also recorded in JUnit.

KCU105 Gate
-----------

The KCU105 job runs ``make kcu105`` and blocks the pipeline when:

* The Vivado build fails.
* WNS, WHS, or WPWS is negative.
* Vivado reports an error-level DRC violation.
* ``kcu105.bit`` or ``kcu105.bin`` is missing or empty.
* A required timing or utilization report is missing or empty.
* The KCU105 JUnit report cannot be generated.

TNS, THS, TPWS, timing warnings, unconstrained paths, and utilization are
diagnostic information. They do not add another timing threshold.

The merge request evidence includes:

* Implementation status and duration.
* Setup WNS and TNS, hold WHS and THS, and pulse-width WPWS and TPWS.
* The number of error-level DRC violations.
* Bitstream and configuration image sizes.
* Required report status.
* LUT, register, BRAM, and DSP utilization.
* Commit, Vivado version, and Bender version.

JUnit reports, simulation logs, KCU105 reports, and generated images are
retained for one week.

HWPE Server Validation
----------------------

From ``heris-soc``, run the complete HWPE acceptance flow on a host with
QuestaSim and Vivado:

.. code-block:: sh

   ./scripts/hwpe/run_hwpe_mac_validation.sh

The script runs ``make full-test REBUILD=1`` first and requires the HWPE pass
marker. It starts KCU105 implementation only after simulation passes. Results
are written under ``notes/hwpe-mac-validation/<timestamp>`` by default; set
``HWPE_VALIDATION_DIR`` to select another directory. Set
``FC_CLK_PERIOD_NS`` to override the default 10 ns FC clock period.

A complete run ends with ``HWPE MAC validation: PASS``. Preserve the summary,
JUnit files, simulation log, KCU105 reports, and generated images as acceptance
evidence.

Dependencies And Retry
----------------------

CI uses the committed ``heris-soc/Bender.lock`` as the dependency source. It
does not update dependencies. The ``.bender/`` cache key is derived only from
``Bender.lock``.

A failed job is retried once only for Runner, timeout, scheduler, or GitLab API
infrastructure failures. Design, timing, and simulation failures are not
retried automatically.

GitLab Project Settings
-----------------------

Configure the following project settings:

* Enable **Pipelines must succeed** and do not accept skipped pipelines.
* Protect ``master``: no direct pushes; only Maintainers may merge.
* Protect ``dev``: Maintainers may push directly; Developers and Maintainers
  may merge.

The pipeline is the technical merge gate. Approval remains a visible review
procedure:

* A merge request to ``dev`` needs one Developer or Maintainer approval.
* A merge request to ``master`` needs one Maintainer approval.
* The author may provide the approval.
* Review the merge request again after new commits.
