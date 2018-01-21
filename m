From: Matthew Wilcox <willy@infradead.org>
Date: Sun, 21 Jan 2018 03:21:29 +0000
Subject: Re: [PATCH] ia64: Rewrite atomic_add and atomic_sub
Message-Id: <20180121032129.GA27293@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180118183953.29257-1-willy@infradead.org>
In-Reply-To: <20180118183953.29257-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 18, 2018 at 11:02:43AM -0800, Luck, Tony wrote:
> On Thu, Jan 18, 2018 at 10:39:53AM -0800, Matthew Wilcox wrote:
> > +	int __i = (i);							\
> > +	static const int __ia64_atomic_p = __ia64_atomic_const(i);	\
> > +	__ia64_atomic_p ? ia64_fetch_and_add(__i, &(v)->counter) :	\
> > +				ia64_atomic_add(__i, v);		\

I felt bad about only covering atomic_add_return and atomic_sub_return and leaving all the other sites exposed to this latent bug.  So here's a patch
which fixes all of them.  As a bonus it's also a nice clean-up.

From: Matthew Wilcox <mawilcox@microsoft.com>
Date: Fri, 12 Jan 2018 14:14:37 -0500
Subject: [PATCH] ia64: Rewrite atomic_add and atomic_sub

Force __builtin_constant_p to evaluate whether the argument to atomic_add
& atomic_sub is constant in the front-end before optimisations which
can lead GCC to output a call to __bad_increment_for_ia64_fetch_and_add().

See GCC bugzilla 83653.

Signed-off-by: Jakub Jelinek <jakub@redhat.com>
Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 arch/ia64/include/asm/atomic.h | 58 +++++++++++++-----------------------------
 1 file changed, 18 insertions(+), 40 deletions(-)

diff --git a/arch/ia64/include/asm/atomic.h b/arch/ia64/include/asm/atomic.h
index 28e02c99be6d..2524fb60fbc2 100644
--- a/arch/ia64/include/asm/atomic.h
+++ b/arch/ia64/include/asm/atomic.h
@@ -65,14 +65,20 @@ ia64_atomic_fetch_##op (int i, atomic_t *v)				\
 ATOMIC_OPS(add, +)
 ATOMIC_OPS(sub, -)
 
+#ifdef __OPTIMIZE__
+#define __ia64_atomic_const(i)						\
+	static const int __ia64_atomic_p = __builtin_constant_p(i) ?	\
+		((i) = 1 || (i) = 4 || (i) = 8 || (i) = 16 ||	\
+		 (i) = -1 || (i) = -4 || (i) = -8 || (i) = -16) : 0;\
+	__ia64_atomic_p
+#else
+#define __ia64_atomic_const(i)	0
+#endif
+
 #define atomic_add_return(i,v)						\
 ({									\
 	int __ia64_aar_i = (i);						\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_aar_i =  1) || (__ia64_aar_i =   4)		\
-	     || (__ia64_aar_i =  8) || (__ia64_aar_i =  16)		\
-	     || (__ia64_aar_i = -1) || (__ia64_aar_i =  -4)		\
-	     || (__ia64_aar_i = -8) || (__ia64_aar_i = -16)))		\
+	__ia64_atomic_const(i)						\
 		? ia64_fetch_and_add(__ia64_aar_i, &(v)->counter)	\
 		: ia64_atomic_add(__ia64_aar_i, v);			\
 })
@@ -80,11 +86,7 @@ ATOMIC_OPS(sub, -)
 #define atomic_sub_return(i,v)						\
 ({									\
 	int __ia64_asr_i = (i);						\
-	(__builtin_constant_p(i)					\
-	 && (   (__ia64_asr_i =   1) || (__ia64_asr_i =   4)		\
-	     || (__ia64_asr_i =   8) || (__ia64_asr_i =  16)		\
-	     || (__ia64_asr_i =  -1) || (__ia64_asr_i =  -4)		\
-	     || (__ia64_asr_i =  -8) || (__ia64_asr_i = -16)))	\
+	__ia64_atomic_const(i)						\
 		? ia64_fetch_and_add(-__ia64_asr_i, &(v)->counter)	\
 		: ia64_atomic_sub(__ia64_asr_i, v);			\
 })
@@ -92,11 +94,7 @@ ATOMIC_OPS(sub, -)
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
@@ -104,11 +102,7 @@ ATOMIC_OPS(sub, -)
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
@@ -169,11 +163,7 @@ ATOMIC64_OPS(sub, -)
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
@@ -181,11 +171,7 @@ ATOMIC64_OPS(sub, -)
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
@@ -193,11 +179,7 @@ ATOMIC64_OPS(sub, -)
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
@@ -205,11 +187,7 @@ ATOMIC64_OPS(sub, -)
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
2.15.1

