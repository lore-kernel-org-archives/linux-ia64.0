From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 28 Feb 2022 10:59:52 +0000
Subject: [PATCH V3 29/30] mm/mmap: Drop generic vm_get_page_prot()
Message-Id: <1646045273-9343-30-git-send-email-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1646045273-9343-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1646045273-9343-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, geert@linux-m68k.org, Anshuman Khandual <anshuman.khandual@arm.com>, Christoph Hellwig <hch@infradead.org>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-s390@vger.kernel.org, linux-riscv@lists.infradead.org, linux-alpha@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-parisc@vger.kernel.org, openrisc@lists.librecores.org, linux-um@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org

All available platforms export their own vm_get_page_prot() implementation
via ARCH_HAS_VM_GET_PAGE_PROT. Hence a generic implementation is no longer
needed.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 mm/mmap.c | 40 ----------------------------------------
 1 file changed, 40 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index c13dd9c37866..ff343f76a825 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -102,46 +102,6 @@ static void unmap_region(struct mm_struct *mm,
  *								w: (no) no
  *								x: (yes) yes
  */
-pgprot_t vm_get_page_prot(unsigned long vm_flags)
-{
-	switch (vm_flags & (VM_READ | VM_WRITE | VM_EXEC | VM_SHARED)) {
-	case VM_NONE:
-		return __P000;
-	case VM_READ:
-		return __P001;
-	case VM_WRITE:
-		return __P010;
-	case VM_READ | VM_WRITE:
-		return __P011;
-	case VM_EXEC:
-		return __P100;
-	case VM_EXEC | VM_READ:
-		return __P101;
-	case VM_EXEC | VM_WRITE:
-		return __P110;
-	case VM_EXEC | VM_READ | VM_WRITE:
-		return __P111;
-	case VM_SHARED:
-		return __S000;
-	case VM_SHARED | VM_READ:
-		return __S001;
-	case VM_SHARED | VM_WRITE:
-		return __S010;
-	case VM_SHARED | VM_READ | VM_WRITE:
-		return __S011;
-	case VM_SHARED | VM_EXEC:
-		return __S100;
-	case VM_SHARED | VM_EXEC | VM_READ:
-		return __S101;
-	case VM_SHARED | VM_EXEC | VM_WRITE:
-		return __S110;
-	case VM_SHARED | VM_EXEC | VM_READ | VM_WRITE:
-		return __S111;
-	default:
-		BUILD_BUG();
-	}
-}
-EXPORT_SYMBOL(vm_get_page_prot);
 #endif	/* CONFIG_ARCH_HAS_VM_GET_PAGE_PROT */
 
 static pgprot_t vm_pgprot_modify(pgprot_t oldprot, unsigned long vm_flags)
-- 
2.25.1
