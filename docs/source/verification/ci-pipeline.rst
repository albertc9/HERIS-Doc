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

Smoke and Full-test currently run the same nine CV32E40P software tests at the moment. They
remain separate commands so that their coverage can change independently in the near future.

Each simulation job writes a JUnit report for the GitLab merge request. Test
failures are collected before the suite fails. Environment or platform build
failures stop the suite and are also recorded in JUnit.

KCU105 Gate
-----------

The KCU105 job runs ``make kcu105`` and blocks the pipeline when:

* The Vivado build fails.
* Setup WNS is negative.
* ``kcu105.bit`` or ``kcu105.bin`` is missing or empty.
* A required timing or utilization report is missing or empty.
* The KCU105 JUnit report cannot be generated.

TNS, hold timing, timing warnings, unconstrained paths, and utilization are
diagnostic information. They do not add another timing threshold.

The merge request evidence includes:

* Implementation status and duration.
* Setup WNS and TNS.
* Bitstream and configuration image sizes.
* Required report status.
* LUT, register, BRAM, and DSP utilization.
* Commit, Vivado version, and Bender version.

JUnit reports, simulation logs, KCU105 reports, and generated images are
retained for one week.

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
