From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 13 Aug 2004 22:53:40 +0000
Subject: [PATCH] fix cyclone timer includes
Message-Id: <200408131553.40510.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_0ZUHBv0U+C575Ok"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_0ZUHBv0U+C575Ok
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Small patch to fix the includes for the cyclone timer.  We just happen to be 
getting these if CONFIG_SMP is on, but if it's turned off the build breaks.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_0ZUHBv0U+C575Ok
Content-Type: text/plain;
  charset="us-ascii";
  name="cyclone-includes-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="cyclone-includes-fix.patch"

--- a/arch/ia64/kernel/cyclone.c	2004-08-13 15:50:37 -07:00
+++ b/arch/ia64/kernel/cyclone.c	2004-08-13 15:50:37 -07:00
@@ -1,6 +1,8 @@
+#include <linux/module.h>
 #include <linux/smp.h>
 #include <linux/time.h>
 #include <linux/errno.h>
+#include <asm/io.h>
 
 /* IBM Summit (EXA) Cyclone counter code*/
 #define CYCLONE_CBAR_ADDR 0xFEB00CD0

--Boundary-00=_0ZUHBv0U+C575Ok--
