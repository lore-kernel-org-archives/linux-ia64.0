From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:17:27 +0000
Subject: [PATCH v3 07/41] sparc: reuse asm-generic/barrier.h
Message-Id: <1452426622-4471-8-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@k>

On sparc 64 bit dma_rmb, dma_wmb, smp_store_mb, smp_mb, smp_rmb,
smp_wmb, read_barrier_depends and smp_read_barrier_depends match the
asm-generic variants exactly. Drop the local definitions and pull in
asm-generic/barrier.h instead.

nop uses __asm__ __volatile but is otherwise identical to
the generic version, drop that as well.

This is in preparation to refactoring this code area.

Note: nop() was in processor.h and not in barrier.h as on other
architectures. Nothing seems to depend on it being there though.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/barrier_32.h |  1 -
 arch/sparc/include/asm/barrier_64.h | 21 ++-------------------
 arch/sparc/include/asm/processor.h  |  3 ---
 3 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/arch/sparc/include/asm/barrier_32.h b/arch/sparc/include/asm/barrier_32.h
index ae69eda..8059130 100644
--- a/arch/sparc/include/asm/barrier_32.h
+++ b/arch/sparc/include/asm/barrier_32.h
@@ -1,7 +1,6 @@
 #ifndef __SPARC_BARRIER_H
 #define __SPARC_BARRIER_H
 
-#include <asm/processor.h> /* for nop() */
 #include <asm-generic/barrier.h>
 
 #endif /* !(__SPARC_BARRIER_H) */
diff --git a/arch/sparc/include/asm/barrier_64.h b/arch/sparc/include/asm/barrier_64.h
index 14a9286..26c3f72 100644
--- a/arch/sparc/include/asm/barrier_64.h
+++ b/arch/sparc/include/asm/barrier_64.h
@@ -37,25 +37,6 @@ do {	__asm__ __volatile__("ba,pt	%%xcc, 1f\n\t" \
 #define rmb()	__asm__ __volatile__("":::"memory")
 #define wmb()	__asm__ __volatile__("":::"memory")
 
-#define dma_rmb()	rmb()
-#define dma_wmb()	wmb()
-
-#define smp_store_mb(__var, __value) \
-	do { WRITE_ONCE(__var, __value); membar_safe("#StoreLoad"); } while(0)
-
-#ifdef CONFIG_SMP
-#define smp_mb()	mb()
-#define smp_rmb()	rmb()
-#define smp_wmb()	wmb()
-#else
-#define smp_mb()	__asm__ __volatile__("":::"memory")
-#define smp_rmb()	__asm__ __volatile__("":::"memory")
-#define smp_wmb()	__asm__ __volatile__("":::"memory")
-#endif
-
-#define read_barrier_depends()		do { } while (0)
-#define smp_read_barrier_depends()	do { } while (0)
-
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
@@ -74,4 +55,6 @@ do {									\
 #define smp_mb__before_atomic()	barrier()
 #define smp_mb__after_atomic()	barrier()
 
+#include <asm-generic/barrier.h>
+
 #endif /* !(__SPARC64_BARRIER_H) */
diff --git a/arch/sparc/include/asm/processor.h b/arch/sparc/include/asm/processor.h
index 2fe99e6..9da9646 100644
--- a/arch/sparc/include/asm/processor.h
+++ b/arch/sparc/include/asm/processor.h
@@ -5,7 +5,4 @@
 #else
 #include <asm/processor_32.h>
 #endif
-
-#define nop() 		__asm__ __volatile__ ("nop")
-
 #endif
-- 
MST

