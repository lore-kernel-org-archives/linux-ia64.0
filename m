From: Sheng Yong <shengyong1@huawei.com>
Date: Fri, 13 Feb 2015 09:01:19 +0000
Subject: [PATCH] mm: Use macro to switch between section and pfn
Message-Id: <1423818079-202291-1-git-send-email-shengyong1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use macro section_nr_to_pfn and pfn_to_section_nr to switch between section
and pfn, instead of bit operations, no semantic changes.

Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 arch/ia64/mm/numa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
index ea21d4c..40287c7 100644
--- a/arch/ia64/mm/numa.c
+++ b/arch/ia64/mm/numa.c
@@ -60,7 +60,7 @@ paddr_to_nid(unsigned long paddr)
  */
 int __meminit __early_pfn_to_nid(unsigned long pfn)
 {
-	int i, section = pfn >> PFN_SECTION_SHIFT, ssec, esec;
+	int i, section = pfn_to_section_nr(pfn), ssec, esec;
 	/*
 	 * NOTE: The following SMP-unsafe globals are only used early in boot
 	 * when the kernel is running single-threaded.
-- 
1.8.3.4

