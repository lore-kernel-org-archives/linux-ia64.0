From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 31 Dec 2015 19:08:53 +0000
Subject: [PATCH v2 24/32] sparc: define __smp_xxx
Message-Id: <1451572003-2440-25-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@kernel.org>, Ralf Baechle <ralf@linux-mips.org>, Andrey Konovalov <andreyknvl@googl>

This defines __smp_xxx barriers for sparc,
for use by virtualization.

smp_xxx barriers are removed as they are
defined correctly by asm-generic/barriers.h

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/sparc/include/asm/barrier_64.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/sparc/include/asm/barrier_64.h b/arch/sparc/include/asm/barrier_64.h
index 26c3f72..c9f6ee6 100644
--- a/arch/sparc/include/asm/barrier_64.h
+++ b/arch/sparc/include/asm/barrier_64.h
@@ -37,14 +37,14 @@ do {	__asm__ __volatile__("ba,pt	%%xcc, 1f\n\t" \
 #define rmb()	__asm__ __volatile__("":::"memory")
 #define wmb()	__asm__ __volatile__("":::"memory")
 
-#define smp_store_release(p, v)						\
+#define __smp_store_release(p, v)						\
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
@@ -52,8 +52,8 @@ do {									\
 	___p1;								\
 })
 
-#define smp_mb__before_atomic()	barrier()
-#define smp_mb__after_atomic()	barrier()
+#define __smp_mb__before_atomic()	barrier()
+#define __smp_mb__after_atomic()	barrier()
 
 #include <asm-generic/barrier.h>
 
-- 
MST

