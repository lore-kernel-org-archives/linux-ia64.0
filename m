From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Jun 2003 21:39:54 +0000
Subject: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105605890319553@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A patch to make 2.5.72 work on ia64 is now available in the usual
place:

  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/
	linux-2.5.72-ia64-030619.diff.bz2

This patch Works for Me.  This particular patch was tested on rx5670
only, but slightly earlier versions worked on all zx1-based machines,
Big Sur, and HP Ski simulator.

There are four outstanding issues that I know of:

 - modules may or may not work properly (I had some problems with
   a load of tg3 hanging when the kernel daemon was invoking
   /sbin/hotplug)
 - hp-agp is currently broken because some generic AGP code once
   again thinks that all AGP bridges have to be PCI devices (which
   isn't true)
 - sigaltstack and ar.bspstore issue pointed out by Matt Chapman
 - problems with bio-level block merging forced me to turn off
   this kind of merging for now (primary suspect is sba_iommu.c)

Since I'm spread pretty thin already, I'd definitely appreciate if
someone else could look into the module loader issue.  It shouldn't be
hard to figure out what's going wrong.  I'd also appreciate help with
the hp-agp code.

We're inching ever closer to the point where 2.5 will build for ia64
out-of-the-box.  Not quite there yet, but hopefully it will only be a
matter of months (just kidding, really!).

Enjoy,

	--david

<chadt:sgi.com>:
  o ia64: early_printk for SGI SN2

David Mosberger:
  o More ppc64 bad merge fixing
  o Drop export of init_thread_union alltogether
  o Simplify the irq_desc[] patch to make it more acceptable for the main tree.
  o io.h
  o Fix weird PPC64 merge errors
  o defconfig
  o io.h
  o Kconfig
  o ia64: Simplify the script to use only $CC and $OBJDUMP.  Besides being
    simpler, this also ensure we really do test the linker which will be used
    when building the gate DSO.
  o Revert back to adjusting RPCSVC_MAXPAGES
  o Don't declare init_thread_union in sched.h if there is an architecture-
    specific task-struct-allocator.
  o ia64: Minor cleanups; fix non-SMP build
  o ia64: Two more minor cleanups for 2.5.72
  o ia64: Drop obsolete ACPI SPCR support
  o More 2.5.72 cleanup/syncing
  o ia64: Initial sync with 2.5.72
  o Merge conflicts with 2.5.72
  o ia64: Sync with 2.5.71
  o Make hp-agp.c compile again.  It's still broken, because the generic AGP
    code once again thinks all AGP bridges must be PCI devices.
  o Add back /proc/sys/kernel/cache_decay_ticks
  o Fix <linux/pci.h> so it can be used on platforms with CONFIG_PCI off
  o Fix serial HCDP and ACPI support for serial driver
  o Merge with 2.5.71
  o memory.c
  o Allow read accesses to the entire FIXMAP range.  This lets gdb see the
    instructions in the gate page (there is no security issue, because the gate
    page only contains instructions or non-security-sensitive data such as the
    ELF headers, etc.).
  o Remove include of <asm/unistd.h> now that force_successful_syscall() is
    back in ptrace.h.
  o Fix gratuitous PPC64 changes (were probably caused by a bad bk merge with
    Linus' tree).
  o Clean up tg3 driver to avoid relying on PCI-DMA implementation internals. 
    This removes code and gets rid of the (incorrect) dependence on
    PCI_DMA_BUS_IS_PHYS.
  o Adjust for force_successful_syscall_return() having moved back to ptrace.h.
  o Don't try to support uncached accesses via read()/write()
  o More small cleanups to /dev/mem driver and for stack dumping
  o Fix up drivers/char/mem.c some more
  o Clean up drivers/char/mem.c to reduce #ifdef bloat.  Make it work better on
    ia64
  o fork.c
  o Fix task creation/destruction to make it possible for the thread_info and
    the task_struct to be next to each other.
  o Add force_successful_syscall_return() to remaining platforms
  o Adjust show_trace()/show_stack() interfce to make them truly portable
  o fix TCP roundtrip time update code
  o ia64: Fix backtrace printing so it doesn't output tabs anymore
  o Fix locking comments for time interpolator routines
  o Overhaul time-interpolation support.  Platforms that do not ever wish to
    use time-interpolation should NOT define CONFIG_TIME_INTERPOLATION.
  o Undo previous pasting-operator "fix".  Code was right and pre3.4 compiler
    was (temporarily) broken.
  o Add two hooks for high-precision time-interpolation.  Based on patch by Jes
    Sorensen.
  o Small driver fixes
  o Undo timer breakage.  Makes profil() work again
  o Change last_time_offset into last_nsec_offset and make it work for real
  o Misc fixes: PCI ids and prefetch in page-table tear-down
  o Add /proc/sys/kernel/cache_decay_ticks
  o Fix off-by-one error to make NFSd work with PAGE_SIZE = 64KB
  o Add MM_VM_SIZE() support
  o Add EARLY_PRINTK support
  o Minor build fixes/enhancements
  o select() speedup
  o Various minor driver fixes
  o Support serial ports in ACPI namespace and serial consoles via HCDP
  o Toolchain bug workarounds
  o AGP fixes for ia64
  o Make ACPI work on ia64
  o Generic DRM support for platforms that cant_use_aperture
  o Add module_arch_cleanup() callback

Jesse Barnes:
  o ia64: generic kernel support for sn2
  o ia64: PCI fixes for sn2
  o ia64: hwgfs fix for sn2
  o ia64: mark_idle() fixes for sn2
  o ia64: bitshift fix

Peter Chubb:
  o Fix ps/2 mouse and keyboard on I2000

Roland McGrath:
  o make FIXMAP user page reading more portable

Tony Luck:
  o ia64: add missing __exit_p() to i460-agp.c

