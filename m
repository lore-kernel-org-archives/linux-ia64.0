From: Julia Lawall <Julia.Lawall@inria.fr>
Date: Fri, 18 Mar 2022 10:36:56 +0000
Subject: [PATCH] ia64: fix typos in comments
Message-Id: <20220318103729.157574-1-Julia.Lawall@inria.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

Various spelling mistakes in comments.
Detected with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@inria.fr>

---
 arch/ia64/kernel/palinfo.c |    2 +-
 arch/ia64/kernel/traps.c   |    2 +-
 arch/ia64/mm/init.c        |    2 +-
 arch/ia64/mm/tlb.c         |    4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index 64189f04c1a4..b9ae093bfe37 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -120,7 +120,7 @@ static const char *mem_attrib[]={
  * Input:
  *	- a pointer to a buffer to hold the string
  *	- a 64-bit vector
- * Ouput:
+ * Output:
  *	- a pointer to the end of the buffer
  *
  */
diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index 753642366e12..53735b1d1be3 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -309,7 +309,7 @@ handle_fpu_swa (int fp_fault, struct pt_regs *regs, unsigned long isr)
 			/*
 			 * Lower 4 bits are used as a count. Upper bits are a sequence
 			 * number that is updated when count is reset. The cmpxchg will
-			 * fail is seqno has changed. This minimizes mutiple cpus
+			 * fail is seqno has changed. This minimizes multiple cpus
 			 * resetting the count.
 			 */
 			if (current_jiffies > last.time)
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 5d165607bf35..7ae1244ed8ec 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -451,7 +451,7 @@ mem_init (void)
 	memblock_free_all();
 
 	/*
-	 * For fsyscall entrpoints with no light-weight handler, use the ordinary
+	 * For fsyscall entrypoints with no light-weight handler, use the ordinary
 	 * (heavy-weight) handler, but mark it by setting bit 0, so the fsyscall entry
 	 * code can tell them apart.
 	 */
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 135b5135cace..ca060e7a2a46 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -174,7 +174,7 @@ __setup("nptcg=", set_nptcg);
  * override table (in which case we should ignore the value from
  * PAL_VM_SUMMARY).
  *
- * Kernel parameter "nptcg=" overrides maximum number of simultanesous ptc.g
+ * Kernel parameter "nptcg=" overrides maximum number of simultaneous ptc.g
  * purges defined in either PAL_VM_SUMMARY or PAL override table. In this case,
  * we should ignore the value from either PAL_VM_SUMMARY or PAL override table.
  *
@@ -516,7 +516,7 @@ int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size)
 	if (i >= per_cpu(ia64_tr_num, cpu))
 		return -EBUSY;
 
-	/*Record tr info for mca hander use!*/
+	/*Record tr info for mca handler use!*/
 	if (i > per_cpu(ia64_tr_used, cpu))
 		per_cpu(ia64_tr_used, cpu) = i;
 
