From: Martin Hicks <mort@wildopensource.com>
Date: Wed, 18 Feb 2004 15:32:20 +0000
Subject: Compile fixes for 2.6.3-mm1
Message-Id: <20040218153220.GJ12142@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="USQ0BwiCE5W4XvtQ"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--USQ0BwiCE5W4XvtQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi,

I had to apply the following two patches to get 2.6.3-mm1 to compile on
ia64.  I'm not sure if the pfn_to_nid() is correct.  I used an extern to
avoid a circular include of asm/numa.h and asm/mmzone.h

I also reverted the compat-ipc-consolidation.patch patch because it
didn't compile and I couldn't even find a trace of
struct compat_ipc64_perm

mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296

--USQ0BwiCE5W4XvtQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="compile-fixes-2.6.3-mm1.patch"

===== include/asm-ia64/mmzone.h 1.8 vs edited =====
--- 1.8/include/asm-ia64/mmzone.h	Tue Feb  3 21:35:17 2004
+++ edited/include/asm-ia64/mmzone.h	Wed Feb 18 06:53:42 2004
@@ -28,10 +28,12 @@
 #endif
 
 extern unsigned long max_low_pfn;
+extern int paddr_to_nid(unsigned long paddr);
 
 #define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
 #define page_to_pfn(page)	((unsigned long) (page - vmem_map))
 #define pfn_to_page(pfn)	(vmem_map + (pfn))
+#define pfn_to_nid(pfn)		paddr_to_nid((pfn) << PAGE_SHIFT)
 
 #else /* CONFIG_DISCONTIGMEM */
 # define NR_NODE_MEMBLKS	4
===== include/linux/msg.h 1.5 vs edited =====
--- 1.5/include/linux/msg.h	Wed Feb 18 01:09:43 2004
+++ edited/include/linux/msg.h	Wed Feb 18 06:57:57 2004
@@ -2,6 +2,7 @@
 #define _LINUX_MSG_H
 
 #include <linux/ipc.h>
+#include <linux/list.h>
 
 /* ipcs ctl commands */
 #define MSG_STAT 11

--USQ0BwiCE5W4XvtQ--
