From: edwardsg@sgi.com (Greg Edwards)
Date: Tue, 11 May 2004 14:59:23 +0000
Subject: [PATCH] set EXEC_PAGESIZE to PAGE_SIZE
Message-Id: <20040511145923.GC23495@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The number of pages allocated for the gid_t * blocks[] array in the
group_info struct is calculated from EXEC_PAGESIZE.  This is used when
the number of groups goes above 32.  On ia64, this is currently
hard-coded at 65536, which results in only a 1/4 of the required pages
being allocated on a 16k page size kernel.  A setgroups() call with a
gidsetsize of 65536 will end up tromping on memory.  Patch below sets
EXEC_PAGESIZE to PAGE_SIZE.


=== include/asm-ia64/param.h 1.6 vs edited ==--- 1.6/include/asm-ia64/param.h	Wed Feb 18 21:42:38 2004
+++ edited/include/asm-ia64/param.h	Tue May 11 09:04:13 2004
@@ -10,7 +10,7 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
  */
 
-#define EXEC_PAGESIZE	65536
+#define EXEC_PAGESIZE	PAGE_SIZE
 
 #ifndef NOGROUP
 # define NOGROUP	(-1)
