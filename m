From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 19 Jun 2004 07:24:57 +0000
Subject: kernel update (relative to 2.6.7)
Message-Id: <16595.59977.400759.833921@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 patch can now be found at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6/

in file:

 linux-2.6.7-ia64-040619.diff.gz

1-line summaries of ia64-specific changes since 2.6.6 are attached below.

One change of interest may be that Arun et al have fixed the ia32
subsystem such that it doesn't leak virtual address space anymore when
an ia64 page gets partially mapped.

I have tested it with Ski simulator and various (zx1-based) Itanium 2
machines.  YMMV.

Enjoy,

	--david

  [PATCH] ia64: fix free_huge_page() call in hugetlb_prefault()
  [PATCH] ia64: perfmon stack consumption fix
  [PATCH] ia64: move move_irq() from iosapic.c to irq.c
  [PATCH] ia64: fix ia32 partial-page map support for overlapping mmaps
  [PATCH] ia64: switching between CPEI & CPEP
  [PATCH] ia64: fix SN2 interrupt rerouting
  ia64: Fix build-problem when CONFIG_IA32 is not enabled.
  ia64: Squish some more hazards & warnings for UP compile.
  ia64: Squish compiler-warning in perfmon.c when compiling for UP.
  ia64: Nuke two warnings in mca.c that showed in the simulator configuration.
  ia64: Fix ia32 partial-page-list code to compile cleanly in more configs.
  [PATCH] ia64: update sn2_defconfig
  [PATCH] ia64: Support SN platform specific error features
  [PATCH] ia64: fix info in /proc/pal/*/bus_info
  [PATCH] ia64: fix race in fsys_bubble_down to avoid fp-register corruption
  ia64: Update defconfig
  [PATCH] ia64: Remove warnings when unwind debug is turned on
  [PATCH] ia64: fix race in fsys_bubble_down to avoid fp-register corruption
  [PATCH] ia64: mark non-existent NUMA-nodes as offline
  [PATCH] ia64: Rename SN "modules" variable to "sn_modules".
  [PATCH] ia64: fix ia32 virtual memory leaks due to partial-page mappings
  [PATCH] ia64: delete McKinley A-stepping code
  ia64: Kill unused external declaration of "acpi_legacy_devices".
  ia64: work around linker bug
  [PATCH] ia64: uninline find_next_bit on ia64
  [PATCH] ia64: fix comment-typo in entry.S
  [PATCH] ia64: Fix early serial console setup regression on the IBM x450 and x455
  [PATCH] ia64: setup cpu_to_node for cpus not present
  ia64: Avoid intermediate-overflows in sched_clock().
  [PATCH] ia64: disable in-kernel ia32 emulation post Madison
  [PATCH] ia64: tighten FPH state context switch check
  [PATCH] ia64: for SN2, disable MST errors on probe
  ia64: fix /proc/ioports regression in 2.6.6 on Tiger4
  ia64: Add defconfig for Ski simulator (patch by Darren Williams).
  ia64: define pending_irq_cpumask in irq.c
  [PATCH] ia64: use new ptep_set_access_flags
  ia64: Implement race-free ptep_set_access_flags()
  [PATCH] ia64: don't udelay() in sn_mmiob
  [PATCH] ia64: fix hotplug config placement
  ia64: Reserve syscall # for vserver().
  ia64: Update defconfig
  ia64: Kill a warning when arch/ia64/kernel/machvec.c gets compiled on UP.
