From: Christoph Hellwig <hch@lst.de>
Date: Mon, 12 Aug 2019 06:55:23 +0000
Subject: [PATCH 3/4] ia64/kprobes: remove the unused ia64_get_bsp_cfm function
Message-Id: <20190812065524.19959-4-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190812065524.19959-1-hch@lst.de>
In-Reply-To: <20190812065524.19959-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/kprobes.c | 26 --------------------------
 1 file changed, 26 deletions(-)

diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 5de801a2c0f0..b8356edbde65 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -979,32 +979,6 @@ int __kprobes kprobe_exceptions_notify(struct notifier_block *self,
 	return ret;
 }
 
-struct param_bsp_cfm {
-	unsigned long ip;
-	unsigned long *bsp;
-	unsigned long cfm;
-};
-
-static void ia64_get_bsp_cfm(struct unw_frame_info *info, void *arg)
-{
-	unsigned long ip;
-	struct param_bsp_cfm *lp = arg;
-
-	do {
-		unw_get_ip(info, &ip);
-		if (ip = 0)
-			break;
-		if (ip = lp->ip) {
-			unw_get_bsp(info, (unsigned long*)&lp->bsp);
-			unw_get_cfm(info, (unsigned long*)&lp->cfm);
-			return;
-		}
-	} while (unw_unwind(info) >= 0);
-	lp->bsp = NULL;
-	lp->cfm = 0;
-	return;
-}
-
 unsigned long arch_deref_entry_point(void *entry)
 {
 	return ((struct fnptr *)entry)->ip;
-- 
2.20.1
