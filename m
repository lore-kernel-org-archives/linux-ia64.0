From: Erich Focht <efocht@ess.nec.de>
Date: Wed, 10 Jul 2002 17:27:20 +0000
Subject: [Linux-ia64] switch_mm race condition with Ingo's scheduler
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------Boundary-00=_K5N18FDJZT5RLQ64YKT4"
Message-Id: <marc-linux-ia64-105590701905759@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--------------Boundary-00=_K5N18FDJZT5RLQ64YKT4
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi David,

the attached patch fixes the switch_mm -> wrap_mmu_context deadlock which
can occur in 2.5.18+ia64. We discussed this in January/February...

Regards,
Erich

--------------Boundary-00=_K5N18FDJZT5RLQ64YKT4
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="wrap_mmu_ia64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="wrap_mmu_ia64.patch"

diff -urNp linux-2.5.18-ia64/arch/ia64/mm/tlb.c linux-2.5.18-ia64-wrap/arch/ia64/mm/tlb.c
--- linux-2.5.18-ia64/arch/ia64/mm/tlb.c	Sat May 25 03:55:29 2002
+++ linux-2.5.18-ia64-wrap/arch/ia64/mm/tlb.c	Wed Jul 10 17:08:46 2002
@@ -77,7 +77,11 @@ wrap_mmu_context (struct mm_struct *mm)
 			ia64_ctx.limit = tsk_context;
 	}
 	read_unlock(&tasklist_lock);
-	flush_tlb_all();
+	//flush_tlb_all(); /* potential race condition with O(1) scheduler [EF] */
+	for (i=0; i<smp_num_cpus; i++)
+		cpu_data(i)->tlb_flush = 1;
+	__flush_tlb_all();
+	local_cpu_data->tlb_flush = 0;
 }
 
 void
diff -urNp linux-2.5.18-ia64/include/asm-ia64/mmu_context.h linux-2.5.18-ia64-wrap/include/asm-ia64/mmu_context.h
--- linux-2.5.18-ia64/include/asm-ia64/mmu_context.h	Sat May 25 03:55:19 2002
+++ linux-2.5.18-ia64-wrap/include/asm-ia64/mmu_context.h	Wed Jul 10 17:03:03 2002
@@ -44,6 +44,23 @@ enter_lazy_tlb (struct mm_struct *mm, st
 {
 }
 
+/* 
+ * When the context counter wraps around all TLBs need to be flushed because
+ * an old context number might have been reused. This is signalled by a bit
+ * set in ia64_ctx.flush, which is checked in the routine below. Called by
+ * activate_mm().                                        <efocht@ess.nec.de>
+ */
+static inline void
+delayed_tlb_flush (void)
+{
+	extern void __flush_tlb_all (void);
+
+	if (unlikely(local_cpu_data->tlb_flush)) {
+		__flush_tlb_all();
+		local_cpu_data->tlb_flush = 0;
+	}
+}
+
 static inline void
 get_new_mmu_context (struct mm_struct *mm)
 {
@@ -54,7 +71,6 @@ get_new_mmu_context (struct mm_struct *m
 		mm->context = ia64_ctx.next++;
 	}
 	spin_unlock(&ia64_ctx.lock);
-
 }
 
 static inline void
@@ -113,6 +129,7 @@ activate_mm (struct mm_struct *prev, str
 	 * We may get interrupts here, but that's OK because interrupt
 	 * handlers cannot touch user-space.
 	 */
+	delayed_tlb_flush();
 	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->pgd));
 	get_mmu_context(next);
 	reload_context(next);
diff -urNp linux-2.5.18-ia64/include/asm-ia64/processor.h linux-2.5.18-ia64-wrap/include/asm-ia64/processor.h
--- linux-2.5.18-ia64/include/asm-ia64/processor.h	Thu Jul  4 12:23:26 2002
+++ linux-2.5.18-ia64-wrap/include/asm-ia64/processor.h	Wed Jul 10 17:05:20 2002
@@ -151,6 +151,7 @@ extern struct cpuinfo_ia64 {
 	/* CPUID-derived information: */
 	__u64 ppn;
 	__u64 features;
+	__u8 tlb_flush;		/* flush TLB before next context switch if non-zero */
 	__u8 number;
 	__u8 revision;
 	__u8 model;

--------------Boundary-00=_K5N18FDJZT5RLQ64YKT4--


