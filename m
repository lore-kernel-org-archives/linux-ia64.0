From: Keith Owens <kaos@sgi.com>
Date: Fri, 14 Mar 2003 04:39:12 +0000
Subject: [Linux-ia64] [patch] 2.4.20-ia64-021210 unwind.c - allow unw_access_gr(r0)
Message-Id: <marc-linux-ia64-105590709806092@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch is against 2.4.20-ia64-021210.
The patch allows unw_access_gr() to read from r0, to support unwind
directives such as .save ar.pfs,r0 and .save rp,r0.

Index: 20.5/arch/ia64/kernel/unwind.c
--- 20.5/arch/ia64/kernel/unwind.c Sat, 14 Sep 2002 01:17:57 +1000 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.1.2.3.1.1.1.1.2 644)
+++ 20.5(w)/arch/ia64/kernel/unwind.c Fri, 14 Mar 2003 11:58:55 +1100 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.1.2.3.1.1.1.1.2 644)
@@ -235,6 +235,11 @@ unw_access_gr (struct unw_frame_info *in
 	struct pt_regs *pt;
 
 	if ((unsigned) regnum - 1 >= 127) {
+		if (regnum = 0 && !write) {
+			*val = 0;	/* read r0 always returns 0 */
+			*nat = 0;
+			return 0;
+		}
 		dprintk("unwind: trying to access non-existent r%u\n", regnum);
 		return -1;
 	}


