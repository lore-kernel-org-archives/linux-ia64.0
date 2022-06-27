From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 27 Jun 2022 05:10:31 +0000
Subject: [PATCH V5 24/26] um/mm: Enable ARCH_HAS_VM_GET_PAGE_PROT
Message-Id: <20220627045833.1590055-25-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220627045833.1590055-1-anshuman.khandual@arm.com>
In-Reply-To: <20220627045833.1590055-1-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: hch@infradead.org, christophe.leroy@csgroup.eu, Anshuman Khandual <anshuman.khandual@arm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, openrisc@lists.librecores.org, linux-xtensa@linux-xtensa.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-um@lists.infradead.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Dike <jdike@addtoit.com>

This enables ARCH_HAS_VM_GET_PAGE_PROT on the platform and exports standard
vm_get_page_prot() implementation via DECLARE_VM_GET_PAGE_PROT, which looks
up a private and static protection_map[] array. Subsequently all __SXXX and
__PXXX macros can be dropped which are no longer needed.

Cc: Jeff Dike <jdike@addtoit.com>
Cc: linux-um@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/um/Kconfig               |  1 +
 arch/um/include/asm/pgtable.h | 17 -----------------
 arch/um/kernel/mem.c          | 20 ++++++++++++++++++++
 arch/x86/um/mem_32.c          |  2 +-
 4 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/arch/um/Kconfig b/arch/um/Kconfig
index 4ec22e156a2e..7fb43654e5b5 100644
--- a/arch/um/Kconfig
+++ b/arch/um/Kconfig
@@ -10,6 +10,7 @@ config UML
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_STRNCPY_FROM_USER
 	select ARCH_HAS_STRNLEN_USER
+	select ARCH_HAS_VM_GET_PAGE_PROT
 	select ARCH_NO_PREEMPT
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_SECCOMP_FILTER
diff --git a/arch/um/include/asm/pgtable.h b/arch/um/include/asm/pgtable.h
index 167e236d9bb8..66bc3f99d9be 100644
--- a/arch/um/include/asm/pgtable.h
+++ b/arch/um/include/asm/pgtable.h
@@ -68,23 +68,6 @@ extern unsigned long end_iomem;
  * Also, write permissions imply read permissions. This is the closest we can
  * get..
  */
-#define __P000	PAGE_NONE
-#define __P001	PAGE_READONLY
-#define __P010	PAGE_COPY
-#define __P011	PAGE_COPY
-#define __P100	PAGE_READONLY
-#define __P101	PAGE_READONLY
-#define __P110	PAGE_COPY
-#define __P111	PAGE_COPY
-
-#define __S000	PAGE_NONE
-#define __S001	PAGE_READONLY
-#define __S010	PAGE_SHARED
-#define __S011	PAGE_SHARED
-#define __S100	PAGE_READONLY
-#define __S101	PAGE_READONLY
-#define __S110	PAGE_SHARED
-#define __S111	PAGE_SHARED
 
 /*
  * ZERO_PAGE is a global shared page that is always zero: used
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 15295c3237a0..5b259f0a1f94 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -197,3 +197,23 @@ void *uml_kmalloc(int size, int flags)
 {
 	return kmalloc(size, flags);
 }
+
+static const pgprot_t protection_map[16] = {
+	[VM_NONE]					= PAGE_NONE,
+	[VM_READ]					= PAGE_READONLY,
+	[VM_WRITE]					= PAGE_COPY,
+	[VM_WRITE | VM_READ]				= PAGE_COPY,
+	[VM_EXEC]					= PAGE_READONLY,
+	[VM_EXEC | VM_READ]				= PAGE_READONLY,
+	[VM_EXEC | VM_WRITE]				= PAGE_COPY,
+	[VM_EXEC | VM_WRITE | VM_READ]			= PAGE_COPY,
+	[VM_SHARED]					= PAGE_NONE,
+	[VM_SHARED | VM_READ]				= PAGE_READONLY,
+	[VM_SHARED | VM_WRITE]				= PAGE_SHARED,
+	[VM_SHARED | VM_WRITE | VM_READ]		= PAGE_SHARED,
+	[VM_SHARED | VM_EXEC]				= PAGE_READONLY,
+	[VM_SHARED | VM_EXEC | VM_READ]			= PAGE_READONLY,
+	[VM_SHARED | VM_EXEC | VM_WRITE]		= PAGE_SHARED,
+	[VM_SHARED | VM_EXEC | VM_WRITE | VM_READ]	= PAGE_SHARED
+};
+DECLARE_VM_GET_PAGE_PROT
diff --git a/arch/x86/um/mem_32.c b/arch/x86/um/mem_32.c
index 19c5dbd46770..cafd01f730da 100644
--- a/arch/x86/um/mem_32.c
+++ b/arch/x86/um/mem_32.c
@@ -17,7 +17,7 @@ static int __init gate_vma_init(void)
 	gate_vma.vm_start = FIXADDR_USER_START;
 	gate_vma.vm_end = FIXADDR_USER_END;
 	gate_vma.vm_flags = VM_READ | VM_MAYREAD | VM_EXEC | VM_MAYEXEC;
-	gate_vma.vm_page_prot = __P101;
+	gate_vma.vm_page_prot = PAGE_READONLY;
 
 	return 0;
 }
-- 
2.25.1
