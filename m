From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Date: Sun, 05 Jun 2022 16:07:38 +0000
Subject: [PATCH] ia64: fix sparse warnings with cmpxchg() & xchg()
Message-Id: <20220605160738.79736-1-luc.vanoostenryck@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87h7547k8c.fsf@toke.dk>
In-Reply-To: <87h7547k8c.fsf@toke.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, kernel test robot <lkp@intel.com>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@redhat.com>

On IA64, new sparse's warnings where issued after fixing
some __rcu annotations in kernel/bpf/.

These new warnings are false positives and appear on IA64 because
on this architecture, the macros for cmpxchg() and xchg() make
casts that ignore sparse annotations.

This patch contains the minimal patch to fix this issue:
adding a missing cast and some missing '__force'.

Link: https://lore.kernel.org/r/20220601120013.bq5a3ynbkc3hngm5@mail
Reported-by: kernel test robot <lkp@intel.com>
Cc: Toke Høiland-Jørgensen <toke@redhat.com>
Signed-off-by: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
---

Note: This patch is only compile tested on defconfig. The corresponding
      binary is unchanged (except some .rodata with the kernel version)
      as it should be.

 arch/ia64/include/uapi/asm/cmpxchg.h | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/include/uapi/asm/cmpxchg.h b/arch/ia64/include/uapi/asm/cmpxchg.h
index 2c2f3cfeaa77..ca2e02685343 100644
--- a/arch/ia64/include/uapi/asm/cmpxchg.h
+++ b/arch/ia64/include/uapi/asm/cmpxchg.h
@@ -33,24 +33,24 @@ extern void ia64_xchg_called_with_bad_pointer(void);
 									\
 	switch (size) {							\
 	case 1:								\
-		__xchg_result = ia64_xchg1((__u8 *)ptr, x);		\
+		__xchg_result = ia64_xchg1((__u8 __force *)ptr, x);	\
 		break;							\
 									\
 	case 2:								\
-		__xchg_result = ia64_xchg2((__u16 *)ptr, x);		\
+		__xchg_result = ia64_xchg2((__u16 __force *)ptr, x);	\
 		break;							\
 									\
 	case 4:								\
-		__xchg_result = ia64_xchg4((__u32 *)ptr, x);		\
+		__xchg_result = ia64_xchg4((__u32 __force *)ptr, x);	\
 		break;							\
 									\
 	case 8:								\
-		__xchg_result = ia64_xchg8((__u64 *)ptr, x);		\
+		__xchg_result = ia64_xchg8((__u64 __force *)ptr, x);	\
 		break;							\
 	default:							\
 		ia64_xchg_called_with_bad_pointer();			\
 	}								\
-	__xchg_result;							\
+	(__typeof__ (*(ptr)) __force) __xchg_result;			\
 })
 
 #ifndef __KERNEL__
@@ -76,42 +76,42 @@ extern long ia64_cmpxchg_called_with_bad_pointer(void);
 									\
 	switch (size) {							\
 	case 1:								\
-		_o_ = (__u8) (long) (old);				\
+		_o_ = (__u8) (long __force) (old);			\
 		break;							\
 	case 2:								\
-		_o_ = (__u16) (long) (old);				\
+		_o_ = (__u16) (long __force) (old);			\
 		break;							\
 	case 4:								\
-		_o_ = (__u32) (long) (old);				\
+		_o_ = (__u32) (long __force) (old);			\
 		break;							\
 	case 8:								\
-		_o_ = (__u64) (long) (old);				\
+		_o_ = (__u64) (long __force) (old);			\
 		break;							\
 	default:							\
 		break;							\
 	}								\
 	switch (size) {							\
 	case 1:								\
-		_r_ = ia64_cmpxchg1_##sem((__u8 *) ptr, new, _o_);	\
+		_r_ = ia64_cmpxchg1_##sem((__u8 __force *) ptr, new, _o_);	\
 		break;							\
 									\
 	case 2:								\
-		_r_ = ia64_cmpxchg2_##sem((__u16 *) ptr, new, _o_);	\
+		_r_ = ia64_cmpxchg2_##sem((__u16 __force *) ptr, new, _o_);	\
 		break;							\
 									\
 	case 4:								\
-		_r_ = ia64_cmpxchg4_##sem((__u32 *) ptr, new, _o_);	\
+		_r_ = ia64_cmpxchg4_##sem((__u32 __force *) ptr, new, _o_);	\
 		break;							\
 									\
 	case 8:								\
-		_r_ = ia64_cmpxchg8_##sem((__u64 *) ptr, new, _o_);	\
+		_r_ = ia64_cmpxchg8_##sem((__u64 __force *) ptr, new, _o_);	\
 		break;							\
 									\
 	default:							\
 		_r_ = ia64_cmpxchg_called_with_bad_pointer();		\
 		break;							\
 	}								\
-	(__typeof__(old)) _r_;						\
+	(__typeof__(old) __force) _r_;					\
 })
 
 #define cmpxchg_acq(ptr, o, n)	\
-- 
2.36.1
