From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 17 May 2006 10:01:01 +0000
Subject: [RFC PATCH 07/09] robust VM per_cpu i386 VM area
Message-Id: <Pine.LNX.4.58.0605170600250.8408@gandalf.stny.rr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0605170547490.8408@gandalf.stny.rr.com>
In-Reply-To: <Pine.LNX.4.58.0605170547490.8408@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Paul Mackerras <paulus@samba.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, David Mosberger-Tang <davidm@hpl.hp.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, davem@davemloft.net, arnd@arndb.de, kenneth.w.chen@intel.com, sam@ravnborg.org, clameter@sgi.com, kiran@scalex86.org

This patch allocates the percpu VM area using the fix addresses.
It defines currently 1 meg per cpu.

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

Index: linux-2.6.16-test/include/asm-i386/fixmap.h
=================================--- linux-2.6.16-test.orig/include/asm-i386/fixmap.h	2006-05-17 04:32:27.000000000 -0400
+++ linux-2.6.16-test/include/asm-i386/fixmap.h	2006-05-17 04:59:34.000000000 -0400
@@ -32,6 +32,10 @@
 #include <asm/kmap_types.h>
 #endif

+/* One meg per cpu of VM space */
+#define PERCPU_PAGES 256
+#define PERCPU_SIZE (PERCPU_PAGES << PAGE_SHIFT)
+
 /*
  * Here we define all the compile-time 'special' virtual
  * addresses. The point is to have a constant address at
@@ -83,6 +87,8 @@ enum fixed_addresses {
 #ifdef CONFIG_PCI_MMCONFIG
 	FIX_PCIE_MCFG,
 #endif
+	FIX_PERCPU_BEGIN,
+	FIX_PERCPU_END = FIX_PERCPU_BEGIN+(PERCPU_PAGES*NR_CPUS)-1,
 	__end_of_permanent_fixed_addresses,
 	/* temporary boot-time mappings, used before ioremap() is functional */
 #define NR_FIX_BTMAPS	16

