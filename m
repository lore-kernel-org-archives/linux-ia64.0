From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Sat, 30 Oct 2004 00:03:59 +0000
Subject: [PATCH] move nic_t to asm/sn/types.h
Message-Id: <200410291704.00027.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_wptgBiEJLsXyNec"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_wptgBiEJLsXyNec
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Somehow nic_t crept into arch.h.  Move it to types.h where it belongs (it 
depends on u64, so pull in linux/types.h too).

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_wptgBiEJLsXyNec
Content-Type: text/plain;
  charset="us-ascii";
  name="move-nic-t-to-types.h.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="move-nic-t-to-types.h.patch"

diff -Nru a/include/asm-ia64/sn/arch.h b/include/asm-ia64/sn/arch.h
--- a/include/asm-ia64/sn/arch.h	2004-10-29 17:02:58 -07:00
+++ b/include/asm-ia64/sn/arch.h	2004-10-29 17:02:58 -07:00
@@ -22,8 +22,6 @@
  */
 #define MAX_COMPACT_NODES       2048
 
-typedef u64	nic_t;
-
 extern void sn_flush_all_caches(long addr, long bytes);
 
 #endif /* _ASM_IA64_SN_ARCH_H */
diff -Nru a/include/asm-ia64/sn/types.h b/include/asm-ia64/sn/types.h
--- a/include/asm-ia64/sn/types.h	2004-10-29 17:02:58 -07:00
+++ b/include/asm-ia64/sn/types.h	2004-10-29 17:02:58 -07:00
@@ -9,13 +9,15 @@
 #ifndef _ASM_IA64_SN_TYPES_H
 #define _ASM_IA64_SN_TYPES_H
 
+#include <linux/types.h>
+
 typedef unsigned long 	cpuid_t;
 typedef signed short	nasid_t;	/* node id in numa-as-id space */
 typedef signed char	partid_t;	/* partition ID type */
 typedef unsigned int    moduleid_t;     /* user-visible module number type */
 typedef unsigned int    cmoduleid_t;    /* kernel compact module id type */
 typedef signed char     slabid_t;
-
+typedef u64 nic_t;
 typedef unsigned long iopaddr_t;
 typedef unsigned long paddr_t;
 typedef short cnodeid_t;

--Boundary-00=_wptgBiEJLsXyNec--
