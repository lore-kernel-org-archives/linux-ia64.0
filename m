From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 20 Aug 2004 02:50:18 +0000
Subject: [PATCH] fix missing header in tlb.h
Message-Id: <200408192250.18127.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_qbWJBxMXvwt12tT"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_qbWJBxMXvwt12tT
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I noticed when building with CONFIG_SWAP=n that tlb.h gave a warning about 
some undefined symbols.  This is because it was pulling them in through 
swap.h, but when CONFIG_SWAP=n, they're no longer pulled in.  Adding 
pagemap.h to tlb.h fixes the problem.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_qbWJBxMXvwt12tT
Content-Type: text/x-diff;
  charset="us-ascii";
  name="tlb-missing-header-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="tlb-missing-header-fix.patch"

===== include/asm-ia64/tlb.h 1.22 vs edited =====
--- 1.22/include/asm-ia64/tlb.h	2004-07-10 17:14:00 -07:00
+++ edited/include/asm-ia64/tlb.h	2004-08-19 19:47:57 -07:00
@@ -39,6 +39,7 @@
  */
 #include <linux/config.h>
 #include <linux/mm.h>
+#include <linux/pagemap.h>
 #include <linux/swap.h>
 
 #include <asm/pgalloc.h>

--Boundary-00=_qbWJBxMXvwt12tT--
