From: Matthew Wilcox <willy@infradead.org>
Date: Thu, 18 Jan 2018 18:39:53 +0000
Subject: [PATCH] ia64: Rewrite atomic_add and atomic_sub
Message-Id: <20180118183953.29257-1-willy@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Force __builtin_constant_p to evaluate whether the argument to atomic_add
& atomic_sub is constant in the front-end before optimisations which
can lead GCC to output a call to __bad_increment_for_ia64_fetch_and_add().

See GCC bugzilla 83653.

Signed-off-by: Jakub Jelinek <jakub@redhat.com>
Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 arch/ia64/include/asm/atomic.h | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/include/asm/atomic.h b/arch/ia64/include/asm/atomic.h
index 28e02c99be6d..762eeb0fcc1d 100644
--- a/arch/ia64/include/asm/atomic.h
+++ b/arch/ia64/include/asm/atomic.h
@@ -65,29 +65,30 @@ ia64_atomic_fetch_##op (int i, atomic_t *v)				\
 ATOMIC_OPS(add, +)
 ATOMIC_OPS(sub, -)
 
-#define atomic_add_return(i,v)						\
+#ifdef __OPTIMIZE__
+#define __ia64_atomic_const(i)	__builtin_constant_p(i) ?		\
+		((i) = 1 || (i) = 4 || (i) = 8 || (i) = 16 ||	\
+		 (i) = -1 || (i) = -4 || (i) = -8 || (i) = -16) : 0
+
+#define atomic_add_return(i, v)						\
 ({									\
-	int __ia64_aar_i = (i);						\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_aar_i =  1) || (__ia64_aar_i =   4)		\
-	     || (__ia64_aar_i =  8) || (__ia64_aar_i =  16)		\
-	     || (__ia64_aar_i = -1) || (__ia64_aar_i =  -4)		\
-	     || (__ia64_aar_i = -8) || (__ia64_aar_i = -16)))		\
-		? ia64_fetch_and_add(__ia64_aar_i, &(v)->counter)	\
-		: ia64_atomic_add(__ia64_aar_i, v);			\
+	int __i = (i);							\
+	static const int __ia64_atomic_p = __ia64_atomic_const(i);	\
+	__ia64_atomic_p ? ia64_fetch_and_add(__i, &(v)->counter) :	\
+				ia64_atomic_add(__i, v);		\
 })
 
-#define atomic_sub_return(i,v)						\
+#define atomic_sub_return(i, v)						\
 ({									\
-	int __ia64_asr_i = (i);						\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_asr_i =   1) || (__ia64_asr_i =   4)		\
-	     || (__ia64_asr_i =   8) || (__ia64_asr_i =  16)		\
-	     || (__ia64_asr_i =  -1) || (__ia64_asr_i =  -4)		\
-	     || (__ia64_asr_i =  -8) || (__ia64_asr_i = -16)))	\
-		? ia64_fetch_and_add(-__ia64_asr_i, &(v)->counter)	\
-		: ia64_atomic_sub(__ia64_asr_i, v);			\
+	int __i = (i);							\
+	static const int __ia64_atomic_p = __ia64_atomic_const(i);	\
+	__ia64_atomic_p ? ia64_fetch_and_add(-__i, &(v)->counter) :	\
+				ia64_atomic_sub(__i, v);		\
 })
+#else
+#define atomic_add_return(i, v)	ia64_atomic_add(i, v)
+#define atomic_sub_return(i, v)	ia64_atomic_sub(i, v)
+#endif
 
 #define atomic_fetch_add(i,v)						\
 ({									\
-- 
2.15.1

