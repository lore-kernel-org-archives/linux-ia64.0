From: Steven Price <steven.price@arm.com>
Date: Wed, 27 Feb 2019 17:05:42 +0000
Subject: [PATCH v3 08/34] ia64: mm: Add p?d_large() definitions
Message-Id: <20190227170608.27963-9-steven.price@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190227170608.27963-1-steven.price@arm.com>
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>, Andy Lutomirski <luto@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Mark Rutland <Mark.Rutland@arm.com>, "Liang, Kan" <kan.liang@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For ia64 leaf entries are always at the lowest level, so implement
stubs returning 0.

CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/ia64/include/asm/pgtable.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index b1e7468eb65a..84dda295391b 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -271,6 +271,7 @@ extern unsigned long VMALLOC_END;
 #define pmd_none(pmd)			(!pmd_val(pmd))
 #define pmd_bad(pmd)			(!ia64_phys_addr_valid(pmd_val(pmd)))
 #define pmd_present(pmd)		(pmd_val(pmd) != 0UL)
+#define pmd_large(pmd)			(0)
 #define pmd_clear(pmdp)			(pmd_val(*(pmdp)) = 0UL)
 #define pmd_page_vaddr(pmd)		((unsigned long) __va(pmd_val(pmd) & _PFN_MASK))
 #define pmd_page(pmd)			virt_to_page((pmd_val(pmd) + PAGE_OFFSET))
@@ -278,6 +279,7 @@ extern unsigned long VMALLOC_END;
 #define pud_none(pud)			(!pud_val(pud))
 #define pud_bad(pud)			(!ia64_phys_addr_valid(pud_val(pud)))
 #define pud_present(pud)		(pud_val(pud) != 0UL)
+#define pud_large(pud)			(0)
 #define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
 #define pud_page_vaddr(pud)		((unsigned long) __va(pud_val(pud) & _PFN_MASK))
 #define pud_page(pud)			virt_to_page((pud_val(pud) + PAGE_OFFSET))
@@ -286,6 +288,7 @@ extern unsigned long VMALLOC_END;
 #define pgd_none(pgd)			(!pgd_val(pgd))
 #define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
 #define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
+#define pgd_large(pgd)			(0)
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 #define pgd_page_vaddr(pgd)		((unsigned long) __va(pgd_val(pgd) & _PFN_MASK))
 #define pgd_page(pgd)			virt_to_page((pgd_val(pgd) + PAGE_OFFSET))
-- 
2.20.1
