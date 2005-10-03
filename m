From: Dean Roe <roe@sgi.com>
Date: Mon, 03 Oct 2005 16:51:45 +0000
Subject: [PATCH] - Remove references to the SN bist_lock
Message-Id: <20051003165145.GA3350@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove all references to the bist_lock in the SN code as it
is not used for anything.


	Signed-off-by: Dean Roe <roe@sgi.com>



Index: linux-2.6/include/asm-ia64/sn/nodepda.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/nodepda.h
+++ linux-2.6/include/asm-ia64/sn/nodepda.h
@@ -55,7 +55,6 @@
 	 */
 	struct phys_cpuid	phys_cpuid[NR_CPUS];
 	spinlock_t		ptc_lock ____cacheline_aligned_in_smp;
-	spinlock_t		bist_lock;
 };
 
 typedef struct nodepda_s nodepda_t;
Index: linux-2.6/include/asm-ia64/sn/sn_sal.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_sal.h
+++ linux-2.6/include/asm-ia64/sn/sn_sal.h
@@ -694,12 +694,10 @@
 	unsigned long irq_flags;
 
 	cnodeid = nasid_to_cnodeid(get_node_number(paddr));
-	// spin_lock(&NODEPDA(cnodeid)->bist_lock);
 	local_irq_save(irq_flags);
 	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_MEMPROTECT, paddr, len,
 				(u64)nasid_array, perms, 0, 0, 0);
 	local_irq_restore(irq_flags);
-	// spin_unlock(&NODEPDA(cnodeid)->bist_lock);
 	return ret_stuff.status;
 }
 #define SN_MEMPROT_ACCESS_CLASS_0		0x14a080
