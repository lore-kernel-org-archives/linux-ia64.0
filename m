From: Jack Steiner <steiner@sgi.com>
Date: Thu, 06 Jan 2005 21:53:24 +0000
Subject: [PATCH] - Delete duplicate SN2 definition of cpu_logical_id for non-SMP
Message-Id: <20050106215324.GA22647@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Looks like this patch is needed to build non-SMP configurations.

Delete duplicate / stale definition of cpu_logical_id for non-SMP
configurations.


	Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/include/asm-ia64/sn/sn_cpuid.h
=================================--- linux.orig/include/asm-ia64/sn/sn_cpuid.h	2005-01-03 19:55:30.048998168 -0600
+++ linux/include/asm-ia64/sn/sn_cpuid.h	2005-01-06 15:50:15.335369557 -0600
@@ -82,7 +82,6 @@
  */
 
 #ifndef CONFIG_SMP
-#define cpu_logical_id(cpu)			0
 #define cpu_physical_id(cpuid)			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 #endif
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


