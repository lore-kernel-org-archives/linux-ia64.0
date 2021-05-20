From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Thu, 20 May 2021 13:05:57 +0000
Subject: [PATCH v1 1/1] kernel.h: split out panic and oops helpers (ia64 fix)
Message-Id: <20210520130557.55277-1-andriy.shevchenko@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, kernel test robot <lkp@intel.com>

Follow up fix for the "kernel.h: split out panic and oops helpers" patch.

Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---

Andrew, please add as a fix to the above mentioned patch, thanks!

For the record, I haven't got any other messages from any of CIs/bots,
presumably there will be no more or very little reports.

Note, this patch is untested. I have no ia64 compiler at hand.

 arch/ia64/include/asm/pal.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/include/asm/pal.h b/arch/ia64/include/asm/pal.h
index 5c51fceedaf9..e6b652f9e45e 100644
--- a/arch/ia64/include/asm/pal.h
+++ b/arch/ia64/include/asm/pal.h
@@ -99,6 +99,7 @@
 
 #include <linux/types.h>
 #include <asm/fpu.h>
+#include <asm/intrinsics.h>
 
 /*
  * Data types needed to pass information into PAL procedures and
-- 
2.30.2
