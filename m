From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 18:04:53 +0000
Subject: [PATCH 3/5] ia64/mm/tlb: Fix indentation in ia64_global_tlb_purge()
Message-Id: <9adf5338-d549-f0ff-df0a-2f02f8bc5477@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
In-Reply-To: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Paolo Bonzini <pbonzini@redhat.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 19:36:39 +0200

The script "checkpatch.pl" pointed the following information out.

ERROR: code indent should use tabs where possible
#40: FILE: arch/ia64/mm/tlb.c:271

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 arch/ia64/mm/tlb.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 46ecc5d..6d2f83d 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -269,9 +269,8 @@ ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
 	if (need_ptcg_sem)
 		up_spin(&ptcg_sem);
 
-        if (mm != active_mm) {
-                activate_context(active_mm);
-        }
+	if (mm != active_mm)
+		activate_context(active_mm);
 }
 
 void
-- 
2.9.3

