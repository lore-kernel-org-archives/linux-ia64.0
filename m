From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 29 Oct 2004 22:59:00 +0000
Subject: [PATCH] remove duplicate INVALID_* defines from arch.h
Message-Id: <200410291559.00868.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_0ssgBtfe46UYcLV"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_0ssgBtfe46UYcLV
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

When I did the sparse stuff, I noticed some duplicate INVALID_* defines.  This 
patch removes one set of them and adds the proper include file to sn_sal.h.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_0ssgBtfe46UYcLV
Content-Type: text/plain;
  charset="us-ascii";
  name="remove-redundant-invalids.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="remove-redundant-invalids.patch"

===== include/asm-ia64/sn/arch.h 1.11 vs edited =====
--- 1.11/include/asm-ia64/sn/arch.h	2004-10-11 13:04:12 -07:00
+++ edited/include/asm-ia64/sn/arch.h	2004-10-29 15:52:12 -07:00
@@ -27,12 +27,6 @@
 #define NASID_TO_COMPACT_NODEID(nasid)  (nasid_to_cnodeid(nasid))
 #define COMPACT_TO_NASID_NODEID(cnode)  (cnodeid_to_nasid(cnode))
 
-
-#define INVALID_NASID		((nasid_t)-1)
-#define INVALID_SLAB            (slabid_t)-1
-#define INVALID_MODULE		((moduleid_t)-1)
-#define	INVALID_PARTID		((partid_t)-1)
-
 extern void sn_flush_all_caches(long addr, long bytes);
 
 #endif /* _ASM_IA64_SN_ARCH_H */
===== include/asm-ia64/sn/sn_sal.h 1.15 vs edited =====
--- 1.15/include/asm-ia64/sn/sn_sal.h	2004-10-26 16:42:36 -07:00
+++ edited/include/asm-ia64/sn/sn_sal.h	2004-10-29 15:55:04 -07:00
@@ -16,6 +16,7 @@
 #include <asm/sal.h>
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/arch.h>
+#include <asm/sn/geo.h>
 #include <asm/sn/nodepda.h>
 
 // SGI Specific Calls

--Boundary-00=_0ssgBtfe46UYcLV--
