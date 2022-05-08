From: Jason Wang <wangborong@cdjrlc.com>
Date: Sun, 08 May 2022 02:26:28 +0000
Subject: [PATCH] arch/ia64: no need to initialise statics to 0
Message-Id: <20220508022628.96501-1-wangborong@cdjrlc.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yury.norov@gmail.com
Cc: wangborong@cdjrlc.com, akpm@linux-foundation.org, Julia.Lawall@inria.fr, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Static variables do not need to be initialised to 0, because compiler
will initialise all uninitialised statics to 0. Thus, remove the
unneeded initializations.

Signed-off-by: Jason Wang <wangborong@cdjrlc.com>
---
 arch/ia64/mm/tlb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 7a2d608fba74..854e90c4e7eb 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -84,7 +84,7 @@ wrap_mmu_context (struct mm_struct *mm)
 		flush_bit = xchg(&ia64_ctx.flushmap[i], 0);
 		ia64_ctx.bitmap[i] ^= flush_bit;
 	}
- 
+
 	/* use offset at 300 to skip daemons */
 	ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
 				ia64_ctx.max_ctx, 300);
@@ -144,7 +144,7 @@ static inline void up_spin(struct spinaphore *ss)
 static struct spinaphore ptcg_sem;
 static u16 nptcg = 1;
 static int need_ptcg_sem = 1;
-static int toolatetochangeptcgsem = 0;
+static int toolatetochangeptcgsem;
 
 /*
  * Kernel parameter "nptcg=" overrides max number of concurrent global TLB
-- 
2.35.1
