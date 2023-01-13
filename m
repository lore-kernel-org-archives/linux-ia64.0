From: David Hildenbrand <david@redhat.com>
Date: Fri, 13 Jan 2023 17:10:21 +0000
Subject: [PATCH mm-unstable v1 21/26] sparc/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE on 32bit
Message-Id: <20230113171026.582290-22-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230113171026.582290-1-david@redhat.com>
In-Reply-To: <20230113171026.582290-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, David Hildenbrand <david@redhat.com>, "David S. Miller" <davem@davemloft.net>

Let's support __HAVE_ARCH_PTE_SWP_EXCLUSIVE by reusing the SRMMU_DIRTY
bit as that seems to be safe to reuse inside a swap PTE. This avoids
having to steal one bit from the swap offset.

While at it, relocate the swap PTE layout documentation and use the same
style now used for most other archs. Note that the old documentation was
wrong: we use 20 bit for the offset and the reserved bits were 8 instead
of 7 bits in the ascii art.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/sparc/include/asm/pgtable_32.h | 27 ++++++++++++++++++++++++++-
 arch/sparc/include/asm/pgtsrmmu.h   | 14 +++-----------
 2 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_32.h b/arch/sparc/include/asm/pgtable_32.h
index 5acc05b572e6..abf7a2601209 100644
--- a/arch/sparc/include/asm/pgtable_32.h
+++ b/arch/sparc/include/asm/pgtable_32.h
@@ -323,7 +323,16 @@ void srmmu_mapiorange(unsigned int bus, unsigned long xpa,
                       unsigned long xva, unsigned int len);
 void srmmu_unmapiorange(unsigned long virt_addr, unsigned int len);
 
-/* Encode and de-code a swap entry */
+/*
+ * Encode/decode swap entries and swap PTEs. Swap PTEs are all PTEs that
+ * are !pte_none() && !pte_present().
+ *
+ * Format of swap PTEs:
+ *
+ *   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
+ *   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
+ *   <-------------- offset ---------------> < type -> E 0 0 0 0 0 0
+ */
 static inline unsigned long __swp_type(swp_entry_t entry)
 {
 	return (entry.val >> SRMMU_SWP_TYPE_SHIFT) & SRMMU_SWP_TYPE_MASK;
@@ -344,6 +353,22 @@ static inline swp_entry_t __swp_entry(unsigned long type, unsigned long offset)
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
+#define __HAVE_ARCH_PTE_SWP_EXCLUSIVE
+static inline int pte_swp_exclusive(pte_t pte)
+{
+	return pte_val(pte) & SRMMU_SWP_EXCLUSIVE;
+}
+
+static inline pte_t pte_swp_mkexclusive(pte_t pte)
+{
+	return __pte(pte_val(pte) | SRMMU_SWP_EXCLUSIVE);
+}
+
+static inline pte_t pte_swp_clear_exclusive(pte_t pte)
+{
+	return __pte(pte_val(pte) & ~SRMMU_SWP_EXCLUSIVE);
+}
+
 static inline unsigned long
 __get_phys (unsigned long addr)
 {
diff --git a/arch/sparc/include/asm/pgtsrmmu.h b/arch/sparc/include/asm/pgtsrmmu.h
index 6067925972d9..18e68d43f036 100644
--- a/arch/sparc/include/asm/pgtsrmmu.h
+++ b/arch/sparc/include/asm/pgtsrmmu.h
@@ -53,21 +53,13 @@
 
 #define SRMMU_CHG_MASK    (0xffffff00 | SRMMU_REF | SRMMU_DIRTY)
 
-/* SRMMU swap entry encoding
- *
- * We use 5 bits for the type and 19 for the offset.  This gives us
- * 32 swapfiles of 4GB each.  Encoding looks like:
- *
- * oooooooooooooooooootttttRRRRRRRR
- * fedcba9876543210fedcba9876543210
- *
- * The bottom 7 bits are reserved for protection and status bits, especially
- * PRESENT.
- */
+/* SRMMU swap entry encoding */
 #define SRMMU_SWP_TYPE_MASK	0x1f
 #define SRMMU_SWP_TYPE_SHIFT	7
 #define SRMMU_SWP_OFF_MASK	0xfffff
 #define SRMMU_SWP_OFF_SHIFT	(SRMMU_SWP_TYPE_SHIFT + 5)
+/* We borrow bit 6 to store the exclusive marker in swap PTEs. */
+#define SRMMU_SWP_EXCLUSIVE	SRMMU_DIRTY
 
 /* Some day I will implement true fine grained access bits for
  * user pages because the SRMMU gives us the capabilities to
-- 
2.39.0
