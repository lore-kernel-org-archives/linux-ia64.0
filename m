From: Greg Edwards <edwardsg@sgi.com>
Date: Tue, 02 Mar 2004 16:19:40 +0000
Subject: [PATCH] missing include in include/asm-ia64/sn/router.h
Message-Id: <20040302161939.GA20466@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The below patch fixes a missing include in include/asm-ia64/sn/router.h.

Regards,
Greg Edwards


=== include/asm-ia64/sn/router.h 1.7 vs edited ==--- 1.7/include/asm-ia64/sn/router.h	Mon Jan 19 00:36:03 2004
+++ edited/include/asm-ia64/sn/router.h	Tue Mar  2 10:07:45 2004
@@ -20,6 +20,7 @@
 #include <asm/sn/vector.h>
 #include <asm/sn/slotnum.h>
 #include <asm/sn/arch.h>
+#include <asm/sn/sgi.h>
 
 typedef uint64_t	router_reg_t;
 
