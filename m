From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:19:27 +0000
Subject: [PATCH v3 21/41] mips: define __smp_xxx
Message-Id: <1452426622-4471-22-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ralf Baechle <ralf@l>

This defines __smp_xxx barriers for mips,
for use by virtualization.

smp_xxx barriers are removed as they are
defined correctly by asm-generic/barriers.h

Note: the only exception is smp_mb__before_llsc which is mips-specific.
We define both the __smp_mb__before_llsc variant (for use in
asm/barriers.h) and smp_mb__before_llsc (for use elsewhere on this
architecture).

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/mips/include/asm/barrier.h | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/arch/mips/include/asm/barrier.h b/arch/mips/include/asm/barrier.h
index 3eac4b9..d296633 100644
--- a/arch/mips/include/asm/barrier.h
+++ b/arch/mips/include/asm/barrier.h
@@ -85,20 +85,20 @@
 #define wmb()		fast_wmb()
 #define rmb()		fast_rmb()
 
-#if defined(CONFIG_WEAK_ORDERING) && defined(CONFIG_SMP)
+#if defined(CONFIG_WEAK_ORDERING)
 # ifdef CONFIG_CPU_CAVIUM_OCTEON
-#  define smp_mb()	__sync()
-#  define smp_rmb()	barrier()
-#  define smp_wmb()	__syncw()
+#  define __smp_mb()	__sync()
+#  define __smp_rmb()	barrier()
+#  define __smp_wmb()	__syncw()
 # else
-#  define smp_mb()	__asm__ __volatile__("sync" : : :"memory")
-#  define smp_rmb()	__asm__ __volatile__("sync" : : :"memory")
-#  define smp_wmb()	__asm__ __volatile__("sync" : : :"memory")
+#  define __smp_mb()	__asm__ __volatile__("sync" : : :"memory")
+#  define __smp_rmb()	__asm__ __volatile__("sync" : : :"memory")
+#  define __smp_wmb()	__asm__ __volatile__("sync" : : :"memory")
 # endif
 #else
-#define smp_mb()	barrier()
-#define smp_rmb()	barrier()
-#define smp_wmb()	barrier()
+#define __smp_mb()	barrier()
+#define __smp_rmb()	barrier()
+#define __smp_wmb()	barrier()
 #endif
 
 #if defined(CONFIG_WEAK_REORDERING_BEYOND_LLSC) && defined(CONFIG_SMP)
@@ -111,6 +111,7 @@
 
 #ifdef CONFIG_CPU_CAVIUM_OCTEON
 #define smp_mb__before_llsc() smp_wmb()
+#define __smp_mb__before_llsc() __smp_wmb()
 /* Cause previous writes to become visible on all CPUs as soon as possible */
 #define nudge_writes() __asm__ __volatile__(".set push\n\t"		\
 					    ".set arch=octeon\n\t"	\
@@ -118,11 +119,12 @@
 					    ".set pop" : : : "memory")
 #else
 #define smp_mb__before_llsc() smp_llsc_mb()
+#define __smp_mb__before_llsc() smp_llsc_mb()
 #define nudge_writes() mb()
 #endif
 
-#define smp_mb__before_atomic()	smp_mb__before_llsc()
-#define smp_mb__after_atomic()	smp_llsc_mb()
+#define __smp_mb__before_atomic()	__smp_mb__before_llsc()
+#define __smp_mb__after_atomic()	smp_llsc_mb()
 
 #include <asm-generic/barrier.h>
 
-- 
MST

