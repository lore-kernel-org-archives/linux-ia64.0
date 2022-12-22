From: Andrzej Hajda <andrzej.hajda@intel.com>
Date: Thu, 22 Dec 2022 11:46:21 +0000
Subject: [PATCH 05/19] arch/hexagon: rename internal name __xchg to __arch_xchg
Message-Id: <20221222114635.1251934-6-andrzej.hajda@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221222114635.1251934-1-andrzej.hajda@intel.com>
In-Reply-To: <20221222114635.1251934-1-andrzej.hajda@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org
Cc: Mark Rutland <mark.rutland@arm.com>, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>, Andrzej Hajda <andrzej.hajda@intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>

__xchg will be used for non-atomic xchg macro.

Signed-off-by: Andrzej Hajda <andrzej.hajda@intel.com>
---
 arch/hexagon/include/asm/cmpxchg.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/hexagon/include/asm/cmpxchg.h b/arch/hexagon/include/asm/cmpxchg.h
index cdb705e1496af8..92dc5e5f836f3b 100644
--- a/arch/hexagon/include/asm/cmpxchg.h
+++ b/arch/hexagon/include/asm/cmpxchg.h
@@ -9,7 +9,7 @@
 #define _ASM_CMPXCHG_H
 
 /*
- * __xchg - atomically exchange a register and a memory location
+ * __arch_xchg - atomically exchange a register and a memory location
  * @x: value to swap
  * @ptr: pointer to memory
  * @size:  size of the value
@@ -19,7 +19,7 @@
  * Note:  there was an errata for V2 about .new's and memw_locked.
  *
  */
-static inline unsigned long __xchg(unsigned long x, volatile void *ptr,
+static inline unsigned long __arch_xchg(unsigned long x, volatile void *ptr,
 				   int size)
 {
 	unsigned long retval;
@@ -42,7 +42,7 @@ static inline unsigned long __xchg(unsigned long x, volatile void *ptr,
  * Atomically swap the contents of a register with memory.  Should be atomic
  * between multiple CPU's and within interrupts on the same CPU.
  */
-#define arch_xchg(ptr, v) ((__typeof__(*(ptr)))__xchg((unsigned long)(v), (ptr), \
+#define arch_xchg(ptr, v) ((__typeof__(*(ptr)))__arch_xchg((unsigned long)(v), (ptr), \
 	sizeof(*(ptr))))
 
 /*
-- 
2.34.1
