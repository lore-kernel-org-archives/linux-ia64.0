From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Jul 2018 12:08:05 +0000
Subject: [PATCH 1/2] ia64: use asm-generic/io.h
Message-Id: <20180711120824.3882108-1-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Boris Brezillon <boris.brezillon@bootlin.com>, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org

asm-generic/io.h provides a generic implementation of all I/O accessors,
which the architectures can override.

Since ia64 does not provide readsl/writesl etc, any driver using those
fails to build, and including asm-generic/io.h will provide the
missing interfaces, as well as any other future interfaces that get
added there. We need to #define a couple of symbols to themselves
in the ia64 to ensure that we use the ia64 specific version of those
rather than the generic one.

There should be no other effect than adding {read,write}s{b,w,l}()
as well as {in,out}s{b,w,l}_p(), which were also not provided
by ia64 but are provided by the generic header for historic reasons.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/include/asm/io.h | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index fb0651961e2c..6f952171abf9 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -83,12 +83,14 @@ virt_to_phys (volatile void *address)
 {
 	return (unsigned long) address - PAGE_OFFSET;
 }
+#define virt_to_phys virt_to_phys
 
 static inline void*
 phys_to_virt (unsigned long address)
 {
 	return (void *) (address + PAGE_OFFSET);
 }
+#define phys_to_virt phys_to_virt
 
 #define ARCH_HAS_VALID_PHYS_ADDR_RANGE
 extern u64 kern_mem_attribute (unsigned long phys_addr, unsigned long size);
@@ -433,9 +435,11 @@ static inline void __iomem * ioremap_cache (unsigned long phys_addr, unsigned lo
 {
 	return ioremap(phys_addr, size);
 }
+#define ioremap ioremap
+#define ioremap_nocache ioremap_nocache
 #define ioremap_cache ioremap_cache
 #define ioremap_uc ioremap_nocache
-
+#define iounmap iounmap
 
 /*
  * String version of IO memory access ops:
@@ -444,6 +448,13 @@ extern void memcpy_fromio(void *dst, const volatile void __iomem *src, long n);
 extern void memcpy_toio(volatile void __iomem *dst, const void *src, long n);
 extern void memset_io(volatile void __iomem *s, int c, long n);
 
+#define memcpy_fromio memcpy_fromio
+#define memcpy_toio memcpy_toio
+#define memset_io memset_io
+#define xlate_dev_kmem_ptr xlate_dev_kmem_ptr
+#define xlate_dev_mem_ptr xlate_dev_mem_ptr
+#include <asm-generic/io.h>
+
 # endif /* __KERNEL__ */
 
 #endif /* _ASM_IA64_IO_H */
-- 
2.9.0

