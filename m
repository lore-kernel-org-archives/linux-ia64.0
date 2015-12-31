From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 31 Dec 2015 19:07:35 +0000
Subject: [PATCH v2 14/32] asm-generic: add __smp_xxx wrappers
Message-Id: <1451572003-2440-15-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-1-git-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org

On !SMP, most architectures define their
barriers as compiler barriers.
On SMP, most need an actual barrier.

Make it possible to remove the code duplication for
!SMP by defining low-level __smp_xxx barriers
which do not depend on the value of SMP, then
use them from asm-generic conditionally.

Besides reducing code duplication, these low level APIs will also be
useful for virtualization, where a barrier is sometimes needed even if
!SMP since we might be talking to another kernel on the same SMP system.

Both virtio and Xen drivers will benefit.

The smp_xxx variants should use __smp_XXX ones or barrier() depending on
SMP, identically for all architectures.

We keep ifndef guards around them for now - once/if all
architectures are converted to use the generic
code, we'll be able to remove these.

Suggested-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 include/asm-generic/barrier.h | 91 ++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 82 insertions(+), 9 deletions(-)

diff --git a/include/asm-generic/barrier.h b/include/asm-generic/barrier.h
index 987b2e0..8752964 100644
--- a/include/asm-generic/barrier.h
+++ b/include/asm-generic/barrier.h
@@ -54,22 +54,38 @@
 #define read_barrier_depends()		do { } while (0)
 #endif
 
+#ifndef __smp_mb
+#define __smp_mb()	mb()
+#endif
+
+#ifndef __smp_rmb
+#define __smp_rmb()	rmb()
+#endif
+
+#ifndef __smp_wmb
+#define __smp_wmb()	wmb()
+#endif
+
+#ifndef __smp_read_barrier_depends
+#define __smp_read_barrier_depends()	read_barrier_depends()
+#endif
+
 #ifdef CONFIG_SMP
 
 #ifndef smp_mb
-#define smp_mb()	mb()
+#define smp_mb()	__smp_mb()
 #endif
 
 #ifndef smp_rmb
-#define smp_rmb()	rmb()
+#define smp_rmb()	__smp_rmb()
 #endif
 
 #ifndef smp_wmb
-#define smp_wmb()	wmb()
+#define smp_wmb()	__smp_wmb()
 #endif
 
 #ifndef smp_read_barrier_depends
-#define smp_read_barrier_depends()	read_barrier_depends()
+#define smp_read_barrier_depends()	__smp_read_barrier_depends()
 #endif
 
 #else	/* !CONFIG_SMP */
@@ -92,23 +108,78 @@
 
 #endif	/* CONFIG_SMP */
 
+#ifndef __smp_store_mb
+#define __smp_store_mb(var, value)  do { WRITE_ONCE(var, value); __smp_mb(); } while (0)
+#endif
+
+#ifndef __smp_mb__before_atomic
+#define __smp_mb__before_atomic()	__smp_mb()
+#endif
+
+#ifndef __smp_mb__after_atomic
+#define __smp_mb__after_atomic()	__smp_mb()
+#endif
+
+#ifndef __smp_store_release
+#define __smp_store_release(p, v)					\
+do {									\
+	compiletime_assert_atomic_type(*p);				\
+	__smp_mb();							\
+	WRITE_ONCE(*p, v);						\
+} while (0)
+#endif
+
+#ifndef __smp_load_acquire
+#define __smp_load_acquire(p)						\
+({									\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
+	compiletime_assert_atomic_type(*p);				\
+	__smp_mb();							\
+	___p1;								\
+})
+#endif
+
+#ifdef CONFIG_SMP
+
+#ifndef smp_store_mb
+#define smp_store_mb(var, value)  __smp_store_mb(var, value)
+#endif
+
+#ifndef smp_mb__before_atomic
+#define smp_mb__before_atomic()	__smp_mb__before_atomic()
+#endif
+
+#ifndef smp_mb__after_atomic
+#define smp_mb__after_atomic()	__smp_mb__after_atomic()
+#endif
+
+#ifndef smp_store_release
+#define smp_store_release(p, v) __smp_store_release(p, v)
+#endif
+
+#ifndef smp_load_acquire
+#define smp_load_acquire(p) __smp_load_acquire(p)
+#endif
+
+#else	/* !CONFIG_SMP */
+
 #ifndef smp_store_mb
-#define smp_store_mb(var, value)  do { WRITE_ONCE(var, value); smp_mb(); } while (0)
+#define smp_store_mb(var, value)  do { WRITE_ONCE(var, value); barrier(); } while (0)
 #endif
 
 #ifndef smp_mb__before_atomic
-#define smp_mb__before_atomic()	smp_mb()
+#define smp_mb__before_atomic()	barrier()
 #endif
 
 #ifndef smp_mb__after_atomic
-#define smp_mb__after_atomic()	smp_mb()
+#define smp_mb__after_atomic()	barrier()
 #endif
 
 #ifndef smp_store_release
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
-	smp_mb();							\
+	barrier();							\
 	WRITE_ONCE(*p, v);						\
 } while (0)
 #endif
@@ -118,10 +189,12 @@ do {									\
 ({									\
 	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
-	smp_mb();							\
+	barrier();							\
 	___p1;								\
 })
 #endif
 
+#endif
+
 #endif /* !__ASSEMBLY__ */
 #endif /* __ASM_GENERIC_BARRIER_H */
-- 
MST

