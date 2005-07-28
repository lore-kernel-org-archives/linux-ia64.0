From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 28 Jul 2005 21:53:00 +0000
Subject: Change ia64 prefetch to use lfetch.fault
Message-Id: <200507282153.j6SLr0g01028@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't remember whether this has been discussed earlier, won't
it make sense to use the fault variant of lfetch for prefetch()
and prefetchw()?  After all, the caller has high confidence that
the cache line will be used in the future.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- linux-2.6.12/include/asm-ia64/processor.h.orig	2005-07-28 14:46:26.629519713 -0700
+++ linux-2.6.12/include/asm-ia64/processor.h	2005-07-28 14:48:17.037721485 -0700
@@ -682,13 +682,13 @@ ia64_imva (void *addr)
 static inline void
 prefetch (const void *x)
 {
-	 ia64_lfetch(ia64_lfhint_none, x);
+	ia64_lfetch_fault(ia64_lfhint_none, x);
 }
 
 static inline void
 prefetchw (const void *x)
 {
-	ia64_lfetch_excl(ia64_lfhint_none, x);
+	ia64_lfetch_fault_excl(ia64_lfhint_none, x);
 }
 
 #define spin_lock_prefetch(x)	prefetchw(x)

