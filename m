From: Keith Owens <kaos@sgi.com>
Date: Fri, 14 Mar 2003 04:37:46 +0000
Subject: [Linux-ia64] [patch] 2.4.21-pre5 ia64 unwind.c - allow unw_access_gr(r0)
Message-Id: <marc-linux-ia64-105590709806091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch is against 2.4.21-pre5 + ia64-021210 + unwind patches from bk
tree (it would be nice to have a released 2.4.21-pre5-ia64 version).
The patch allows unw_access_gr() to read from r0, to support unwind
directives such as .save ar.pfs,r0 and .save rp,r0.

diff -urN 2.4.21-pre5-ia64/arch/ia64/kernel/unwind.c 2.4.21-pre5-ia64/arch/ia64/kernel/unwind.c
--- 2.4.21-pre5-ia64/arch/ia64/kernel/unwind.c	Fri Mar 14 15:24:18 2003
+++ 2.4.21-pre5-ia64/arch/ia64/kernel/unwind.c	Fri Mar 14 15:23:17 2003
@@ -253,6 +253,11 @@
 	struct pt_regs *pt;
 
 	if ((unsigned) regnum - 1 >= 127) {
+		if (regnum = 0 && !write) {
+			*val = 0;	/* read r0 always returns 0 */
+			*nat = 0;
+			return 0;
+		}
 		UNW_DPRINT(0, "unwind.%s: trying to access non-existent r%u\n",
 			   __FUNCTION__, regnum);
 		return -1;


