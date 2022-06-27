From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 27 Jun 2022 05:10:23 +0000
Subject: [PATCH V5 16/26] riscv/mm: Enable ARCH_HAS_VM_GET_PAGE_PROT
Message-Id: <20220627045833.1590055-17-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220627045833.1590055-1-anshuman.khandual@arm.com>
In-Reply-To: <20220627045833.1590055-1-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: hch@infradead.org, christophe.leroy@csgroup.eu, Anshuman Khandual <anshuman.khandual@arm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, openrisc@lists.librecores.org, linux-xtensa@linux-xtensa.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-um@lists.infradead.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>

This enables ARCH_HAS_VM_GET_PAGE_PROT on the platform and exports standard
vm_get_page_prot() implementation via DECLARE_VM_GET_PAGE_PROT, which looks
up a private and static protection_map[] array. Subsequently all __SXXX and
__PXXX macros can be dropped which are no longer needed.

Cc: Paul Walmsley <paul.walmsley@sifive.com>
Cc: Palmer Dabbelt <palmer@dabbelt.com>
Cc: linux-riscv@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/riscv/Kconfig               |  1 +
 arch/riscv/include/asm/pgtable.h | 20 --------------------
 arch/riscv/mm/init.c             | 20 ++++++++++++++++++++
 3 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index 32ffef9f6e5b..583389d4e43a 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -32,6 +32,7 @@ config RISCV
 	select ARCH_HAS_STRICT_MODULE_RWX if MMU && !XIP_KERNEL
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
+	select ARCH_HAS_VM_GET_PAGE_PROT
 	select ARCH_OPTIONAL_KERNEL_RWX if ARCH_HAS_STRICT_KERNEL_RWX
 	select ARCH_OPTIONAL_KERNEL_RWX_DEFAULT
 	select ARCH_STACKWALK
diff --git a/arch/riscv/include/asm/pgtable.h b/arch/riscv/include/asm/pgtable.h
index 1d1be9d9419c..23e643db6575 100644
--- a/arch/riscv/include/asm/pgtable.h
+++ b/arch/riscv/include/asm/pgtable.h
@@ -186,26 +186,6 @@ extern struct pt_alloc_ops pt_ops __initdata;
 
 extern pgd_t swapper_pg_dir[];
 
-/* MAP_PRIVATE permissions: xwr (copy-on-write) */
-#define __P000	PAGE_NONE
-#define __P001	PAGE_READ
-#define __P010	PAGE_COPY
-#define __P011	PAGE_COPY
-#define __P100	PAGE_EXEC
-#define __P101	PAGE_READ_EXEC
-#define __P110	PAGE_COPY_EXEC
-#define __P111	PAGE_COPY_READ_EXEC
-
-/* MAP_SHARED permissions: xwr */
-#define __S000	PAGE_NONE
-#define __S001	PAGE_READ
-#define __S010	PAGE_SHARED
-#define __S011	PAGE_SHARED
-#define __S100	PAGE_EXEC
-#define __S101	PAGE_READ_EXEC
-#define __S110	PAGE_SHARED_EXEC
-#define __S111	PAGE_SHARED_EXEC
-
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline int pmd_present(pmd_t pmd)
 {
diff --git a/arch/riscv/mm/init.c b/arch/riscv/mm/init.c
index d466ec670e1f..a88b7dc31a68 100644
--- a/arch/riscv/mm/init.c
+++ b/arch/riscv/mm/init.c
@@ -288,6 +288,26 @@ static pmd_t __maybe_unused early_dtb_pmd[PTRS_PER_PMD] __initdata __aligned(PAG
 #define early_pg_dir           ((pgd_t *)XIP_FIXUP(early_pg_dir))
 #endif /* CONFIG_XIP_KERNEL */
 
+static const pgprot_t protection_map[16] = {
+	[VM_NONE]					= PAGE_NONE,
+	[VM_READ]					= PAGE_READ,
+	[VM_WRITE]					= PAGE_COPY,
+	[VM_WRITE | VM_READ]				= PAGE_COPY,
+	[VM_EXEC]					= PAGE_EXEC,
+	[VM_EXEC | VM_READ]				= PAGE_READ_EXEC,
+	[VM_EXEC | VM_WRITE]				= PAGE_COPY_EXEC,
+	[VM_EXEC | VM_WRITE | VM_READ]			= PAGE_COPY_READ_EXEC,
+	[VM_SHARED]					= PAGE_NONE,
+	[VM_SHARED | VM_READ]				= PAGE_READ,
+	[VM_SHARED | VM_WRITE]				= PAGE_SHARED,
+	[VM_SHARED | VM_WRITE | VM_READ]		= PAGE_SHARED,
+	[VM_SHARED | VM_EXEC]				= PAGE_EXEC,
+	[VM_SHARED | VM_EXEC | VM_READ]			= PAGE_READ_EXEC,
+	[VM_SHARED | VM_EXEC | VM_WRITE]		= PAGE_SHARED_EXEC,
+	[VM_SHARED | VM_EXEC | VM_WRITE | VM_READ]	= PAGE_SHARED_EXEC
+};
+DECLARE_VM_GET_PAGE_PROT
+
 void __set_fixmap(enum fixed_addresses idx, phys_addr_t phys, pgprot_t prot)
 {
 	unsigned long addr = __fix_to_virt(idx);
-- 
2.25.1
