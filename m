From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 24 Jan 2014 01:52:51 +0000
Subject: [PATCH 1/5] ia64: limit stack size for the ski emulator
Message-Id: <alpine.LRH.2.02.1401232043320.16873@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LRH.2.02.1401232041520.16873@file01.intranet.prod.int.rdu2.redhat.com>
In-Reply-To: <alpine.LRH.2.02.1401232041520.16873@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The ski emulator can't spawn any process with larger stack than
0x7ffff00000000.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 arch/ia64/include/asm/resource.h |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6-ia64/arch/ia64/include/asm/resource.h
=================================--- linux-2.6-ia64.orig/arch/ia64/include/uapi/asm/resource.h	2013-04-20 19:14:30.000000000 +0200
+++ linux-2.6-ia64/arch/ia64/include/uapi/asm/resource.h	2013-04-20 20:59:00.000000000 +0200
@@ -2,6 +2,12 @@
 #define _ASM_IA64_RESOURCE_H
 
 #include <asm/ustack.h>
+
+#if defined(__KERNEL__) && defined(CONFIG_IA64_HP_SIM)
+/* The ski simulator can't spawn any process with larger stack size */
+#define _STK_LIM_MAX	0x7ffff00000000UL
+#endif
+
 #include <asm-generic/resource.h>
 
 #endif /* _ASM_IA64_RESOURCE_H */

