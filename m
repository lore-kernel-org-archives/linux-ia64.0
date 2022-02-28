From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 28 Feb 2022 10:59:42 +0000
Subject: [PATCH V3 19/30] csky/mm: Enable ARCH_HAS_VM_GET_PAGE_PROT
Message-Id: <1646045273-9343-20-git-send-email-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1646045273-9343-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1646045273-9343-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, geert@linux-m68k.org, Anshuman Khandual <anshuman.khandual@arm.com>, Christoph Hellwig <hch@infradead.org>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-s390@vger.kernel.org, linux-riscv@lists.infradead.org, linux-alpha@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-parisc@vger.kernel.org, openrisc@lists.librecores.org, linux-um@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org

This defines and exports a platform specific custom vm_get_page_prot() via
subscribing ARCH_HAS_VM_GET_PAGE_PROT. Subsequently all __SXXX and __PXXX
macros can be dropped which are no longer needed.

Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-csky@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/csky/Kconfig               |  1 +
 arch/csky/include/asm/pgtable.h | 18 ------------------
 arch/csky/mm/init.c             | 32 ++++++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+), 18 deletions(-)

diff --git a/arch/csky/Kconfig b/arch/csky/Kconfig
index 132f43f12dd8..209dac5686dd 100644
--- a/arch/csky/Kconfig
+++ b/arch/csky/Kconfig
@@ -6,6 +6,7 @@ config CSKY
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_SYNC_DMA_FOR_CPU
 	select ARCH_HAS_SYNC_DMA_FOR_DEVICE
+	select ARCH_HAS_VM_GET_PAGE_PROT
 	select ARCH_USE_BUILTIN_BSWAP
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_WANT_FRAME_POINTERS if !CPU_CK610 && $(cc-option,-mbacktrace)
diff --git a/arch/csky/include/asm/pgtable.h b/arch/csky/include/asm/pgtable.h
index 151607ed5158..2c6b1cfb1cce 100644
--- a/arch/csky/include/asm/pgtable.h
+++ b/arch/csky/include/asm/pgtable.h
@@ -76,24 +76,6 @@
 #define MAX_SWAPFILES_CHECK() \
 		BUILD_BUG_ON(MAX_SWAPFILES_SHIFT != 5)
 
-#define __P000	PAGE_NONE
-#define __P001	PAGE_READ
-#define __P010	PAGE_READ
-#define __P011	PAGE_READ
-#define __P100	PAGE_READ
-#define __P101	PAGE_READ
-#define __P110	PAGE_READ
-#define __P111	PAGE_READ
-
-#define __S000	PAGE_NONE
-#define __S001	PAGE_READ
-#define __S010	PAGE_WRITE
-#define __S011	PAGE_WRITE
-#define __S100	PAGE_READ
-#define __S101	PAGE_READ
-#define __S110	PAGE_WRITE
-#define __S111	PAGE_WRITE
-
 extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
 #define ZERO_PAGE(vaddr)	(virt_to_page(empty_zero_page))
 
diff --git a/arch/csky/mm/init.c b/arch/csky/mm/init.c
index bf2004aa811a..f9babbed17d4 100644
--- a/arch/csky/mm/init.c
+++ b/arch/csky/mm/init.c
@@ -197,3 +197,35 @@ void __init fixaddr_init(void)
 	vaddr = __fix_to_virt(__end_of_fixed_addresses - 1) & PMD_MASK;
 	fixrange_init(vaddr, vaddr + PMD_SIZE, swapper_pg_dir);
 }
+
+pgprot_t vm_get_page_prot(unsigned long vm_flags)
+{
+	switch (vm_flags & (VM_READ | VM_WRITE | VM_EXEC | VM_SHARED)) {
+	case VM_NONE:
+		return PAGE_NONE;
+	case VM_READ:
+	case VM_WRITE:
+	case VM_WRITE | VM_READ:
+	case VM_EXEC:
+	case VM_EXEC | VM_READ:
+	case VM_EXEC | VM_WRITE:
+	case VM_EXEC | VM_WRITE | VM_READ:
+		return PAGE_READ;
+	case VM_SHARED:
+		return PAGE_NONE;
+	case VM_SHARED | VM_READ:
+		return PAGE_READ;
+	case VM_SHARED | VM_WRITE:
+	case VM_SHARED | VM_WRITE | VM_READ:
+		return PAGE_WRITE;
+	case VM_SHARED | VM_EXEC:
+	case VM_SHARED | VM_EXEC | VM_READ:
+		return PAGE_READ;
+	case VM_SHARED | VM_EXEC | VM_WRITE:
+	case VM_SHARED | VM_EXEC | VM_WRITE | VM_READ:
+		return PAGE_WRITE;
+	default:
+		BUILD_BUG();
+	}
+}
+EXPORT_SYMBOL(vm_get_page_prot);
-- 
2.25.1
