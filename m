From: Matthew Wilcox <willy@infradead.org>
Date: Mon, 19 Feb 2018 17:41:26 +0000
Subject: [PATCH] ia64: Convert remaining atomic operations
Message-Id: <20180219174126.25334-1-willy@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

While we've only seen inlining problems with atomic_sub_return(),
the other atomic operations could have the same problem.  Convert all
remaining operations to use the same solution as atomic_sub_return().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 arch/ia64/include/asm/atomic.h | 69 ++++++++++++++----------------------------
 1 file changed, 23 insertions(+), 46 deletions(-)

diff --git a/arch/ia64/include/asm/atomic.h b/arch/ia64/include/asm/atomic.h
index 762eeb0fcc1d..2524fb60fbc2 100644
--- a/arch/ia64/include/asm/atomic.h
+++ b/arch/ia64/include/asm/atomic.h
@@ -66,38 +66,35 @@ ATOMIC_OPS(add, +)
 ATOMIC_OPS(sub, -)
 
 #ifdef __OPTIMIZE__
-#define __ia64_atomic_const(i)	__builtin_constant_p(i) ?		\
+#define __ia64_atomic_const(i)						\
+	static const int __ia64_atomic_p = __builtin_constant_p(i) ?	\
 		((i) = 1 || (i) = 4 || (i) = 8 || (i) = 16 ||	\
-		 (i) = -1 || (i) = -4 || (i) = -8 || (i) = -16) : 0
+		 (i) = -1 || (i) = -4 || (i) = -8 || (i) = -16) : 0;\
+	__ia64_atomic_p
+#else
+#define __ia64_atomic_const(i)	0
+#endif
 
-#define atomic_add_return(i, v)						\
+#define atomic_add_return(i,v)						\
 ({									\
-	int __i = (i);							\
-	static const int __ia64_atomic_p = __ia64_atomic_const(i);	\
-	__ia64_atomic_p ? ia64_fetch_and_add(__i, &(v)->counter) :	\
-				ia64_atomic_add(__i, v);		\
+	int __ia64_aar_i = (i);						\
+	__ia64_atomic_const(i)						\
+		? ia64_fetch_and_add(__ia64_aar_i, &(v)->counter)	\
+		: ia64_atomic_add(__ia64_aar_i, v);			\
 })
 
-#define atomic_sub_return(i, v)						\
+#define atomic_sub_return(i,v)						\
 ({									\
-	int __i = (i);							\
-	static const int __ia64_atomic_p = __ia64_atomic_const(i);	\
-	__ia64_atomic_p ? ia64_fetch_and_add(-__i, &(v)->counter) :	\
-				ia64_atomic_sub(__i, v);		\
+	int __ia64_asr_i = (i);						\
+	__ia64_atomic_const(i)						\
+		? ia64_fetch_and_add(-__ia64_asr_i, &(v)->counter)	\
+		: ia64_atomic_sub(__ia64_asr_i, v);			\
 })
-#else
-#define atomic_add_return(i, v)	ia64_atomic_add(i, v)
-#define atomic_sub_return(i, v)	ia64_atomic_sub(i, v)
-#endif
 
 #define atomic_fetch_add(i,v)						\
 ({									\
 	int __ia64_aar_i = (i);						\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_aar_i =  1) || (__ia64_aar_i =   4)		\
-	     || (__ia64_aar_i =  8) || (__ia64_aar_i =  16)		\
-	     || (__ia64_aar_i = -1) || (__ia64_aar_i =  -4)		\
-	     || (__ia64_aar_i = -8) || (__ia64_aar_i = -16)))		\
+	__ia64_atomic_const(i)						\
 		? ia64_fetchadd(__ia64_aar_i, &(v)->counter, acq)	\
 		: ia64_atomic_fetch_add(__ia64_aar_i, v);		\
 })
@@ -105,11 +102,7 @@ ATOMIC_OPS(sub, -)
 #define atomic_fetch_sub(i,v)						\
 ({									\
 	int __ia64_asr_i = (i);						\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_asr_i =   1) || (__ia64_asr_i =   4)		\
-	     || (__ia64_asr_i =   8) || (__ia64_asr_i =  16)		\
-	     || (__ia64_asr_i =  -1) || (__ia64_asr_i =  -4)		\
-	     || (__ia64_asr_i =  -8) || (__ia64_asr_i = -16)))	\
+	__ia64_atomic_const(i)						\
 		? ia64_fetchadd(-__ia64_asr_i, &(v)->counter, acq)	\
 		: ia64_atomic_fetch_sub(__ia64_asr_i, v);		\
 })
@@ -170,11 +163,7 @@ ATOMIC64_OPS(sub, -)
 #define atomic64_add_return(i,v)					\
 ({									\
 	long __ia64_aar_i = (i);					\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_aar_i =  1) || (__ia64_aar_i =   4)		\
-	     || (__ia64_aar_i =  8) || (__ia64_aar_i =  16)		\
-	     || (__ia64_aar_i = -1) || (__ia64_aar_i =  -4)		\
-	     || (__ia64_aar_i = -8) || (__ia64_aar_i = -16)))		\
+	__ia64_atomic_const(i)						\
 		? ia64_fetch_and_add(__ia64_aar_i, &(v)->counter)	\
 		: ia64_atomic64_add(__ia64_aar_i, v);			\
 })
@@ -182,11 +171,7 @@ ATOMIC64_OPS(sub, -)
 #define atomic64_sub_return(i,v)					\
 ({									\
 	long __ia64_asr_i = (i);					\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_asr_i =   1) || (__ia64_asr_i =   4)		\
-	     || (__ia64_asr_i =   8) || (__ia64_asr_i =  16)		\
-	     || (__ia64_asr_i =  -1) || (__ia64_asr_i =  -4)		\
-	     || (__ia64_asr_i =  -8) || (__ia64_asr_i = -16)))	\
+	__ia64_atomic_const(i)						\
 		? ia64_fetch_and_add(-__ia64_asr_i, &(v)->counter)	\
 		: ia64_atomic64_sub(__ia64_asr_i, v);			\
 })
@@ -194,11 +179,7 @@ ATOMIC64_OPS(sub, -)
 #define atomic64_fetch_add(i,v)						\
 ({									\
 	long __ia64_aar_i = (i);					\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_aar_i =  1) || (__ia64_aar_i =   4)		\
-	     || (__ia64_aar_i =  8) || (__ia64_aar_i =  16)		\
-	     || (__ia64_aar_i = -1) || (__ia64_aar_i =  -4)		\
-	     || (__ia64_aar_i = -8) || (__ia64_aar_i = -16)))		\
+	__ia64_atomic_const(i)						\
 		? ia64_fetchadd(__ia64_aar_i, &(v)->counter, acq)	\
 		: ia64_atomic64_fetch_add(__ia64_aar_i, v);		\
 })
@@ -206,11 +187,7 @@ ATOMIC64_OPS(sub, -)
 #define atomic64_fetch_sub(i,v)						\
 ({									\
 	long __ia64_asr_i = (i);					\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_asr_i =   1) || (__ia64_asr_i =   4)		\
-	     || (__ia64_asr_i =   8) || (__ia64_asr_i =  16)		\
-	     || (__ia64_asr_i =  -1) || (__ia64_asr_i =  -4)		\
-	     || (__ia64_asr_i =  -8) || (__ia64_asr_i = -16)))	\
+	__ia64_atomic_const(i)						\
 		? ia64_fetchadd(-__ia64_asr_i, &(v)->counter, acq)	\
 		: ia64_atomic64_fetch_sub(__ia64_asr_i, v);		\
 })
-- 
2.16.1

