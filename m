From: Meelis Roos <mroos@linux.ee>
Date: Fri, 06 Jun 2014 11:12:11 +0000
Subject: [PATCH] ia64: fix compilation for !CONFIG_FLATMEM
Message-Id: <alpine.SOC.1.00.1406061408190.8408@math.ut.ee>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When CONFIG_FLATMEM is not set, GRANULEROUNDDOWN and GRANULEROUNDUP are 
used in arch/ia64/mm/init.c but compilation fails because they are 
undefined. Include asm/meminit.h to get the definitions.

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 25c3502..499c2dc 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -35,6 +35,7 @@
 #include <asm/unistd.h>
 #include <asm/mca.h>
 #include <asm/paravirt.h>
+#include <asm/meminit.h>
 
 extern void ia64_tlb_init (void);
 

-- 
Meelis Roos (mroos@linux.ee)
