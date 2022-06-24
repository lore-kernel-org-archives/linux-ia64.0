From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Fri, 24 Jun 2022 04:55:30 +0000
Subject: [PATCH V4 17/26] csky/mm: Enable ARCH_HAS_VM_GET_PAGE_PROT
Message-Id: <20220624044339.1533882-18-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624044339.1533882-1-anshuman.khandual@arm.com>
In-Reply-To: <20220624044339.1533882-1-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: hch@infradead.org, christophe.leroy@csgroup.eu, Anshuman Khandual <anshuman.khandual@arm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, openrisc@lists.librecores.org, linux-xtensa@linux-xtensa.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-um@lists.infradead.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

This enables ARCH_HAS_VM_GET_PAGE_PROT on the platform and exports standard
vm_get_page_prot() implementation via DECLARE_VM_GET_PAGE_PROT, which looks
up a private and static protection_map[] array. Subsequently all __SXXX and
__PXXX macros can be dropped which are no longer needed.

Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-csky@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/csky/Kconfig               |  1 +
 arch/csky/include/asm/pgtable.h | 18 ------------------
 arch/csky/mm/init.c             | 20 ++++++++++++++++++++
 3 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/arch/csky/Kconfig b/arch/csky/Kconfig
index 21d72b078eef..588b8a9c68ed 100644
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
index bbe245117777..229a5f4ad7fc 100644
--- a/arch/csky/include/asm/pgtable.h
+++ b/arch/csky/include/asm/pgtable.h
@@ -77,24 +77,6 @@
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
index bf2004aa811a..1bf7b2a748fd 100644
--- a/arch/csky/mm/init.c
+++ b/arch/csky/mm/init.c
@@ -197,3 +197,23 @@ void __init fixaddr_init(void)
 	vaddr = __fix_to_virt(__end_of_fixed_addresses - 1) & PMD_MASK;
 	fixrange_init(vaddr, vaddr + PMD_SIZE, swapper_pg_dir);
 }
+
+static pgprot_t protection_map[16] __ro_after_init = {
+	[VM_NONE]					= PAGE_NONE,
+	[VM_READ]					= PAGE_READ,
+	[VM_WRITE]					= PAGE_READ,
+	[VM_WRITE | VM_READ]				= PAGE_READ,
+	[VM_EXEC]					= PAGE_READ,
+	[VM_EXEC | VM_READ]				= PAGE_READ,
+	[VM_EXEC | VM_WRITE]				= PAGE_READ,
+	[VM_EXEC | VM_WRITE | VM_READ]			= PAGE_READ,
+	[VM_SHARED]					= PAGE_NONE,
+	[VM_SHARED | VM_READ]				= PAGE_READ,
+	[VM_SHARED | VM_WRITE]				= PAGE_WRITE,
+	[VM_SHARED | VM_WRITE | VM_READ]		= PAGE_WRITE,
+	[VM_SHARED | VM_EXEC]				= PAGE_READ,
+	[VM_SHARED | VM_EXEC | VM_READ]			= PAGE_READ,
+	[VM_SHARED | VM_EXEC | VM_WRITE]		= PAGE_WRITE,
+	[VM_SHARED | VM_EXEC | VM_WRITE | VM_READ]	= PAGE_WRITE
+};
+DECLARE_VM_GET_PAGE_PROT
-- 
2.25.1
