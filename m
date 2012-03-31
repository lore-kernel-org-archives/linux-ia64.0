From: Kautuk Consul <consul.kautuk@gmail.com>
Date: Sat, 31 Mar 2012 12:03:32 +0000
Subject: [PATCH 09/19 v2] ia64/mm/fault.c: Port OOM changes to ia64_do_page_fault
Message-Id: <1333195412-5217-1-git-send-email-consul.kautuk@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

Commit d065bd810b6deb67d4897a14bfe21f8eb526ba99
(mm: retry page fault when blocking on disk transfer) and
commit 37b23e0525d393d48a7d59f870b3bc061a30ccdb
(x86,mm: make pagefault killable)

The above commits introduced changes into the x86 pagefault handler
for making the page fault handler retryable as well as killable.

These changes reduce the mmap_sem hold time, which is crucial
during OOM killer invocation.

Port these changes to ia64.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 arch/ia64/mm/fault.c |   38 ++++++++++++++++++++++++++++++--------
 1 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 02d29c2..b0c3b29 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -81,6 +81,12 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	struct siginfo si;
 	unsigned long mask;
 	int fault;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+
+	mask = ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
+		| (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_WRITE_BIT));
+
+	flags |= ((mask & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
 
 	/* mmap_sem is performance critical.... */
 	prefetchw(&mm->mmap_sem);
@@ -109,6 +115,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	if (notify_page_fault(regs, TRAP_BRKPT))
 		return;
 
+retry:
 	down_read(&mm->mmap_sem);
 
 	vma = find_vma_prev(mm, address, &prev_vma);
@@ -142,9 +149,6 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	if (((isr >> IA64_ISR_R_BIT) & 1UL) && (!(vma->vm_flags & (VM_READ | VM_WRITE))))
 		goto bad_area;
 
-	mask = (  (((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
-		| (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_WRITE_BIT));
-
 	if ((vma->vm_flags & mask) != mask)
 		goto bad_area;
 
@@ -153,7 +157,11 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, (mask & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
+
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+		return;
+
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We ran out of memory, or some other thing happened
@@ -168,10 +176,24 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 		}
 		BUG();
 	}
-	if (fault & VM_FAULT_MAJOR)
-		current->maj_flt++;
-	else
-		current->min_flt++;
+
+	if (flags & FAULT_FLAG_ALLOW_RETRY) {
+		if (fault & VM_FAULT_MAJOR)
+			current->maj_flt++;
+		else
+			current->min_flt++;
+		if (fault & VM_FAULT_RETRY) {
+			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+
+			 /* No need to up_read(&mm->mmap_sem) as we would
+			 * have already released it in __lock_page_or_retry
+			 * in mm/filemap.c.
+			 */
+
+			goto retry;
+		}
+	}
+
 	up_read(&mm->mmap_sem);
 	return;
 
-- 
1.7.5.4

