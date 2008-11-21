From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 21 Nov 2008 03:58:39 +0000
Subject: [PATCH] ia64: remove BUILD_BUG_ON from paravirt_getreg()
Message-Id: <20081121040221.GA5170@x200.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  CC      arch/ia64/kernel/asm-offsets.s
In file included from include/linux/bitops.h:17,
                 from include/linux/kernel.h:15,
                 from include/linux/sched.h:52,
                 from arch/ia64/kernel/asm-offsets.c:9:
arch/ia64/include/asm/bitops.h: In function 'set_bit':
arch/ia64/include/asm/bitops.h:47: error: implicit declaration of function 'BUILD_BUG_ON'


Obvious inclusion of kernel.h doesn't fix it, because of circular dependencies
involving fls.h and log2(). Fixing the latter requires some serious header surgery,
it seems, so just remove BUILD_BUG_ON for now.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 arch/ia64/include/asm/paravirt_privop.h |    1 -
 1 file changed, 1 deletion(-)

--- a/arch/ia64/include/asm/paravirt_privop.h
+++ b/arch/ia64/include/asm/paravirt_privop.h
@@ -83,7 +83,6 @@ extern unsigned long ia64_native_getreg_func(int regnum);
 #define paravirt_getreg(reg)					\
 	({							\
 		unsigned long res;				\
-		BUILD_BUG_ON(!__builtin_constant_p(reg));	\
 		if ((reg) = _IA64_REG_IP)			\
 			res = ia64_native_getreg(_IA64_REG_IP); \
 		else						\
