From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Tue, 14 Feb 2023 07:49:02 +0000
Subject: [PATCH v3 01/24] alpha: Remove COMMAND_LINE_SIZE from uapi
Message-Id: <20230214074925.228106-2-alexghiti@rivosinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230214074925.228106-1-alexghiti@rivosinc.com>
In-Reply-To: <20230214074925.228106-1-alexghiti@rivosinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Palmer Dabbelt <palmer@rivosinc.com>

From: Palmer Dabbelt <palmer@rivosinc.com>

As far as I can tell this is not used by userspace and thus should not
be part of the user-visible API.

Signed-off-by: Palmer Dabbelt <palmer@rivosinc.com>
---
 arch/alpha/include/asm/setup.h      | 4 ++--
 arch/alpha/include/uapi/asm/setup.h | 2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/alpha/include/asm/setup.h b/arch/alpha/include/asm/setup.h
index 262aab99e391..ea08ca45efa8 100644
--- a/arch/alpha/include/asm/setup.h
+++ b/arch/alpha/include/asm/setup.h
@@ -2,8 +2,6 @@
 #ifndef __ALPHA_SETUP_H
 #define __ALPHA_SETUP_H
 
-#include <uapi/asm/setup.h>
-
 /*
  * We leave one page for the initial stack page, and one page for
  * the initial process structure. Also, the console eats 3 MB for
@@ -14,6 +12,8 @@
 /* Remove when official MILO sources have ELF support: */
 #define BOOT_SIZE	(16*1024)
 
+#define COMMAND_LINE_SIZE	256
+
 #ifdef CONFIG_ALPHA_LEGACY_START_ADDRESS
 #define KERNEL_START_PHYS	0x300000 /* Old bootloaders hardcoded this.  */
 #else
diff --git a/arch/alpha/include/uapi/asm/setup.h b/arch/alpha/include/uapi/asm/setup.h
index f881ea5947cb..9b3b5ba39b1d 100644
--- a/arch/alpha/include/uapi/asm/setup.h
+++ b/arch/alpha/include/uapi/asm/setup.h
@@ -2,6 +2,4 @@
 #ifndef _UAPI__ALPHA_SETUP_H
 #define _UAPI__ALPHA_SETUP_H
 
-#define COMMAND_LINE_SIZE	256
-
 #endif /* _UAPI__ALPHA_SETUP_H */
-- 
2.37.2
