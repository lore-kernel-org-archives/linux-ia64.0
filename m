From: menglong8.dong@gmail.com
Date: Wed, 03 Mar 2021 08:45:49 +0000
Subject: [PATCH] module: remove duplicate include in arch/ia64/kernel/head.S
Message-Id: <20210303084549.179346-1-zhang.yunkai@zte.com.cn>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: akpm@linux-foundation.org, rppt@kernel.org, zhang.yunkai@zte.com.cn, linux-kernel@vger.kernel.org

From: Zhang Yunkai <zhang.yunkai@zte.com.cn>

'linux/pgtable.h' included in 'arch/ia64/kernel/head.S' is duplicated.

Signed-off-by: Zhang Yunkai <zhang.yunkai@zte.com.cn>
---
 arch/ia64/kernel/head.S | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 30f1ef760136..81b64d1adad5 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -33,7 +33,6 @@
 #include <asm/mca_asm.h>
 #include <linux/init.h>
 #include <linux/linkage.h>
-#include <linux/pgtable.h>
 #include <asm/export.h>
 
 #ifdef CONFIG_HOTPLUG_CPU
-- 
2.25.1
