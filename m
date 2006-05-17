From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 17 May 2006 09:58:28 +0000
Subject: [RFC PATCH 04/09] robust VM per_cpu main startup
Message-Id: <Pine.LNX.4.58.0605170557580.8408@gandalf.stny.rr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0605170547490.8408@gandalf.stny.rr.com>
In-Reply-To: <Pine.LNX.4.58.0605170547490.8408@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Paul Mackerras <paulus@samba.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, David Mosberger-Tang <davidm@hpl.hp.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, davem@davemloft.net, arnd@arndb.de, kenneth.w.chen@intel.com, sam@ravnborg.org, clameter@sgi.com, kiran@scalex86.org

This patch disables the generic setup if __ARCH_HAS_VM_PERCPU defined.

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

Index: linux-2.6.16-test/init/main.c
=================================--- linux-2.6.16-test.orig/init/main.c	2006-05-17 04:32:28.000000000 -0400
+++ linux-2.6.16-test/init/main.c	2006-05-17 04:57:45.000000000 -0400
@@ -324,7 +324,7 @@ static inline void smp_prepare_cpus(unsi

 #else

-#ifdef __GENERIC_PER_CPU
+#if defined(__GENERIC_PER_CPU) && !defined(__ARCH_HAS_VM_PERCPU)
 unsigned long __per_cpu_offset[NR_CPUS];

 EXPORT_SYMBOL(__per_cpu_offset);

