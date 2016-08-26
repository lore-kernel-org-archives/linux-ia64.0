From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 18:06:58 +0000
Subject: [PATCH 5/5] ia64/mm/tlb: Delete unnecessary braces
Message-Id: <1405adbb-c4d7-911c-5e7e-b5ea76719819@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
In-Reply-To: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Paolo Bonzini <pbonzini@redhat.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 19:45:24 +0200

Do not use curly brackets at a few source code places
where a single statement should be sufficient.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 arch/ia64/mm/tlb.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 30870d1..e2b7435 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -244,7 +244,7 @@ ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
 
 	toolatetochangeptcgsem = 1;
 
-	if (mm != active_mm) {
+	if (mm != active_mm)
 		/* Restore region IDs for mm */
 		if (mm && active_mm) {
 			activate_context(mm);
@@ -252,7 +252,6 @@ ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
 			flush_tlb_all();
 			return;
 		}
-	}
 
 	if (need_ptcg_sem)
 		down_spin(&ptcg_sem);
@@ -440,14 +439,13 @@ int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size)
 	if (target_mask & 0x1) {
 		p = ia64_idtrs[cpu];
 		for (i = IA64_TR_ALLOC_BASE; i <= per_cpu(ia64_tr_used, cpu);
-								i++, p++) {
+								i++, p++)
 			if (p->pte & 0x1)
 				if (is_tr_overlap(p, va, log_size)) {
 					printk(KERN_DEBUG "Overlapped Entry"
 						"Inserted for TR Register!!\n");
 					goto out;
 			}
-		}
 	}
 	if (target_mask & 0x2) {
 		p = ia64_idtrs[cpu] + IA64_TR_ALLOC_MAX;
@@ -551,11 +549,10 @@ void ia64_ptr_entry(u64 target_mask, int slot)
 		}
 	}
 
-	for (i = per_cpu(ia64_tr_used, cpu); i >= IA64_TR_ALLOC_BASE; i--) {
+	for (i = per_cpu(ia64_tr_used, cpu); i >= IA64_TR_ALLOC_BASE; i--)
 		if (((ia64_idtrs[cpu] + i)->pte & 0x1) ||
 		    ((ia64_idtrs[cpu] + IA64_TR_ALLOC_MAX + i)->pte & 0x1))
 			break;
-	}
 	per_cpu(ia64_tr_used, cpu) = i;
 }
 EXPORT_SYMBOL_GPL(ia64_ptr_entry);
-- 
2.9.3

