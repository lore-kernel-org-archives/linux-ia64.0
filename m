From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 16 Oct 2003 22:27:38 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106634331202560@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942507026161@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942507026161@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.  Relative to what I sent you
yesterday, this update adds a largish update to perfmon.  This makes
perfmon "feature complete" (and thanks to John Levon, ready to
interoperate with oprofile) and Stephane promised me that there will
only be bug fixes from now on.  I hope this is still acceptable,
because this was all being worked on (and much of if done) before you
declared the bug-fix-only status.

Thanks!

	--david

 Documentation/ia64/fsys.txt         |   57 +++
 arch/ia64/Kconfig                   |    4 
 arch/ia64/kernel/acpi.c             |    4 
 arch/ia64/kernel/asm-offsets.c      |   18 +
 arch/ia64/kernel/fsys.S             |  208 +++++++++++--
 arch/ia64/kernel/gate.S             |    3 
 arch/ia64/kernel/head.S             |   19 +
 arch/ia64/kernel/mca.c              |   30 -
 arch/ia64/kernel/mca_asm.S          |    6 
 arch/ia64/kernel/patch.c            |    6 
 arch/ia64/kernel/perfmon.c          |  571 +++++++++++++++++++-----------------
 arch/ia64/kernel/perfmon_itanium.h  |    4 
 arch/ia64/kernel/perfmon_mckinley.h |   22 +
 arch/ia64/kernel/setup.c            |   37 ++
 arch/ia64/kernel/time.c             |   13 
 arch/ia64/sn/kernel/sn2/io.c        |    4 
 include/asm-ia64/asmmacro.h         |   23 -
 include/asm-ia64/delay.h            |    9 
 include/asm-ia64/machvec_sn2.h      |    2 
 include/asm-ia64/mca.h              |    2 
 include/asm-ia64/mca_asm.h          |    3 
 include/asm-ia64/pal.h              |   12 
 include/asm-ia64/perfmon.h          |   11 
 include/asm-ia64/posix_types.h      |    2 
 include/asm-ia64/serial.h           |  106 ------
 25 files changed, 702 insertions(+), 474 deletions(-)

through these ChangeSets:

<eranian@hpl.hp.com> (03/10/16 1.1536)
   [PATCH] ia64: perfmon-2 fixes
   
    - remove PFM_FL_UNSECURE support because broken
    - remove instrumentation code for syswide ctx update (5% speedup)
    - integrated cleanups from John Levon
    - remove references to pmu_conf.ovfl_val from loops, use local variable
    - updated pfm_bad_permissions()
    - support reset values for non-counting pmds
    - serialization of PFM_RESTART
    - added support for restart_active in per-task mode
    - remove potential deadlock caused by calling pfm_overflow_handler()   from pfm_load_regs()
    - fix invalid check in perfmon_mckinley() for PMC13

<tony.luck@intel.com> (03/10/16 1.1535)
   [PATCH] ia64: MCA min_state area must be uncacheable
   
   Software Developer's Manual page 2:270, section 11.3.2.3
   says that the processor min-state save area must be in an
   uncacheable region ... but current MCA recovery code
   allocates the min-state area "ia64_mca_min_state_save_info"
   in regular kernel data/bss.
   
   This patch re-uses the same min-state area that the PAL/SAL
   used to report the error to Linux ... which mostly requires
   deleting code and declarations (some of which were wrong,
   MIN_STATE_AREA_SIZE ought to have been 58).  The real "work"
   is copying the pointer to the min-state area from the
   sal_to_os handoff structure into the os_to_sal structure.

<davidm@tiger.hpl.hp.com> (03/10/15 1.1534)
   ia64: Important security fix for fsyscalls.  Without this patch, the McKinley E9
   	workaround caused fsyscalls to return with the wrong privilege level.
   	This patch also adds fsys_rt_sigprocmask(), which happens to be a good
   	test-case for this bug.  Only McKinley systems using fsyscalls are affected.
   	Merced and Madison are OK.

<ianw@gelato.unsw.edu.au> (03/10/15 1.1533)
   [PATCH] ia64: a little more documentation in fsys.txt
   
   Attached is a suggestion for a small addition to fsys.txt about how
   userspace can use fast system calls.
   
   If people think this is totally wrong, or that something like this
   might be more appropriate in our WiKi, that's fine.

<davidm@tiger.hpl.hp.com> (03/10/15 1.1532)
   ia64: Fix __delay() even more: it's just not safe to inline the delay-
   	loop because, e.g., the compiler might decide to unroll the
   	loop when passed a constant, etc.

<bjorn.helgaas@hp.com> (03/10/15 1.1531)
   [PATCH] ia64: fix serial port naming
   
   Now that the serial driver fully supports discovery via ACPI,
   we can get rid of all the legacy junk in asm-ia64/serial.h.
   This keeps the serial driver from blindly probing I/O port
   space.
   
   This also fixes a long-standing serial device naming issue:
   ttyS0-ttyS3 were always reserved for the compiled-in
   COM ports, even if they weren't present in the box.
   Any additional PCI or ACPI ports appeared starting at
   ttyS4 (except for the special case of things described
   in the HCDP).   Now we'll just name ttyS devices in the
   order they're discovered, without any holes for non-existent
   devices.
   
   This is a little bit ugly for serial console because the HCDP
   is currently the only way we learn about serial ports before
   the actual ACPI discovery.  All HP firmware implements HCDP,
   but Intel firmware does not.  So in the absence of an HCDP,
   we have to probe for legacy COM ports.  Otherwise, the serial
   console wouldn't work until the serial driver discovers the
   port via ACPI.

<nathans@sgi.com> (03/10/15 1.1530)
   [PATCH] ia64: correct ino_t to be 64 bits wide
   
   This brings the kernel in sync with glibc (and all other 64-bit platforms
   other than Alpha and S390x).  This fixes ustat() and breaks nfsctl_export,
   but the latter is a deprecated interface anyhow (newer versions of
   nfsutils use "exportfs" instead).

<davidm@tiger.hpl.hp.com> (03/10/15 1.1529)
   ia64: Fix __delay() to do The Right Thing.  In practice, this may
   	cause BogoMIPS to drop to half the clock-speed with current
   	versions of GCC, but this just shows that GCC doesn't generate
   	very good code for single-cycle loops.  Perhaps it will motivate
   	someone to improve GCC in this area (though it's hardly of
   	practical value, other than for producing large BogoMIPS values).

<jbarnes@sgi.com> (03/10/15 1.1528)
   [PATCH] ia64: force on appropriate generic options
   
   Make sure that generic kernels actually build by forcing on the
   necessary options.  With this patch I was able to build a generic kernel
   out of the to-linus-2.5 tree.

<ianw@gelato.unsw.edu.au> (03/10/14 1.1527)
   [PATCH] ia64: drop bogus "now < last_tick" message
   
   itc_get_offset() has a consistency check which is no longer valid now that
   xtime_lock is a seq_lock.  Drop the bogus check.

<jbarnes@sgi.com> (03/10/14 1.1526)
   [PATCH] ia64: SN2 module fix
   
   Because we're the only platform with seperate in, out, and read
   routines, we have to include the file that defines them in our machvec
   header so that users of the functions will get the right defines and not
   use the non-inline function variants (which are only necessary for
   generic kernels).

<tony.luck@intel.com> (03/10/14 1.1525)
   [PATCH] ia64: Another MCA fix
   
   The definition of the pal_process_state_info_s structure
   misses out some useful pieces (e.g. the "mi" bit which indicates
   whether we should call PAL_MC_ERROR_INFO to get more details).
   
   Worse yet, some of the bits are in the wrong places (cc/tc/bc).
   
   See Volume 2 of "Intel Itanium Architecture Software Developer's
   Manual".  (In the Rev 2.1 October 2002 edition, p. 2:268 and 2:276).

<tony.luck@intel.com> (03/10/13 1.1524)
   [PATCH] ia64: cannot convert region 5 address to physical by clearing bits 63:61
   
   Another no-brainer bug fix snipped out of the quagmire of
   the MCA/TLB patch.  This one is for 2.6 only, we must use
   the new LOAD_PHYSICAL() macro to get the physical address of
   the code label that we want to jump to, the INST_VA_TO_PA()
   macro just clears the region bits, which only works for region
   7 addresses.

<tony.luck@intel.com> (03/10/13 1.1523)
   [PATCH] ia64: infinite loop in ia64_mca_wakeup_ipi_wait
   
   This bugfix has been hiding inside the MCA TLB patches.
   
   There is an infinite loop in ia64_mca_wakeup_ipi_wait() because
   the compiler optimizes away the test at the bottom of the while
   loop.  It does this because IA64_MCA_WAKEUP_VECTOR is 0xf0, so
   irr_bit is known to be the constant 0x30, a.k.a. 48 in decimal.
   So when the compiler looks at the expression:
   
   
   It observes that 1' as unsigned
   long.
