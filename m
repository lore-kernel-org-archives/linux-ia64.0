From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 14 Mar 2015 01:12:57 +0000
Subject: [PATCH] ia64: Use bitmap_weight
Message-Id: <1426295577-10836-5-git-send-email-akinobu.mita@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1426295577-10836-1-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1426295577-10836-1-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Use bitmap_weight to count the total number of bits set in bitmap.
This change just simplifies the code a bit.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/hp/common/sba_iommu.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 344387a..9c944fa 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -33,7 +33,7 @@
 #include <linux/acpi.h>
 #include <linux/efi.h>
 #include <linux/nodemask.h>
-#include <linux/bitops.h>         /* hweight64() */
+#include <linux/bitmap.h>         /* bitmap_weight() */
 #include <linux/crash_dump.h>
 #include <linux/iommu-helper.h>
 #include <linux/dma-mapping.h>
@@ -1901,8 +1901,7 @@ static int
 ioc_show(struct seq_file *s, void *v)
 {
 	struct ioc *ioc = v;
-	unsigned long *res_ptr = (unsigned long *)ioc->res_map;
-	int i, used = 0;
+	int used;
 
 	seq_printf(s, "Hewlett Packard %s IOC rev %d.%d\n",
 		ioc->name, ((ioc->rev >> 4) & 0xF), (ioc->rev & 0xF));
@@ -1913,8 +1912,8 @@ ioc_show(struct seq_file *s, void *v)
 	seq_printf(s, "IOVA size       : %ld MB\n", ((ioc->pdir_size >> 3) * iovp_size)/(1024*1024));
 	seq_printf(s, "IOVA page size  : %ld kb\n", iovp_size/1024);
 
-	for (i = 0; i < (ioc->res_size / sizeof(unsigned long)); ++i, ++res_ptr)
-		used += hweight64(*res_ptr);
+	used = bitmap_weight((unsigned long *)ioc->res_map,
+			ioc->res_size * BITS_PER_BYTE);
 
 	seq_printf(s, "PDIR size       : %d entries\n", ioc->pdir_size >> 3);
 	seq_printf(s, "PDIR used       : %d entries\n", used);
-- 
1.9.1

