From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Apr 2002 07:15:17 +0000
Subject: [Linux-ia64] kernel update (relative to v2.5.10)
Message-Id: <marc-linux-ia64-105590701905531@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 kernel patch is at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in
file:

	linux-2.5.10-ia64-020426.diff.gz

This hasn't been tested very thoroughly but assuming bitkeeper didn't
let me down, the patch should work.  A summary of changes is below.

	--david

<davidm@wailua.hpl.hp.com> (02/04/25 1.531.11.11)
   ia64: Fix merge errors in do_csum().

<davidm@wailua.hpl.hp.com> (02/04/25 1.531.11.10)
   ia64: Revert compile-time optimization for bzero().

<davidm@wailua.hpl.hp.com> (02/04/25 1.531.11.9)
   ia64: Add missing .prologue directive to ip_fast_csum().

<davidm@wailua.hpl.hp.com> (02/04/25 1.531.11.8)
   ia64: Add IA64_ISR_CODE_* macros from Ken's patch.

<davidm@wailua.hpl.hp.com> (02/04/25 1.531.11.7)
   ia64: Treat lfetch.fault like speculative loads as is required by the
   	architecture definition.  Patch by Ken Chen.

<davidm@wailua.hpl.hp.com> (02/04/25 1.531.11.6)
   ia64: Change "McKinley" to "Itanium 2" for user-visible strings.

<davidm@wailua.hpl.hp.com> (02/04/25 1.531.11.5)
   ia64: Add optimized ip_fast_csum() by Ken Chen and merge his cleanups
   	to do_csum.S.

<elenstev@mesatop.com> (02/04/25 1.531.11.4)
   [PATCH] This patch adds a help text for CONFIG_IA64_GRANULE_16MB.

<davidm@wailua.hpl.hp.com> (02/04/25 1.531.11.3)
   ia64: Make default behavior of SIGURG to ignore the signal, as per SUS.

<davidm@wailua.hpl.hp.com> (02/04/24 1.531.11.2)
   ia64: Update comments for E2BIG and TCSETS like for x86.

<davidm@wailua.hpl.hp.com> (02/04/24 1.531.11.1)
   ia64: Correct unwind info for signal trampoline.

<davidm@wailua.hpl.hp.com> (02/04/23 1.489.12.3)
   mpi_raid.h:
     Rename: drivers/message/fusion/mpi_raid.h -> drivers/message/fusion/lsi/mpi_raid.h

<davidm@wailua.hpl.hp.com> (02/04/23 1.489.12.2)
   Make fusion driver work on 2.5.

<davidm@wailua.hpl.hp.com> (02/04/23 1.489.11.5)
   ia64: Make ACPI work again.

<davidm@wailua.hpl.hp.com> (02/04/23 1.489.3.8)
   ia64: Send SIGILL for break operands in range 0x3f000 to 0x3ffff to
   simplify dynamic bundle patching.

<davidm@wailua.hpl.hp.com> (02/04/19 1.489.11.4)
   Misc. ACPI and merge fixes.

<davidm@wailua.hpl.hp.com> (02/04/19 1.489.3.7)
   ia64: Fix ACPI/IOSAPIC breakage introduced by big ACPI update.

<peter@chubb.wattle.id.au> (02/04/19 1.489.3.6)
   [PATCH] The attached patch cleans up IA32 support a little.
   As it's impossible at present to compile and use IA32 support as a
   module, disallow that; and also provide dummy functions to remove
   compilation warnings if CONFIG_IA32_SUPPORT is off.

<asit.k.mallick@intel.com> (02/04/19 1.489.3.5)
   [PATCH] Don't prefetch beyond end of patch to avoid bringing in cache-lines needlessly.

<davidm@wailua.hpl.hp.com> (02/04/19 1.489.11.3)
   Cset exclude: davidm@napali.hpl.hp.com|ChangeSet|20020315234532|54616

<davidm@wailua.hpl.hp.com> (02/04/19 1.456.7.6)
   agpgart_be.c:
     ia64: Add missing parenthesis for the pdev
     argument in "unused" attribute of the setup
     routines.

<davidm@wailua.hpl.hp.com> (02/04/19 1.489.12.1)
   Update with latest version.

<davidm@wailua.hpl.hp.com> (02/04/18 1.489.11.2)
   ia64: Fix typo that prevented _PRT from being found on zx1.

<davidm@wailua.hpl.hp.com> (02/04/18 1.489.3.4)
   ia64: Include config file for fusion driver in arch/ia64/config.in.

<steiner@sgi.com> (02/04/16 1.489.3.3)
   [PATCH] ia64: Correct copyright message in shub_md.h.

<davidm@wailua.hpl.hp.com> (02/04/16 1.489.3.2)
   ia64: Fix alloc_consistent() for zx1 platform to return <4GB memory as per
   DMA-mapping.txt.  Patch by Alex Williamson.

