From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 25 Aug 2016 05:47:04 +0000
Subject: [PATCH] [IA64] MCA: Use kmalloc_array() in init_record_index_pools()
Message-Id: <71e94d34-27fc-1c98-50aa-be96abddabab@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Paolo Bonzini <pbonzini@redhat.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 25 Aug 2016 07:37:46 +0200

* A multiplication for the size determination of a memory allocation
  indicated that an array data structure should be processed.
  Thus reuse the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of a data structure by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 arch/ia64/kernel/mca_drv.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 94f8bf7..e4ce128 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -349,9 +349,9 @@ init_record_index_pools(void)
 
 	/* - 3 - */
 	slidx_pool.max_idx = (rec_max_size/sect_min_size) * 2 + 1;
-	slidx_pool.buffer -		kmalloc(slidx_pool.max_idx * sizeof(slidx_list_t), GFP_KERNEL);
-
+	slidx_pool.buffer = kmalloc_array(slidx_pool.max_idx,
+					  sizeof(*slidx_pool.buffer),
+					  GFP_KERNEL);
 	return slidx_pool.buffer ? 0 : -ENOMEM;
 }
 
-- 
2.9.3

