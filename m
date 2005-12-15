From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 15 Dec 2005 10:46:04 +0000
Subject: 2.6.15-rc5-git3 perfmon2 new code base + libpfm available
Message-Id: <20051215104604.GA16937@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfctr-devel@lists.sourceforge.net
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

I have released a new version of the perfmon base package.
This release is relative to 2.6.15-rc5-git3.

I have also updated the library, libpfm-3.2, to match the kernel
level changes. 

This new kernel patch includes several important changes:

  - pfm_create_context() interface has changed. The sampling
    buffer format argument is now passed explicitly instead
    of relying on it being contiguous to pfarg_ctx_t.

  - code in perfmon/perfmon.c has been split into 8 
    different files for improved maintainability. Each
    file implements one specific function. Perfmon.c
    remains the core.

  - fixed several important bugs for i386 and x86_64 for
    Intel P4/Xeon (simple counting was returning 0).

  - added support for virtual PMD (read/write)

  - added notion of read-only PMD

  - Split Pentium M/P 6 PMU description in preparation for
    Pentium M LBR support

  - Added support for reference counting on PMU description
    and Sampling buffer modules to avoid panic in case
    module is removed while being used.

  - On i386/X86_64, added code to handle the NMI watchdog
    when it is using the Local APIC. We now use
    reserve_lapic_nmi() and release_lapic_nmi().

  - various other cleanups and bug fixes

You MUST use libpfm-3.2-051215 with this kernel due to
interface change for pfm_create_context().

As usual, you can download the latest packages from the
SourceForge website at:

	http://www.sf.net/projects/perfmon2

I will be posting the patches directly to LKML for
review very shortly.

Enjoy,
-- 

-Stephane
