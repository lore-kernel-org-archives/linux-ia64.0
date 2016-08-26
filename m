From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 18:05:53 +0000
Subject: [PATCH 4/5] ia64/mm/tlb: Use kmalloc_array() in ia64_itr_entry()
Message-Id: <cdd32fc4-523b-d6fe-2e0c-4506bac7469b@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
In-Reply-To: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Paolo Bonzini <pbonzini@redhat.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 19:43:34 +0200

* A multiplication for the size determination of a memory allocation
  indicated that an array data structure should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of a data structure by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 arch/ia64/mm/tlb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 6d2f83d..30870d1 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -429,8 +429,9 @@ int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size)
 	int cpu = smp_processor_id();
 
 	if (!ia64_idtrs[cpu]) {
-		ia64_idtrs[cpu] = kmalloc(2 * IA64_TR_ALLOC_MAX *
-				sizeof (struct ia64_tr_entry), GFP_KERNEL);
+		ia64_idtrs[cpu] = kmalloc_array(2 * IA64_TR_ALLOC_MAX,
+						sizeof(*ia64_idtrs[cpu]),
+						GFP_KERNEL);
 		if (!ia64_idtrs[cpu])
 			return -ENOMEM;
 	}
-- 
2.9.3

