From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Nov 2002 06:12:42 +0000
Subject: [Linux-ia64] flush_tlb_mm() bug fix
Message-Id: <marc-linux-ia64-105590709805420@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The flush_tlb_mm() routine contained a long-standing bug back from the
days when SMP support was added to ia64 linux.  It causes seemingly
random and temporary memory "corruption" when a multi-threaded task
does a fork() on an SMP machine.  Note that both a conditions are
required: the bug doesn't trigger on UP machines or when fork() is
called from a single-threaded program.  Fortunately, there don't seem
to be all that many programs doing that (OK, if there were more
programs doing that, we would have found the bug earlier...).

A quick patch is below (for the 2.5 tree, 2.4 quick fix is analogous,
except that the change needs to be made in pgalloc.h:flush_tlb_mm()).
A cleaner and (supposedly) better-performing fix is in the 2.5
bitkeeper tree:

	http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.867

Thanks to Steve Goldman and Hans Boehm for helping to identify and
track down the bug

Regards,

	--david

=== include/asm-ia64/tlbflush.h 1.3 vs edited ==--- 1.3/include/asm-ia64/tlbflush.h	Fri Aug  9 17:16:44 2002
+++ edited/include/asm-ia64/tlbflush.h	Wed Nov 13 11:47:37 2002
@@ -39,6 +39,11 @@
 {
 	if (mm) {
 		mm->context = 0;
+#ifdef CONFIG_SMP
+		if (atomic_read(&mm->mm_users) > 1)
+			flush_tlb_all();
+		else
+#endif
 		if (mm = current->active_mm) {
 			/* This is called, e.g., as a result of exec().  */
 			get_new_mmu_context(mm);

