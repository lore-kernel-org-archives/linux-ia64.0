From: Keith Owens <kaos@sgi.com>
Date: Wed, 19 Mar 2003 03:08:55 +0000
Subject: [Linux-ia64] [patch] 2.4.21-pre5-bk arch/ia64/kernel/unwind.c
Message-Id: <marc-linux-ia64-105590723705268@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David has said that he has applied the take the "read unwind data from
r0" patch to 2.5, so add it to 2.4.  The check for info->pt before
calling get_scratch_regs() is a merge error, get_scratch_regs() does
all the checking (needs to be in 2.5 as well).

--- 2.4.21-pre5-ia64-bk/arch/ia64/kernel/unwind.c	Wed Mar 19 11:56:52 2003
+++ linux/arch/ia64/kernel/unwind.c	Wed Mar 19 14:03:57 2003
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
@@ -318,11 +323,6 @@
 			}
 		} else {
 			/* access a scratch register */
-			if (!info->pt) {
-				UNW_DPRINT(0, "unwind.%s: no pt-regs; cannot access r%d\n",
-					   __FUNCTION__, regnum);
-				return -1;
-			}
 			pt = get_scratch_regs(info);
 			addr = (unsigned long *) (pt + pt_regs_off(regnum));
 			if (info->pri_unat_loc)


