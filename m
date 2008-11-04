From: Doug Chapman <doug.chapman@hp.com>
Date: Tue, 04 Nov 2008 20:28:34 +0000
Subject: [REGRESSION] Minimize per_cpu reservations patch causes NULL ptr
Message-Id: <1225830514.13942.8.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At HP we ran into a regression that appears to be caused by:

commit 2c6e6db41f01b6b4eb98809350827c9678996698
Author: holt@sgi.com <holt@sgi.com>
Date:   Thu Apr 3 15:17:13 2008 -0500

    [IA64] Minimize per_cpu reservations.


This is seen when we have one or more CPUs deconfigured via "cpuconfig"
at the EFI shell or on systems that have an unpopulated CPU socket.  We
hit this traceback (edited for clarity)

Unable to handle kernel NULL pointer dereference (address 0000000000000040)
 [<a000000100618bc0>] _spin_lock+0x20/0x60
 [<a0000001000811b0>] __enable_runtime+0x70/0x160
 [<a000000100086a50>] rq_online_rt+0x110/0x180
 [<a00000010007e070>] set_rq_online+0x110/0x160
 [<a00000010060db90>] migration_call+0x290/0xc00
 [<a000000100807060>] migration_init+0xc0/0x100
 [<a00000010000a960>] do_one_initcall+0xa0/0x2a0
 [<a0000001007f0310>] kernel_init+0xd0/0x5a0


The problem is the per-cpu datastructures are used but not set up for
the offline CPUs.

in setup_arch() we call this bit of code which should add the offline CPUs to
early_cpu_possible_mask:


        per_cpu_scan_finalize((cpus_weight(early_cpu_possible_map) = 0 ?
                32 : cpus_weight(early_cpu_possible_map)),
                additional_cpus > 0 ? additional_cpus : 0);


however, additional_cpus has not been set yet.  It _can_ be set by the user as
a command line parameter however it is normally set by prefill_possible_map()
which is called later.  At the point where per_cpu_scan_finalize is called we
_cannot_ know what additional_cpus is because we have not yet gotten that info
from acpi.  That happens when we call acpi_boot_init() which hapens later in
setup_arch().

It appears the intent of calling per_cpu_scan_finalize() at the current
location is that it needs to be called prior to find_memory().  The "Minimize
per_cpu reservations." patch changes code in arch/ia64/mm/discontig.c which
sets up the per-cpu datastructures to only set those up for CPUs in
early_cpu_possible_map.  The problem is we don't have the offline CPUs in that
map yet.  Later code tries to use these datastructures and we hit the NULL ptr.

So, it seems the options to fix this that I can think of are:

1) try to get the info regarding offline CPUs earlier either by calling
acpi_boot_init() earlier (probably not possible prior to calling find_memory())
or walk a subset of the ACPI tables to get the number of offline CPUs sooner
(which sounds ugly).


2) after we call acpi_boot_init() go back and setup the per-cpu datastructures
for the offline CPUs then.  Seems like this might be cleaner but I have not
investigated the specifics.


I will start looking at option #2 but certainly welcome suggestions, perhaps
there is an easy fix?

thanks,

- Doug


