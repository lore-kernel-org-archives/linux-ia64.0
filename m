From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 15 Mar 2002 05:02:14 +0000
Subject: [Linux-ia64] new kernel patch (relative to 2.5.7-pre1)
Message-Id: <marc-linux-ia64-105590701905293@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, here is a bit of a weirdo patch.  See, I'm still learning to get
along with bitkeeper.  It's been rough going, but I think it's getting
closer to the point where it will actually start to save me time.  In
the meantime, please bear with me.

So, why is it a weird patch: well, it's relative to 2.5.7-pre1 instead
of 2.5.6 as I had originally planned.  Furthermore, the ia64 patch
contains a couple of unrelated patches which Linus added after
releasing 2.5.7-pre1.  I'll spare you the details of how this
happened, but for now, just ignore those minor details.  I'll try to
do better next time.

The good news is that 2.5 seems to be quite usable now.  With this
patch applied, the kernel passes all the tests in my (admittedly
small) test suite.  Couldn't say that for the earlier kernels.  The
patch has been tested with SMP on a Big Sur (gcc3.0) and UP on HP Ski
simulator (gcc2.96).

As usual, the patch can be found in
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/.  The file
name is:

	linux-2.5.7-pre1-ia64-020314.diff.bz2

A rough changelog is appended below (and prepended to the patch).  I expect
the quality of these messages to improve in the future.  One notable change:
I switched over to using Rusty's approach for per-CPU variables.  It makes
it very easy to declare new per-CPU variables:

	int foo __per_cpu_data;

would declare "foo" as a per-CPU variable.  You can then access the value
that this variable has on CPU n with:

	per_cpu(foo, n)

As a special-case, you can access the value for the current CPU as:

	this_cpu(foo)

This is more efficient than the logically equivalent
per_cpu(foo, smp_processor_id()) because the access goes through
the special per-CPU page (whose translation is pinned into the TLB).

There are two caveats:

	- the total size of the per-CPU data area is currently limited
	  to the smallest page size (4KB); we can increase this in
	  the future if necessary, but, on the other hand, you probably
	  shouldn't put huge variables in here either

	- be careful when taking the address of this_cpu(foo); it's
	  safe to use such a pointer on the CPU that calculated the
	  address, but the effect of passing it to any other CPU will
	  be implementation-dependent; if you want to get the address
	  of a particular instance of a per-CPU variable, be sure
	  to take the address of per_cpu(foo, n) instead.

Oh, Jack, I dropped the NUMA portion of the cpuinfo-structure.  This case
needs to be updated anyhow due to the new per-CPU scheme and I wasn't sure
exactly what your preference would be.  Also, the need for the
"platform_specific" portion and the NUMA pointers in this structure should
be gone now: simply declare your own per-CPU variables wherever convenient.

Over the next couple of patches, I expect much of the stuff in cpuinfo
to be migrated into separate per-CPU variables, so the structure can
be reverted back to its original purpose.  I already moved
ipi_operations.

On a final note, for those of you who want to use bitkeeper themselves,
I'm trying to maintain something sensible at:

	http://lia64.bkbits.net/

If you don't want to use bitkeper, that's perfectly fine: I'll accepted
patches just the same way as before so if you don't care for it, nothing
at all changes for you.

Enjoy,

	--david


Summary of changes from v2.5.7-pre1 to lia64-2.5.7-pre1
===========================
<davidm@wailua.hpl.hp.com> (02/03/09 1.375.25.1)
	This patch provides a platform hook which can be used to force a successful
	system call return for system calls that can legitimately return (small)
	negative numbers.

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.26.1)
	DRM fixes for IA-64.

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.27.1)
	acpi.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.28.1)
	efi.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.29.1)
	qlogic.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.30.1)
	64-bit cleanups for sound drivers.

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.28.2)
	Add GUID support to devfs.

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.31.1)
	eepro100.c:
	  Bias Ethernet header so that IP header is (usually) aligned.
	  Enable DMA even on word-oriented machines.

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.26.2)
	agp_backend.h:
	  Mention INTEL_460GX as a chipset.
	  Add vmptr member to struct _agp_memory.

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.32.1)
	timer.c, time.c:
	  Define and initialize time_offset variable to enable guaranteed monotonic time.

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.33.1)
	irq_cpustat.h:
	  Rename local_irq_count() to irq_count() and local_bh_count() to bh_count().
	  Provide old names as deprecated alternatives
	  for now.  Define local_*() macros to provide
	  local CPU efficient access to various irq_stat
	  members.

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.33.2)
	Take advantage of CPU-local irqstat accessors.

<davidm@wailua.hpl.hp.com> (02/03/09 1.375.31.2)
	eepro100.c:
	  Restore comment that was accidentally dropped by earlier patch.

<bjorn_helgaas@hp.com> (02/03/11 1.375.26.3)
	[PATCH] agpgart/DRM page_mask fix

	Support both 460GX and HP's zx1 chipset without having to put kludges in DRM.

<peter@chubb.wattle.id.au> (02/03/11 1.375.40.3)
	[PATCH] HP Sim config patch

	Offer loopback driver and network block device support for HP Sim.

<davidm@wailua.hpl.hp.com> (02/03/11 1.375.34.8)
	ide-geometry.c:
	  Don't include RTC headerfile for IA-64.

<davidm@wailua.hpl.hp.com> (02/03/11 1.375.40.4)
	siginfo.h:
	  Define SI_DETHREAD.

<davidm@wailua.hpl.hp.com> (02/03/11 1.375.40.5)
	smp.c:
	  Remove task-migration IPI.   It's been replaced
	  by Ingo's migration threads.

<davidm@wailua.hpl.hp.com> (02/03/11 1.375.40.6)
	Sync with Linus' v2.5.6 tree.

<davidm@hpl.hp.com> (02/03/12 1.388.2.2)
	[PATCH] Compile fix for kernel/sched.c

	Fix init_idle() to initialize preempt_count only if CONFIG_PREEMPT is set.

<davidm@wailua.hpl.hp.com> (02/03/12 1.388.5.1)
	Make sys_sendfile64() accept 64-bit fileoffsets on 64-bit platforms.
	Don't define sys_sendfile64() unless it's really needed.

<davidm@wailua.hpl.hp.com> (02/03/12 1.375.36.2)
	Clean up sys_prctl().

<davidm@wailua.hpl.hp.com> (02/03/12 1.388.5.2)
	fs.h:
	  Fix typo in definition of MAX_OFF_T.

<eranian@hpl.hp.com> (02/03/13 1.388.2.3)
	[PATCH] Fix ia64 perfmon for 2.5.6

	Fix up earlier perfmon breakage.

<jes@trained-monkey.org> (02/03/13 1.375.29.2)
	[PATCH] Clean up qla1280 SCSI driver.

	Clean up qla1280 SCSI driver.

<davidm@wailua.hpl.hp.com> (02/03/13 1.388.2.4)
	offsets.h:
	  Update offsets.h
	defconfig:
	  Update defconfig.

<davidm@hpl.hp.com> (02/03/13 1.388.2.7)
	[PATCH] Move __per_cpu_data from smp.h to compiler.h.

<davidm@wailua.hpl.hp.com> (02/03/14 1.475)
	Make main-title more concise.
	Rename "General setup" to "Processor type and features".
	Move ACPI types after the point where HP_SIM gets defined.
	Pick up HP Ski configuration options from arch/ia64/hp/Config.in.

<davidm@wailua.hpl.hp.com> (02/03/14 1.473.1.2)
	Pick up binfmt_elf.c SET_PERSONALITY() fix from 2.4.18.

<davidm@wailua.hpl.hp.com> (02/03/14 1.375.29.3)
	Fix typos in qla1280.c and qla1280.h.



