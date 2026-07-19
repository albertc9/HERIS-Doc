Simple Runtime
==============

The developer-facing entry point is ``main()``. A minimal application needs
only standard output and a return value:

.. code-block:: c

   #include <stdio.h>

   int main(void)
   {
       printf("Hello from HERIS\n");
       return 0;
   }

Returning ``0`` reports success. A nonzero return value reports failure. In RTL
simulation, ``printf()`` writes to the testbench stdout device; it does not use
the physical UART.

Current Interfaces
------------------

The minimal C library implements ``printf()``, ``puts()``, ``putchar()``, and
``sprintf()``. It is not a complete hosted C library and does not provide a
general-purpose ``malloc()`` implementation.

The runtime provides an L2 allocator:

.. code-block:: c

   void *pi_l2_malloc(int size);
   void pi_l2_free(void *ptr, int size);

The caller supplies the allocation size again when freeing a block. Allocation
failure returns a null pointer.

The UART driver exposes blocking transfers:

.. code-block:: c

   int uart_open(int uart_id, int baudrate);
   int uart_write(int uart_id, void *buffer, uint32_t size);
   int uart_read(int uart_id, void *buffer, uint32_t size);
   void uart_close(int uart_id);

The UART test configures the pads, opens UART 0 at 115200 baud, transfers data,
and compares the received bytes. In the default profile, application
``printf()`` remains connected to the testbench stdout; the UART test calls the
UART interfaces directly.

The bundled runtime header declares these interfaces. Until ``heris-sdk``
provides HERIS-owned public headers, use an existing regression test as the
include and build reference.

Current Target
--------------

The supported target is a single CV32E40P core using
``-march=rv32imfc_xcorev`` and the ``ilp32f`` ABI. The FPU is enabled and Zfinx
is disabled. The default execution target is QuestaSim RTL simulation.

Validation
----------

``make smoke`` validates startup and exit, testbench stdout, floating-point and
basic integer execution, misaligned access, the UART loopback, and three
standalone algorithms. The exact test list is maintained in
:doc:`/getting-started/first-smoke-test`.

The L2 allocator and interrupt initialization do not have isolated smoke tests.
FLL programming and other peripheral drivers are not covered. The current
target has no multi-core runtime contract.

The simple runtime is not an operating system. It has no scheduler, processes,
threads, or portable device model.
