From: Mike Rapoport <rppt@kernel.org>
Date: Sun, 16 Feb 2020 08:18:38 +0000
Subject: [PATCH v2 08/13] sh: fault: Modernize printing of kernel messages
Message-Id: <20200216081843.28670-9-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200216081843.28670-1-rppt@kernel.org>
In-Reply-To: <20200216081843.28670-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, linux-hexagon@vger.kernel.org, Will Deacon <will@kernel.org>, kvmarm@lists.cs.columbia.edu, Jonas Bonn <jonas@southpole.se>, linux-arch@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, Marc Zyngier <maz@kernel.org>, Russell King <linux@armlinux.org.uk>, Ley Foon Tan <ley.foon.tan@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, kvm-ppc@vger.kernel.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, nios2-dev@lists.rocketboards.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mike Rapoport <rppt@kernel.org>

From: Geert Uytterhoeven <geert+renesas@glider.be>

  - Convert from printk() to pr_*(),
  - Add missing continuations,
  - Use "%llx" to format u64,
  - Join multiple prints in show_fault_oops() into a single print.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/sh/mm/fault.c | 39 ++++++++++++++++++---------------------
 1 file changed, 18 insertions(+), 21 deletions(-)

diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 5f51456f4fc7..a2b0275413e8 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -47,10 +47,10 @@ static void show_pte(struct mm_struct *mm, unsigned long addr)
 			pgd = swapper_pg_dir;
 	}
 
-	printk(KERN_ALERT "pgd = %p\n", pgd);
+	pr_alert("pgd = %p\n", pgd);
 	pgd += pgd_index(addr);
-	printk(KERN_ALERT "[%08lx] *pgd=%0*Lx", addr,
-	       (u32)(sizeof(*pgd) * 2), (u64)pgd_val(*pgd));
+	pr_alert("[%08lx] *pgd=%0*llx", addr, (u32)(sizeof(*pgd) * 2),
+		 (u64)pgd_val(*pgd));
 
 	do {
 		pud_t *pud;
@@ -61,33 +61,33 @@ static void show_pte(struct mm_struct *mm, unsigned long addr)
 			break;
 
 		if (pgd_bad(*pgd)) {
-			printk("(bad)");
+			pr_cont("(bad)");
 			break;
 		}
 
 		pud = pud_offset(pgd, addr);
 		if (PTRS_PER_PUD != 1)
-			printk(", *pud=%0*Lx", (u32)(sizeof(*pud) * 2),
-			       (u64)pud_val(*pud));
+			pr_cont(", *pud=%0*llx", (u32)(sizeof(*pud) * 2),
+				(u64)pud_val(*pud));
 
 		if (pud_none(*pud))
 			break;
 
 		if (pud_bad(*pud)) {
-			printk("(bad)");
+			pr_cont("(bad)");
 			break;
 		}
 
 		pmd = pmd_offset(pud, addr);
 		if (PTRS_PER_PMD != 1)
-			printk(", *pmd=%0*Lx", (u32)(sizeof(*pmd) * 2),
-			       (u64)pmd_val(*pmd));
+			pr_cont(", *pmd=%0*llx", (u32)(sizeof(*pmd) * 2),
+				(u64)pmd_val(*pmd));
 
 		if (pmd_none(*pmd))
 			break;
 
 		if (pmd_bad(*pmd)) {
-			printk("(bad)");
+			pr_cont("(bad)");
 			break;
 		}
 
@@ -96,11 +96,11 @@ static void show_pte(struct mm_struct *mm, unsigned long addr)
 			break;
 
 		pte = pte_offset_kernel(pmd, addr);
-		printk(", *pte=%0*Lx", (u32)(sizeof(*pte) * 2),
-		       (u64)pte_val(*pte));
+		pr_cont(", *pte=%0*llx", (u32)(sizeof(*pte) * 2),
+			(u64)pte_val(*pte));
 	} while (0);
 
-	printk("\n");
+	pr_cont("\n");
 }
 
 static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
@@ -188,14 +188,11 @@ show_fault_oops(struct pt_regs *regs, unsigned long address)
 	if (!oops_may_print())
 		return;
 
-	printk(KERN_ALERT "BUG: unable to handle kernel ");
-	if (address < PAGE_SIZE)
-		printk(KERN_CONT "NULL pointer dereference");
-	else
-		printk(KERN_CONT "paging request");
-
-	printk(KERN_CONT " at %08lx\n", address);
-	printk(KERN_ALERT "PC:");
+	pr_alert("BUG: unable to handle kernel %s at %08lx\n",
+		 address < PAGE_SIZE ? "NULL pointer dereference"
+				     : "paging request",
+		 address);
+	pr_alert("PC:");
 	printk_address(regs->pc, 1);
 
 	show_pte(NULL, address);
-- 
2.24.0
