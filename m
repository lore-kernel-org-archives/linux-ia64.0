From: Sven Eckelmann <sven@narfation.org>
Date: Tue, 03 May 2011 21:30:35 +0000
Subject: [PATCH] atomic: add *_dec_not_zero
Message-Id: <1304458235-28473-1-git-send-email-sven@narfation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Sven Eckelmann <sven@narfation.org>, David Howells <dhowells@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, uclinux-dist-devel@blackfin.uclinux.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m32r@ml.linux-m32r.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

Introduce an *_dec_not_zero operation.  Make this a special case of
*_add_unless because batman-adv uses atomic_dec_not_zero in different
places like re-broadcast queue or aggregation queue management. There
are other non-final patches which may also want to use this macro.

Reported-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Cc: David Howells <dhowells@redhat.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: x86@kernel.org
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: uclinux-dist-devel@blackfin.uclinux.org
Cc: linux-cris-kernel@axis.com
Cc: linux-ia64@vger.kernel.org
Cc: linux-m32r@ml.linux-m32r.org
Cc: linux-m68k@lists.linux-m68k.org
Cc: linux-mips@linux-mips.org
Cc: linux-am33-list@redhat.com
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-arch@vger.kernel.org
---
David S. Miller recommended this change in
 https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2011-May/004560.html

 arch/alpha/include/asm/atomic.h    |    2 ++
 arch/alpha/include/asm/local.h     |    1 +
 arch/arm/include/asm/atomic.h      |    2 ++
 arch/avr32/include/asm/atomic.h    |    1 +
 arch/blackfin/include/asm/atomic.h |    1 +
 arch/cris/include/asm/atomic.h     |    1 +
 arch/frv/include/asm/atomic.h      |    1 +
 arch/h8300/include/asm/atomic.h    |    1 +
 arch/ia64/include/asm/atomic.h     |    2 ++
 arch/m32r/include/asm/atomic.h     |    1 +
 arch/m32r/include/asm/local.h      |    1 +
 arch/m68k/include/asm/atomic.h     |    1 +
 arch/mips/include/asm/atomic.h     |    2 ++
 arch/mips/include/asm/local.h      |    1 +
 arch/mn10300/include/asm/atomic.h  |    1 +
 arch/parisc/include/asm/atomic.h   |    2 ++
 arch/powerpc/include/asm/atomic.h  |    2 ++
 arch/powerpc/include/asm/local.h   |    1 +
 arch/s390/include/asm/atomic.h     |    2 ++
 arch/sh/include/asm/atomic.h       |    1 +
 arch/sparc/include/asm/atomic_32.h |    1 +
 arch/sparc/include/asm/atomic_64.h |    2 ++
 arch/tile/include/asm/atomic.h     |    9 +++++++++
 arch/tile/include/asm/atomic_32.h  |    1 +
 arch/x86/include/asm/atomic.h      |    1 +
 arch/x86/include/asm/atomic64_64.h |    1 +
 arch/xtensa/include/asm/atomic.h   |    1 +
 include/asm-generic/atomic-long.h  |    2 ++
 include/asm-generic/atomic.h       |    1 +
 include/asm-generic/atomic64.h     |    1 +
 include/asm-generic/local.h        |    1 +
 include/asm-generic/local64.h      |    2 ++
 32 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/arch/alpha/include/asm/atomic.h b/arch/alpha/include/asm/atomic.h
index e756d04..7e9434e 100644
--- a/arch/alpha/include/asm/atomic.h
+++ b/arch/alpha/include/asm/atomic.h
@@ -200,6 +200,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 /**
  * atomic64_add_unless - add unless the number is a given value
@@ -226,6 +227,7 @@ static __inline__ int atomic64_add_unless(atomic64_t *v, long a, long u)
 }
 
 #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
+#define atomic64_dec_not_zero(v) atomic64_add_unless((v), -1, 0)
 
 #define atomic_add_negative(a, v) (atomic_add_return((a), (v)) < 0)
 #define atomic64_add_negative(a, v) (atomic64_add_return((a), (v)) < 0)
diff --git a/arch/alpha/include/asm/local.h b/arch/alpha/include/asm/local.h
index b9e3e33..09fb327 100644
--- a/arch/alpha/include/asm/local.h
+++ b/arch/alpha/include/asm/local.h
@@ -79,6 +79,7 @@ static __inline__ long local_sub_return(long i, local_t * l)
 	c != (u);						\
 })
 #define local_inc_not_zero(l) local_add_unless((l), 1, 0)
+#define local_dec_not_zero(l) local_add_unless((l), -1, 0)
 
 #define local_add_negative(a, l) (local_add_return((a), (l)) < 0)
 
diff --git a/arch/arm/include/asm/atomic.h b/arch/arm/include/asm/atomic.h
index 7e79503..a005265 100644
--- a/arch/arm/include/asm/atomic.h
+++ b/arch/arm/include/asm/atomic.h
@@ -218,6 +218,7 @@ static inline int atomic_add_unless(atomic_t *v, int a, int u)
 	return c != u;
 }
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 #define atomic_inc(v)		atomic_add(1, v)
 #define atomic_dec(v)		atomic_sub(1, v)
@@ -459,6 +460,7 @@ static inline int atomic64_add_unless(atomic64_t *v, u64 a, u64 u)
 #define atomic64_dec_return(v)		atomic64_sub_return(1LL, (v))
 #define atomic64_dec_and_test(v)	(atomic64_dec_return((v)) = 0)
 #define atomic64_inc_not_zero(v)	atomic64_add_unless((v), 1LL, 0LL)
+#define atomic64_dec_not_zero(v)	atomic64_add_unless((v), -1LL, 0LL)
 
 #else /* !CONFIG_GENERIC_ATOMIC64 */
 #include <asm-generic/atomic64.h>
diff --git a/arch/avr32/include/asm/atomic.h b/arch/avr32/include/asm/atomic.h
index bbce6a1..e6f39c1 100644
--- a/arch/avr32/include/asm/atomic.h
+++ b/arch/avr32/include/asm/atomic.h
@@ -189,6 +189,7 @@ static inline int atomic_sub_if_positive(int i, atomic_t *v)
 #define atomic_add_negative(i, v) (atomic_add_return(i, v) < 0)
 
 #define atomic_inc_not_zero(v)	atomic_add_unless(v, 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 #define atomic_dec_if_positive(v) atomic_sub_if_positive(1, v)
 
 #define smp_mb__before_atomic_dec()	barrier()
diff --git a/arch/blackfin/include/asm/atomic.h b/arch/blackfin/include/asm/atomic.h
index e485089..900682e 100644
--- a/arch/blackfin/include/asm/atomic.h
+++ b/arch/blackfin/include/asm/atomic.h
@@ -103,6 +103,7 @@ static inline int atomic_test_mask(int mask, atomic_t *v)
 	c != (u);						\
 })
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 /*
  * atomic_inc_and_test - increment and test
diff --git a/arch/cris/include/asm/atomic.h b/arch/cris/include/asm/atomic.h
index 88dc9b9..9db2767 100644
--- a/arch/cris/include/asm/atomic.h
+++ b/arch/cris/include/asm/atomic.h
@@ -151,6 +151,7 @@ static inline int atomic_add_unless(atomic_t *v, int a, int u)
 	return ret != u;
 }
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 /* Atomic operations are already serializing */
 #define smp_mb__before_atomic_dec()    barrier()
diff --git a/arch/frv/include/asm/atomic.h b/arch/frv/include/asm/atomic.h
index fae32c7..90f12a8 100644
--- a/arch/frv/include/asm/atomic.h
+++ b/arch/frv/include/asm/atomic.h
@@ -257,6 +257,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 #include <asm-generic/atomic-long.h>
 #endif /* _ASM_ATOMIC_H */
diff --git a/arch/h8300/include/asm/atomic.h b/arch/h8300/include/asm/atomic.h
index 984221a..eda4c8a 100644
--- a/arch/h8300/include/asm/atomic.h
+++ b/arch/h8300/include/asm/atomic.h
@@ -117,6 +117,7 @@ static inline int atomic_add_unless(atomic_t *v, int a, int u)
 	return ret != u;
 }
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 static __inline__ void atomic_clear_mask(unsigned long mask, unsigned long *v)
 {
diff --git a/arch/ia64/include/asm/atomic.h b/arch/ia64/include/asm/atomic.h
index 4468814..e2777a9 100644
--- a/arch/ia64/include/asm/atomic.h
+++ b/arch/ia64/include/asm/atomic.h
@@ -106,6 +106,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 static __inline__ long atomic64_add_unless(atomic64_t *v, long a, long u)
 {
@@ -123,6 +124,7 @@ static __inline__ long atomic64_add_unless(atomic64_t *v, long a, long u)
 }
 
 #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
+#define atomic64_dec_not_zero(v) atomic64_add_unless((v), -1, 0)
 
 #define atomic_add_return(i,v)						\
 ({									\
diff --git a/arch/m32r/include/asm/atomic.h b/arch/m32r/include/asm/atomic.h
index d44a51e..4e0b4ec 100644
--- a/arch/m32r/include/asm/atomic.h
+++ b/arch/m32r/include/asm/atomic.h
@@ -263,6 +263,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 static __inline__ void atomic_clear_mask(unsigned long  mask, atomic_t *addr)
 {
diff --git a/arch/m32r/include/asm/local.h b/arch/m32r/include/asm/local.h
index 734bca8..d536082 100644
--- a/arch/m32r/include/asm/local.h
+++ b/arch/m32r/include/asm/local.h
@@ -272,6 +272,7 @@ static inline int local_add_unless(local_t *l, long a, long u)
 }
 
 #define local_inc_not_zero(l) local_add_unless((l), 1, 0)
+#define local_dec_not_zero(l) local_add_unless((l), -1, 0)
 
 static inline void local_clear_mask(unsigned long  mask, local_t *addr)
 {
diff --git a/arch/m68k/include/asm/atomic.h b/arch/m68k/include/asm/atomic.h
index 03ae3d1..187a33f 100644
--- a/arch/m68k/include/asm/atomic.h
+++ b/arch/m68k/include/asm/atomic.h
@@ -199,6 +199,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 /* Atomic operations are already serializing */
 #define smp_mb__before_atomic_dec()	barrier()
diff --git a/arch/mips/include/asm/atomic.h b/arch/mips/include/asm/atomic.h
index 4a02fe8..8c4109e 100644
--- a/arch/mips/include/asm/atomic.h
+++ b/arch/mips/include/asm/atomic.h
@@ -326,6 +326,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 	return c != (u);
 }
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 #define atomic_dec_return(v) atomic_sub_return(1, (v))
 #define atomic_inc_return(v) atomic_add_return(1, (v))
@@ -698,6 +699,7 @@ static __inline__ int atomic64_add_unless(atomic64_t *v, long a, long u)
 }
 
 #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
+#define atomic64_dec_not_zero(v) atomic64_add_unless((v), -1, 0)
 
 #define atomic64_dec_return(v) atomic64_sub_return(1, (v))
 #define atomic64_inc_return(v) atomic64_add_return(1, (v))
diff --git a/arch/mips/include/asm/local.h b/arch/mips/include/asm/local.h
index fffc830..c34d3ca 100644
--- a/arch/mips/include/asm/local.h
+++ b/arch/mips/include/asm/local.h
@@ -137,6 +137,7 @@ static __inline__ long local_sub_return(long i, local_t * l)
 	c != (u);						\
 })
 #define local_inc_not_zero(l) local_add_unless((l), 1, 0)
+#define local_dec_not_zero(l) local_add_unless((l), -1, 0)
 
 #define local_dec_return(l) local_sub_return(1, (l))
 #define local_inc_return(l) local_add_return(1, (l))
diff --git a/arch/mn10300/include/asm/atomic.h b/arch/mn10300/include/asm/atomic.h
index 9d773a6..bcad5d1 100644
--- a/arch/mn10300/include/asm/atomic.h
+++ b/arch/mn10300/include/asm/atomic.h
@@ -270,6 +270,7 @@ static inline void atomic_dec(atomic_t *v)
 })
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 /**
  * atomic_clear_mask - Atomically clear bits in memory
diff --git a/arch/parisc/include/asm/atomic.h b/arch/parisc/include/asm/atomic.h
index f819559..c2353cf 100644
--- a/arch/parisc/include/asm/atomic.h
+++ b/arch/parisc/include/asm/atomic.h
@@ -221,6 +221,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 #define atomic_add(i,v)	((void)(__atomic_add_return( (i),(v))))
 #define atomic_sub(i,v)	((void)(__atomic_add_return(-(i),(v))))
@@ -335,6 +336,7 @@ static __inline__ int atomic64_add_unless(atomic64_t *v, long a, long u)
 }
 
 #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
+#define atomic64_dec_not_zero(v) atomic64_add_unless((v), -1, 0)
 
 #else /* CONFIG_64BIT */
 
diff --git a/arch/powerpc/include/asm/atomic.h b/arch/powerpc/include/asm/atomic.h
index b8f152e..906f49a 100644
--- a/arch/powerpc/include/asm/atomic.h
+++ b/arch/powerpc/include/asm/atomic.h
@@ -213,6 +213,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 #define atomic_sub_and_test(a, v)	(atomic_sub_return((a), (v)) = 0)
 #define atomic_dec_and_test(v)		(atomic_dec_return((v)) = 0)
@@ -469,6 +470,7 @@ static __inline__ int atomic64_add_unless(atomic64_t *v, long a, long u)
 }
 
 #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
+#define atomic64_dec_not_zero(v) atomic64_add_unless((v), -1, 0)
 
 #else  /* __powerpc64__ */
 #include <asm-generic/atomic64.h>
diff --git a/arch/powerpc/include/asm/local.h b/arch/powerpc/include/asm/local.h
index c2410af..3d4c58a 100644
--- a/arch/powerpc/include/asm/local.h
+++ b/arch/powerpc/include/asm/local.h
@@ -134,6 +134,7 @@ static __inline__ int local_add_unless(local_t *l, long a, long u)
 }
 
 #define local_inc_not_zero(l) local_add_unless((l), 1, 0)
+#define local_dec_not_zero(l) local_add_unless((l), -1, 0)
 
 #define local_sub_and_test(a, l)	(local_sub_return((a), (l)) = 0)
 #define local_dec_and_test(l)		(local_dec_return((l)) = 0)
diff --git a/arch/s390/include/asm/atomic.h b/arch/s390/include/asm/atomic.h
index d9db138..09972c3 100644
--- a/arch/s390/include/asm/atomic.h
+++ b/arch/s390/include/asm/atomic.h
@@ -109,6 +109,7 @@ static inline int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 #undef __CS_LOOP
 
@@ -326,6 +327,7 @@ static inline long long atomic64_dec_if_positive(atomic64_t *v)
 #define atomic64_dec_return(_v)		atomic64_sub_return(1, _v)
 #define atomic64_dec_and_test(_v)	(atomic64_sub_return(1, _v) = 0)
 #define atomic64_inc_not_zero(v)	atomic64_add_unless((v), 1, 0)
+#define atomic64_dec_not_zero(v)	atomic64_add_unless((v), -1, 0)
 
 #define smp_mb__before_atomic_dec()	smp_mb()
 #define smp_mb__after_atomic_dec()	smp_mb()
diff --git a/arch/sh/include/asm/atomic.h b/arch/sh/include/asm/atomic.h
index c798312..848849e 100644
--- a/arch/sh/include/asm/atomic.h
+++ b/arch/sh/include/asm/atomic.h
@@ -31,6 +31,7 @@
 #define atomic_sub_and_test(i,v)	(atomic_sub_return((i), (v)) = 0)
 #define atomic_dec_and_test(v)		(atomic_sub_return(1, (v)) = 0)
 #define atomic_inc_not_zero(v)		atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v)		atomic_add_unless((v), -1, 0)
 
 #define atomic_inc(v)			atomic_add(1, (v))
 #define atomic_dec(v)			atomic_sub(1, (v))
diff --git a/arch/sparc/include/asm/atomic_32.h b/arch/sparc/include/asm/atomic_32.h
index 7ae128b..c7da1e5 100644
--- a/arch/sparc/include/asm/atomic_32.h
+++ b/arch/sparc/include/asm/atomic_32.h
@@ -53,6 +53,7 @@ extern void atomic_set(atomic_t *, int);
 #define atomic_sub_and_test(i, v) (atomic_sub_return(i, v) = 0)
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 /* This is the old 24-bit implementation.  It's still used internally
  * by some sparc-specific code, notably the semaphore implementation.
diff --git a/arch/sparc/include/asm/atomic_64.h b/arch/sparc/include/asm/atomic_64.h
index bdb2ff8..23ad7cf 100644
--- a/arch/sparc/include/asm/atomic_64.h
+++ b/arch/sparc/include/asm/atomic_64.h
@@ -86,6 +86,7 @@ static inline int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 #define atomic64_cmpxchg(v, o, n) \
 	((__typeof__((v)->counter))cmpxchg(&((v)->counter), (o), (n)))
@@ -107,6 +108,7 @@ static inline long atomic64_add_unless(atomic64_t *v, long a, long u)
 }
 
 #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
+#define atomic64_dec_not_zero(v) atomic64_add_unless((v), -1, 0)
 
 /* Atomic operations are already serializing */
 #define smp_mb__before_atomic_dec()	barrier()
diff --git a/arch/tile/include/asm/atomic.h b/arch/tile/include/asm/atomic.h
index 75a1602..7fd7be2 100644
--- a/arch/tile/include/asm/atomic.h
+++ b/arch/tile/include/asm/atomic.h
@@ -130,6 +130,15 @@ static inline int atomic_read(const atomic_t *v)
  */
 #define atomic_inc_not_zero(v)		atomic_add_unless((v), 1, 0)
 
+/**
+ * atomic_dec_not_zero - decrement unless the number is zero
+ * @v: pointer of type atomic_t
+ *
+ * Atomically decrement @v by 1, so long as @v is non-zero.
+ * Returns non-zero if @v was non-zero, and zero otherwise.
+ */
+#define atomic_dec_not_zero(v)		atomic_add_unless((v), -1, 0)
+
 
 /*
  * We define xchg() and cmpxchg() in the included headers.
diff --git a/arch/tile/include/asm/atomic_32.h b/arch/tile/include/asm/atomic_32.h
index ed359aee..43137bd 100644
--- a/arch/tile/include/asm/atomic_32.h
+++ b/arch/tile/include/asm/atomic_32.h
@@ -243,6 +243,7 @@ static inline void atomic64_set(atomic64_t *v, u64 n)
 #define atomic64_dec_return(v)		atomic64_sub_return(1LL, (v))
 #define atomic64_dec_and_test(v)	(atomic64_dec_return((v)) = 0)
 #define atomic64_inc_not_zero(v)	atomic64_add_unless((v), 1LL, 0LL)
+#define atomic64_dec_not_zero(v)	atomic64_add_unless((v), -1LL, 0LL)
 
 /*
  * We need to barrier before modifying the word, since the _atomic_xxx()
diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
index 952a826..7102a0b 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -245,6 +245,7 @@ static inline int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 /*
  * atomic_dec_if_positive - decrement by 1 if old value positive
diff --git a/arch/x86/include/asm/atomic64_64.h b/arch/x86/include/asm/atomic64_64.h
index 49fd1ea..2cb37f4 100644
--- a/arch/x86/include/asm/atomic64_64.h
+++ b/arch/x86/include/asm/atomic64_64.h
@@ -220,6 +220,7 @@ static inline int atomic64_add_unless(atomic64_t *v, long a, long u)
 }
 
 #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
+#define atomic64_dec_not_zero(v) atomic64_add_unless((v), -1, 0)
 
 /*
  * atomic64_dec_if_positive - decrement by 1 if old value positive
diff --git a/arch/xtensa/include/asm/atomic.h b/arch/xtensa/include/asm/atomic.h
index a96a061..3b2a7b3 100644
--- a/arch/xtensa/include/asm/atomic.h
+++ b/arch/xtensa/include/asm/atomic.h
@@ -249,6 +249,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 static inline void atomic_clear_mask(unsigned int mask, atomic_t *v)
 {
diff --git a/include/asm-generic/atomic-long.h b/include/asm-generic/atomic-long.h
index b7babf0..0fe75ab 100644
--- a/include/asm-generic/atomic-long.h
+++ b/include/asm-generic/atomic-long.h
@@ -130,6 +130,7 @@ static inline long atomic_long_add_unless(atomic_long_t *l, long a, long u)
 }
 
 #define atomic_long_inc_not_zero(l) atomic64_inc_not_zero((atomic64_t *)(l))
+#define atomic_long_dec_not_zero(l) atomic64_dec_not_zero((atomic64_t *)(l))
 
 #define atomic_long_cmpxchg(l, old, new) \
 	(atomic64_cmpxchg((atomic64_t *)(l), (old), (new)))
@@ -247,6 +248,7 @@ static inline long atomic_long_add_unless(atomic_long_t *l, long a, long u)
 }
 
 #define atomic_long_inc_not_zero(l) atomic_inc_not_zero((atomic_t *)(l))
+#define atomic_long_dec_not_zero(l) atomic_dec_not_zero((atomic_t *)(l))
 
 #define atomic_long_cmpxchg(l, old, new) \
 	(atomic_cmpxchg((atomic_t *)(l), (old), (new)))
diff --git a/include/asm-generic/atomic.h b/include/asm-generic/atomic.h
index e994197..4e1d3ef 100644
--- a/include/asm-generic/atomic.h
+++ b/include/asm-generic/atomic.h
@@ -139,6 +139,7 @@ static inline int atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
+#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
 
 static inline void atomic_clear_mask(unsigned long mask, unsigned long *addr)
 {
diff --git a/include/asm-generic/atomic64.h b/include/asm-generic/atomic64.h
index b18ce4f..f301c46 100644
--- a/include/asm-generic/atomic64.h
+++ b/include/asm-generic/atomic64.h
@@ -38,5 +38,6 @@ extern int	 atomic64_add_unless(atomic64_t *v, long long a, long long u);
 #define atomic64_dec_return(v)		atomic64_sub_return(1LL, (v))
 #define atomic64_dec_and_test(v)	(atomic64_dec_return((v)) = 0)
 #define atomic64_inc_not_zero(v) 	atomic64_add_unless((v), 1LL, 0LL)
+#define atomic64_dec_not_zero(v)	atomic64_add_unless((v), -1LL, 0LL)
 
 #endif  /*  _ASM_GENERIC_ATOMIC64_H  */
diff --git a/include/asm-generic/local.h b/include/asm-generic/local.h
index c8a5d68..82ef01f 100644
--- a/include/asm-generic/local.h
+++ b/include/asm-generic/local.h
@@ -44,6 +44,7 @@ typedef struct
 #define local_xchg(l, n) atomic_long_xchg((&(l)->a), (n))
 #define local_add_unless(l, _a, u) atomic_long_add_unless((&(l)->a), (_a), (u))
 #define local_inc_not_zero(l) atomic_long_inc_not_zero(&(l)->a)
+#define local_dec_not_zero(l) atomic_long_dec_not_zero(&(l)->a)
 
 /* Non-atomic variants, ie. preemption disabled and won't be touched
  * in interrupt, etc.  Some archs can optimize this case well. */
diff --git a/include/asm-generic/local64.h b/include/asm-generic/local64.h
index 02ac760..aa3a841 100644
--- a/include/asm-generic/local64.h
+++ b/include/asm-generic/local64.h
@@ -45,6 +45,7 @@ typedef struct {
 #define local64_xchg(l, n)	local_xchg((&(l)->a), (n))
 #define local64_add_unless(l, _a, u) local_add_unless((&(l)->a), (_a), (u))
 #define local64_inc_not_zero(l)	local_inc_not_zero(&(l)->a)
+#define local64_dec_not_zero(l)	local_dec_not_zero(&(l)->a)
 
 /* Non-atomic variants, ie. preemption disabled and won't be touched
  * in interrupt, etc.  Some archs can optimize this case well. */
@@ -83,6 +84,7 @@ typedef struct {
 #define local64_xchg(l, n)	atomic64_xchg((&(l)->a), (n))
 #define local64_add_unless(l, _a, u) atomic64_add_unless((&(l)->a), (_a), (u))
 #define local64_inc_not_zero(l)	atomic64_inc_not_zero(&(l)->a)
+#define local64_dec_not_zero(l)	atomic64_dec_not_zero(&(l)->a)
 
 /* Non-atomic variants, ie. preemption disabled and won't be touched
  * in interrupt, etc.  Some archs can optimize this case well. */
-- 
1.7.4.4

