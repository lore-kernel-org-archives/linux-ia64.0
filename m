From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sun, 28 Mar 2021 21:55:49 +0000
Subject: [PATCH] ia64: mca: always make IA64_MCA_DEBUG an expression
Message-Id: <20210328215549.830420-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Sergei Trofimovich <slyfox@gentoo.org>, linux-ia64@vger.kernel.org

At least ia64_mca_log_sal_error_record() expects some statement:

    static void ia64_mca_log_sal_error_record(int sal_info_type)
    {
        ...
        if (irq_safe)
            IA64_MCA_DEBUG("CPU %d: SAL log contains %s error record\n",
                smp_processor_id(),
                sal_info_type < ARRAY_SIZE(rec_name) ? rec_name[sal_info_type] : "UNKNOWN");
        ...
    }

Instead of fixing all callers the change expicitly makes IA64_MCA_DEBUG
a non-empty expression.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-ia64@vger.kernel.org
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 arch/ia64/kernel/mca.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 79e76712198c..16088c645e2b 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -109,9 +109,9 @@
 #include "irq.h"
 
 #if defined(IA64_MCA_DEBUG_INFO)
-# define IA64_MCA_DEBUG(fmt...)	printk(fmt)
+# define IA64_MCA_DEBUG(fmt...) printk(fmt)
 #else
-# define IA64_MCA_DEBUG(fmt...)
+# define IA64_MCA_DEBUG(fmt...) do {} while (0)
 #endif
 
 #define NOTIFY_INIT(event, regs, arg, spin)				\
-- 
2.31.1
