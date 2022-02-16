From: Arnd Bergmann <arnd@kernel.org>
Date: Wed, 16 Feb 2022 13:13:24 +0000
Subject: [PATCH v2 10/18] m68k: fix access_ok for coldfire
Message-Id: <20220216131332.1489939-11-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, dinguyen@kernel.org, shorne@gmail.com, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org

From: Arnd Bergmann <arnd@arndb.de>

While most m68k platforms use separate address spaces for user
and kernel space, at least coldfire does not, and the other
ones have a TASK_SIZE that is less than the entire 4GB address
range.

Using the default implementation of __access_ok() stops coldfire
user space from trivially accessing kernel memory.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/m68k/include/asm/uaccess.h | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/m68k/include/asm/uaccess.h b/arch/m68k/include/asm/uaccess.h
index 79617c0b2f91..8eb625e75452 100644
--- a/arch/m68k/include/asm/uaccess.h
+++ b/arch/m68k/include/asm/uaccess.h
@@ -12,14 +12,21 @@
 #include <asm/extable.h>
 
 /* We let the MMU do all checking */
-static inline int access_ok(const void __user *addr,
+static inline int access_ok(const void __user *ptr,
 			    unsigned long size)
 {
+	unsigned long limit = TASK_SIZE;
+	unsigned long addr = (unsigned long)ptr;
+
 	/*
 	 * XXX: for !CONFIG_CPU_HAS_ADDRESS_SPACES this really needs to check
 	 * for TASK_SIZE!
+	 * Removing this helper is probably sufficient.
 	 */
-	return 1;
+	if (IS_ENABLED(CONFIG_CPU_HAS_ADDRESS_SPACES))
+		return 1;
+
+	return (size <= limit) && (addr <= (limit - size));
 }
 
 /*
-- 
2.29.2
