From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 27 Feb 2012 23:08:25 +0000
Subject: [PATCH] ia64: fix a couple of warnings for EXPORT_SYMBOL
Message-Id: <1330384105-27794-1-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, jes@trained-monkey.org, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>

To get rid of things like:

arch/ia64/sn/kernel/sn2/sn_hwperf.c:1002:1: warning: data definition has no type or storage class
arch/ia64/sn/kernel/sn2/sn_hwperf.c:1002:1: warning: type defaults to 'int' in declaration of 'EXPORT_SYMBOL'
arch/ia64/sn/kernel/sn2/sn_hwperf.c:1002:1: warning: parameter names (without types) in function declaration

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[I can carry this patch if required, but it is 100% independent and
 can go in via the ia64 maintainers.  Let me know which is best. ]

diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 4433dd0..fbb5f2f 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/bootmem.h>
+#include <linux/export.h>
 #include <linux/slab.h>
 #include <asm/sn/types.h>
 #include <asm/sn/addrs.h>
diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index 2de41d4..4554f68 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -25,6 +25,7 @@
 
 #include <linux/fs.h>
 #include <linux/slab.h>
+#include <linux/export.h>
 #include <linux/vmalloc.h>
 #include <linux/seq_file.h>
 #include <linux/miscdevice.h>
-- 
1.7.9.1

