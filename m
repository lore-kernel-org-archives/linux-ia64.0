From: Nik Nyby <nikolas@gnu.org>
Date: Mon, 29 Jun 2015 20:16:20 +0000
Subject: [PATCH] mm: tlb.c: Trivial: Fix typo in error message
Message-Id: <1435608980-19107-1-git-send-email-nikolas@gnu.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This fixes a typo in two error messages, from "Reigster" to
"Register".

Signed-off-by: Nik Nyby <nikolas@gnu.org>
---
 arch/ia64/mm/tlb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index ed61297..46ecc5d 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -444,7 +444,7 @@ int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size)
 			if (p->pte & 0x1)
 				if (is_tr_overlap(p, va, log_size)) {
 					printk(KERN_DEBUG "Overlapped Entry"
-						"Inserted for TR Reigster!!\n");
+						"Inserted for TR Register!!\n");
 					goto out;
 			}
 		}
@@ -456,7 +456,7 @@ int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size)
 			if (p->pte & 0x1)
 				if (is_tr_overlap(p, va, log_size)) {
 					printk(KERN_DEBUG "Overlapped Entry"
-						"Inserted for TR Reigster!!\n");
+						"Inserted for TR Register!!\n");
 					goto out;
 				}
 		}
-- 
2.1.4

