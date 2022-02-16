From: Arnd Bergmann <arnd@kernel.org>
Date: Wed, 16 Feb 2022 13:13:17 +0000
Subject: [PATCH v2 03/18] nds32: fix access_ok() checks in get/put_user
Message-Id: <20220216131332.1489939-4-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, dinguyen@kernel.org, shorne@gmail.com, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, stable@vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

The get_user()/put_user() functions are meant to check for
access_ok(), while the __get_user()/__put_user() functions
don't.

This broke in 4.19 for nds32, when it gained an extraneous
check in __get_user(), but lost the check it needs in
__put_user().

Fixes: 487913ab18c2 ("nds32: Extract the checking and getting pointer to a macro")
Cc: stable@vger.kernel.org @ v4.19+
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/nds32/include/asm/uaccess.h | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/arch/nds32/include/asm/uaccess.h b/arch/nds32/include/asm/uaccess.h
index d4cbf069dc22..37a40981deb3 100644
--- a/arch/nds32/include/asm/uaccess.h
+++ b/arch/nds32/include/asm/uaccess.h
@@ -70,9 +70,7 @@ static inline void set_fs(mm_segment_t fs)
  * versions are void (ie, don't return a value as such).
  */
 
-#define get_user	__get_user					\
-
-#define __get_user(x, ptr)						\
+#define get_user(x, ptr)						\
 ({									\
 	long __gu_err = 0;						\
 	__get_user_check((x), (ptr), __gu_err);				\
@@ -85,6 +83,14 @@ static inline void set_fs(mm_segment_t fs)
 	(void)0;							\
 })
 
+#define __get_user(x, ptr)						\
+({									\
+	long __gu_err = 0;						\
+	const __typeof__(*(ptr)) __user *__p = (ptr);			\
+	__get_user_err((x), __p, (__gu_err));				\
+	__gu_err;							\
+})
+
 #define __get_user_check(x, ptr, err)					\
 ({									\
 	const __typeof__(*(ptr)) __user *__p = (ptr);			\
@@ -165,12 +171,18 @@ do {									\
 		: "r"(addr), "i"(-EFAULT)				\
 		: "cc")
 
-#define put_user	__put_user					\
+#define put_user(x, ptr)						\
+({									\
+	long __pu_err = 0;						\
+	__put_user_check((x), (ptr), __pu_err);				\
+	__pu_err;							\
+})
 
 #define __put_user(x, ptr)						\
 ({									\
 	long __pu_err = 0;						\
-	__put_user_err((x), (ptr), __pu_err);				\
+	__typeof__(*(ptr)) __user *__p = (ptr);				\
+	__put_user_err((x), __p, __pu_err);				\
 	__pu_err;							\
 })
 
-- 
2.29.2
