From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 30 Jun 2022 05:28:18 +0000
Subject: [PATCH V6 14/26] alpha/mm: Enable ARCH_HAS_VM_GET_PAGE_PROT
Message-Id: <20220630051630.1718927-15-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220630051630.1718927-1-anshuman.khandual@arm.com>
In-Reply-To: <20220630051630.1718927-1-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: hch@infradead.org, christophe.leroy@csgroup.eu, Anshuman Khandual <anshuman.khandual@arm.com>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, openrisc@lists.librecores.org, linux-xtensa@linux-xtensa.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-um@lists.infradead.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>

This enables ARCH_HAS_VM_GET_PAGE_PROT on the platform and exports standard
vm_get_page_prot() implementation via DECLARE_VM_GET_PAGE_PROT, which looks
up a private and static protection_map[] array. Subsequently all __SXXX and
__PXXX macros can be dropped which are no longer needed.

Cc: Richard Henderson <rth@twiddle.net>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/alpha/Kconfig               |  1 +
 arch/alpha/include/asm/pgtable.h | 17 -----------------
 arch/alpha/mm/init.c             | 22 ++++++++++++++++++++++
 3 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index 7d0d26b5b3f5..db1c8b329461 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -2,6 +2,7 @@
 config ALPHA
 	bool
 	default y
+	select ARCH_HAS_VM_GET_PAGE_PROT
 	select ARCH_32BIT_USTAT_F_TINODE
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
diff --git a/arch/alpha/include/asm/pgtable.h b/arch/alpha/include/asm/pgtable.h
index 170451fde043..3ea9661c09ff 100644
--- a/arch/alpha/include/asm/pgtable.h
+++ b/arch/alpha/include/asm/pgtable.h
@@ -116,23 +116,6 @@ struct vm_area_struct;
  * arch/alpha/mm/fault.c)
  */
 	/* xwr */
-#define __P000	_PAGE_P(_PAGE_FOE | _PAGE_FOW | _PAGE_FOR)
-#define __P001	_PAGE_P(_PAGE_FOE | _PAGE_FOW)
-#define __P010	_PAGE_P(_PAGE_FOE)
-#define __P011	_PAGE_P(_PAGE_FOE)
-#define __P100	_PAGE_P(_PAGE_FOW | _PAGE_FOR)
-#define __P101	_PAGE_P(_PAGE_FOW)
-#define __P110	_PAGE_P(0)
-#define __P111	_PAGE_P(0)
-
-#define __S000	_PAGE_S(_PAGE_FOE | _PAGE_FOW | _PAGE_FOR)
-#define __S001	_PAGE_S(_PAGE_FOE | _PAGE_FOW)
-#define __S010	_PAGE_S(_PAGE_FOE)
-#define __S011	_PAGE_S(_PAGE_FOE)
-#define __S100	_PAGE_S(_PAGE_FOW | _PAGE_FOR)
-#define __S101	_PAGE_S(_PAGE_FOW)
-#define __S110	_PAGE_S(0)
-#define __S111	_PAGE_S(0)
 
 /*
  * pgprot_noncached() is only for infiniband pci support, and a real
diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index 7511723b7669..a155180d7a83 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -280,3 +280,25 @@ mem_init(void)
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 	memblock_free_all();
 }
+
+static const pgprot_t protection_map[16] = {
+	[VM_NONE]					= _PAGE_P(_PAGE_FOE | _PAGE_FOW |
+								  _PAGE_FOR),
+	[VM_READ]					= _PAGE_P(_PAGE_FOE | _PAGE_FOW),
+	[VM_WRITE]					= _PAGE_P(_PAGE_FOE),
+	[VM_WRITE | VM_READ]				= _PAGE_P(_PAGE_FOE),
+	[VM_EXEC]					= _PAGE_P(_PAGE_FOW | _PAGE_FOR),
+	[VM_EXEC | VM_READ]				= _PAGE_P(_PAGE_FOW),
+	[VM_EXEC | VM_WRITE]				= _PAGE_P(0),
+	[VM_EXEC | VM_WRITE | VM_READ]			= _PAGE_P(0),
+	[VM_SHARED]					= _PAGE_S(_PAGE_FOE | _PAGE_FOW |
+								  _PAGE_FOR),
+	[VM_SHARED | VM_READ]				= _PAGE_S(_PAGE_FOE | _PAGE_FOW),
+	[VM_SHARED | VM_WRITE]				= _PAGE_S(_PAGE_FOE),
+	[VM_SHARED | VM_WRITE | VM_READ]		= _PAGE_S(_PAGE_FOE),
+	[VM_SHARED | VM_EXEC]				= _PAGE_S(_PAGE_FOW | _PAGE_FOR),
+	[VM_SHARED | VM_EXEC | VM_READ]			= _PAGE_S(_PAGE_FOW),
+	[VM_SHARED | VM_EXEC | VM_WRITE]		= _PAGE_S(0),
+	[VM_SHARED | VM_EXEC | VM_WRITE | VM_READ]	= _PAGE_S(0)
+};
+DECLARE_VM_GET_PAGE_PROT
-- 
2.25.1
