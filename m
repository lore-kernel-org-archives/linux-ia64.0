From: Jason Uhlenkott <jasonuhl@sgi.com>
Date: Wed, 18 Feb 2004 22:13:32 +0000
Subject: [PATCH] 2.6.3: ia64_abort(): Use guard page instead of page 0
Message-Id: <20040218221332.GB87364@dragonfly.csd.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64_abort() macro deliberately writes to address 0 in order to
trigger a page fault and an Oops.  This won't work if the process has
mapped something into page zero:  We'll just print the "kernel BUG"
message and continue (after having stomped on whatever user memory was
at address 0). 

A solution is to write to the guard page in region 5, which is
guaranteed to trigger a page fault.


--- linux-2.6.3.orig/include/asm-ia64/bug.h	Tue Feb 17 19:57:12 2004
+++ linux-2.6.3/include/asm-ia64/bug.h	Wed Feb 18 14:00:14 2004
@@ -4,7 +4,7 @@
 #if (__GNUC__ > 3) || (__GNUC__ = 3 && __GNUC_MINOR__ >= 1)
 # define ia64_abort()	__builtin_trap()
 #else
-# define ia64_abort()	(*(volatile int *) 0 = 0)
+# define ia64_abort()	(*(volatile int *) (0xa000000000000000+2*PERCPU_PAGE_SIZE) = 0)
 #endif
 #define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); ia64_abort(); } while (0)

