From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Date: Tue, 12 Mar 2013 04:47:08 +0000
Subject: [PATCH 02/18] ia64: remove cast for kmalloc return value
Message-Id: <513EB34C.5060608@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <513EB23D.7020303@cn.fujitsu.com>
In-Reply-To: <513EB23D.7020303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

remove cast for kmalloc return value.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/mca_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 9392e02..94f8bf7 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -349,7 +349,7 @@ init_record_index_pools(void)
 
 	/* - 3 - */
 	slidx_pool.max_idx = (rec_max_size/sect_min_size) * 2 + 1;
-	slidx_pool.buffer = (slidx_list_t *)
+	slidx_pool.buffer  		kmalloc(slidx_pool.max_idx * sizeof(slidx_list_t), GFP_KERNEL);
 
 	return slidx_pool.buffer ? 0 : -ENOMEM;
-- 
1.7.1

