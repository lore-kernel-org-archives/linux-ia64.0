From: Mike Rapoport <rppt@kernel.org>
Date: Tue, 14 Apr 2020 15:34:45 +0000
Subject: [PATCH v4 04/14] hexagon: remove __ARCH_USE_5LEVEL_HACK
Message-Id: <20200414153455.21744-5-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200414153455.21744-1-rppt@kernel.org>
In-Reply-To: <20200414153455.21744-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, linux-hexagon@vger.kernel.org, Will Deacon <will@kernel.org>, kvmarm@lists.cs.columbia.edu, Jonas Bonn <jonas@southpole.se>, linux-arch@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, Marc Zyngier <maz@kernel.org>, Russell King <linux@armlinux.org.uk>, Ley Foon Tan <ley.foon.tan@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, kvm-ppc@vger.kernel.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, nios2-dev@lists.rocketboards.org, linuxppc-dev@lists.ozlabs.org, Mike Rapoport <rppt@kernel.org>

From: Mike Rapoport <rppt@linux.ibm.com>

The hexagon architecture has 2 level page tables and as such most of the
page table folding is already implemented in asm-generic/pgtable-nopmd.h.

Fixup the only place in arch/hexagon to unfold the p4d level and remove
__ARCH_USE_5LEVEL_HACK.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/hexagon/include/asm/fixmap.h  | 4 ++--
 arch/hexagon/include/asm/pgtable.h | 1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/hexagon/include/asm/fixmap.h b/arch/hexagon/include/asm/fixmap.h
index 933dac167504..97b1b062e750 100644
--- a/arch/hexagon/include/asm/fixmap.h
+++ b/arch/hexagon/include/asm/fixmap.h
@@ -16,7 +16,7 @@
 #include <asm-generic/fixmap.h>
 
 #define kmap_get_fixmap_pte(vaddr) \
-	pte_offset_kernel(pmd_offset(pud_offset(pgd_offset_k(vaddr), \
-				(vaddr)), (vaddr)), (vaddr))
+	pte_offset_kernel(pmd_offset(pud_offset(p4d_offset(pgd_offset_k(vaddr), \
+				(vaddr)), (vaddr)), (vaddr)), (vaddr))
 
 #endif
diff --git a/arch/hexagon/include/asm/pgtable.h b/arch/hexagon/include/asm/pgtable.h
index d383e8bea5b2..2a17d4eb2fa4 100644
--- a/arch/hexagon/include/asm/pgtable.h
+++ b/arch/hexagon/include/asm/pgtable.h
@@ -12,7 +12,6 @@
  * Page table definitions for Qualcomm Hexagon processor.
  */
 #include <asm/page.h>
-#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 /* A handy thing to have if one has the RAM. Declared in head.S */
-- 
2.25.1
