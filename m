From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 12 Dec 2002 17:13:55 +0000
Subject: [Linux-ia64] ia32 emulation layer bug fix
Message-Id: <marc-linux-ia64-105590709805553@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

sys32_mprotect code isn't dropping ia32_mmap_sem before returning. This
affects both 2.4 and 2.5.

--- linux/arch/ia64/ia32/sys_ia32.c-	Wed Dec 11 20:30:25 2002
+++ linux/arch/ia64/ia32/sys_ia32.c	Wed Dec 11 20:30:31 2002
@@ -623,7 +623,8 @@
 			/* end address is 4KB aligned but not page aligned. */
 			retval = mprotect_subpage(PAGE_START(end), prot);
 			if (retval < 0)
-				return retval;
+				goto out;
+				  
 			end = PAGE_START(end);
 		}
 		retval = sys_mprotect(start, end - start, prot);


	-Arun


