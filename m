From: Troy Heber <troy.heber@hp.com>
Date: Wed, 25 Oct 2006 20:46:15 +0000
Subject: [PATCH] move SAL_CACHE_FLUSH check later in boot
Message-Id: <20061025204615.GA23281@pc.troyhebe>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The check to see if the firmware drops interrupts during a
SAL_CACHE_FLUSH is done to early in the boot. SAL_CACHE_FLUSH expects
to be able to make PAL calls in virtual mode, on some cell based
machines a fault occurs causing a MCA. This patch moves the check
after mmu_context_init so the TLB and VHPT are properly setup.

Signed-off-by Troy Heber <troy.heber@hp.com>
---
diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index 642fdc7..20bad78 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -223,12 +223,13 @@ #endif
  */
 static int sal_cache_flush_drops_interrupts;
 
-static void __init
+void __init
 check_sal_cache_flush (void)
 {
 	unsigned long flags;
 	int cpu;
-	u64 vector;
+	u64 vector, cache_type = 3;
+	struct ia64_sal_retval isrv;
 
 	cpu = get_cpu();
 	local_irq_save(flags);
@@ -243,7 +244,10 @@ check_sal_cache_flush (void)
 	while (!ia64_get_irr(IA64_TIMER_VECTOR))
 		cpu_relax();
 
-	ia64_sal_cache_flush(3);
+	SAL_CALL(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0, 0, 0);
+
+	if (isrv.status)
+		printk(KERN_ERR "SAL_CAL_FLUSH failed with %ld\n", isrv.status);
 
 	if (ia64_get_irr(IA64_TIMER_VECTOR)) {
 		vector = ia64_get_ivr();
@@ -331,7 +335,6 @@ #endif
 		p += SAL_DESC_SIZE(*p);
 	}
 
-	check_sal_cache_flush();
 }
 
 int
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 28751be..cc55845 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -494,6 +494,8 @@ #endif
 	cpu_init();	/* initialize the bootstrap CPU */
 	mmu_context_init();	/* initialize context_id bitmap */
 
+	check_sal_cache_flush();
+
 #ifdef CONFIG_ACPI
 	acpi_boot_init();
 #endif
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 0b210ab..d000689 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -659,6 +659,7 @@ ia64_sal_freq_base (unsigned long which,
 }
 
 extern s64 ia64_sal_cache_flush (u64 cache_type);
+extern void __init check_sal_cache_flush (void);
 
 /* Initialize all the processor and platform level instruction and data caches */
 static inline s64
