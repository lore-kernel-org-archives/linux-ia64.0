From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 17 May 2006 10:00:09 +0000
Subject: [RFC PATCH 06/09] robust VM per_cpu i386 bootmem
Message-Id: <Pine.LNX.4.58.0605170559410.8408@gandalf.stny.rr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0605170547490.8408@gandalf.stny.rr.com>
In-Reply-To: <Pine.LNX.4.58.0605170547490.8408@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Paul Mackerras <paulus@samba.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, David Mosberger-Tang <davidm@hpl.hp.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, davem@davemloft.net, arnd@arndb.de, kenneth.w.chen@intel.com, sam@ravnborg.org, clameter@sgi.com, kiran@scalex86.org

This patch was to get my VM percpu working on my laptop.  This patch
still needs work to handle NUMA and other types of X86 architectures.

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

Index: linux-2.6.16-test/arch/i386/mm/init.c
=================================--- linux-2.6.16-test.orig/arch/i386/mm/init.c	2006-05-17 04:32:28.000000000 -0400
+++ linux-2.6.16-test/arch/i386/mm/init.c	2006-05-17 04:58:37.000000000 -0400
@@ -772,3 +772,39 @@ void free_initrd_mem(unsigned long start
 	}
 }
 #endif
+
+/*
+ * The following three functions are to impement per_cpu variables
+ * into VM.  per_cpu variables are initialized very early on startup
+ * and before memory management. So the per_cpu initialization needs
+ * a way to allocate pages using bootmem.
+ */
+pud_t __init *pud_boot_alloc(struct mm_struct *mm, pgd_t *pgd,
+			     unsigned long addr, int cpu)
+{
+	return (pud_t*)pgd;
+}
+
+pmd_t __init *pmd_boot_alloc(struct mm_struct *mm, pud_t *pud,
+			     unsigned long addr, int cpu)
+{
+	return pmd_offset(pud, addr);
+}
+
+/* FIXME - handle NUMA handling with the CPU parameter */
+pte_t __init *pte_boot_alloc(struct mm_struct *mm, pmd_t *pmd,
+			     unsigned long addr, int cpu)
+{
+	pte_t *pte;
+
+	if (pmd_none(*pmd)) {
+		pte = alloc_bootmem_pages(PAGE_SIZE);
+		if (!pte)
+			return NULL;
+		mm->nr_ptes++;
+		set_pmd(pmd, __pmd(__pa(pte) | _PAGE_TABLE));
+	} else
+		pte = pte_offset_kernel(pmd, addr);
+
+	return pte;
+}

