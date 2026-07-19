HERIS SDK
=========

``heris-sdk`` is not implemented. Applications must continue to use the simple
runtime and the repository Make targets described in :doc:`build-and-startup`.

First Usable Version
--------------------

The first SDK version is usable only when it provides all of the following:

.. list-table::
   :header-rows: 1

   * - Deliverable
     - Acceptance condition
   * - Public headers
     - An application includes only HERIS-owned headers.
   * - Application build entry
     - A new application builds without importing internal runtime Make rules.
   * - CV32E40P profile
     - ISA, ABI, FPU, linker, and execution settings come from one named profile.
   * - Runtime services
     - Console output, L2 allocation, exit status, and UART have documented APIs.
   * - Examples
     - Minimal hello, floating-point, and UART applications build from a clean checkout.
   * - Validation
     - The existing runtime smoke passes through the SDK entry points.

Migration Rule
--------------

The simple runtime remains the implementation baseline until the SDK builds and
runs the current hello, floating-point, integer, UART, and algorithm tests. The
test output and exit status must remain unchanged during migration.

New SDK APIs require a focused test before existing applications move to them.
Internal headers and build variables can be retired only after the regression
suite no longer uses them.

Not Yet Defined
---------------

The first SDK does not imply an RTOS, scheduler, threading model, or binary
compatibility guarantee. Those features need separate requirements and tests.
