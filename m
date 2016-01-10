From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:19:35 +0000
Subject: [PATCH v3 22/41] s390: define __smp_xxx
Message-Id: <1452426622-4471-23-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Martin

This defines __smp_xxx barriers for s390,
for use by virtualization.

Some smp_xxx barriers are removed as they are
defined correctly by asm-generic/barriers.h

Note: smp_mb, smp_rmb and smp_wmb are defined as full barriers
unconditionally on this architecture.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/include/asm/barrier.h | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
index c358c31..fbd25b2 100644
--- a/arch/s390/include/asm/barrier.h
+++ b/arch/s390/include/asm/barrier.h
@@ -26,18 +26,21 @@
 #define wmb()				barrier()
 #define dma_rmb()			mb()
 #define dma_wmb()			mb()
-#define smp_mb()			mb()
-#define smp_rmb()			rmb()
-#define smp_wmb()			wmb()
-
-#define smp_store_release(p, v)						\
+#define __smp_mb()			mb()
+#define __smp_rmb()			rmb()
+#define __smp_wmb()			wmb()
+#define smp_mb()			__smp_mb()
+#define smp_rmb()			__smp_rmb()
+#define smp_wmb()			__smp_wmb()
+
+#define __smp_store_release(p, v)					\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	WRITE_ONCE(*p, v);						\
 } while (0)
 
-#define smp_load_acquire(p)						\
+#define __smp_load_acquire(p)						\
 ({									\
 	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
-- 
MST

