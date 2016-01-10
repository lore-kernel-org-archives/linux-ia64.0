From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:19:19 +0000
Subject: [PATCH v3 20/41] metag: define __smp_xxx
Message-Id: <1452426622-4471-21-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, James Hogan <james.>

This defines __smp_xxx barriers for metag,
for use by virtualization.

smp_xxx barriers are removed as they are
defined correctly by asm-generic/barriers.h

Note: as __smp_XX macros should not depend on CONFIG_SMP, they can not
use the existing fence() macro since that is defined differently between
SMP and !SMP.  For this reason, this patch introduces a wrapper
metag_fence() that doesn't depend on CONFIG_SMP.
fence() is then defined using that, depending on CONFIG_SMP.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/metag/include/asm/barrier.h | 32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/arch/metag/include/asm/barrier.h b/arch/metag/include/asm/barrier.h
index b5b778b..84880c9 100644
--- a/arch/metag/include/asm/barrier.h
+++ b/arch/metag/include/asm/barrier.h
@@ -44,13 +44,6 @@ static inline void wr_fence(void)
 #define rmb()		barrier()
 #define wmb()		mb()
 
-#ifndef CONFIG_SMP
-#define fence()		do { } while (0)
-#define smp_mb()        barrier()
-#define smp_rmb()       barrier()
-#define smp_wmb()       barrier()
-#else
-
 #ifdef CONFIG_METAG_SMP_WRITE_REORDERING
 /*
  * Write to the atomic memory unlock system event register (command 0). This is
@@ -60,26 +53,31 @@ static inline void wr_fence(void)
  * incoherence). It is therefore ineffective if used after and on the same
  * thread as a write.
  */
-static inline void fence(void)
+static inline void metag_fence(void)
 {
 	volatile int *flushptr = (volatile int *) LINSYSEVENT_WR_ATOMIC_UNLOCK;
 	barrier();
 	*flushptr = 0;
 	barrier();
 }
-#define smp_mb()        fence()
-#define smp_rmb()       fence()
-#define smp_wmb()       barrier()
+#define __smp_mb()        metag_fence()
+#define __smp_rmb()       metag_fence()
+#define __smp_wmb()       barrier()
 #else
-#define fence()		do { } while (0)
-#define smp_mb()        barrier()
-#define smp_rmb()       barrier()
-#define smp_wmb()       barrier()
+#define metag_fence()		do { } while (0)
+#define __smp_mb()        barrier()
+#define __smp_rmb()       barrier()
+#define __smp_wmb()       barrier()
 #endif
+
+#ifdef CONFIG_SMP
+#define fence() metag_fence()
+#else
+#define fence()		do { } while (0)
 #endif
 
-#define smp_mb__before_atomic()	barrier()
-#define smp_mb__after_atomic()	barrier()
+#define __smp_mb__before_atomic()	barrier()
+#define __smp_mb__after_atomic()	barrier()
 
 #include <asm-generic/barrier.h>
 
-- 
MST

