From: David Hildenbrand <david@redhat.com>
Date: Tue, 06 Dec 2022 14:47:05 +0000
Subject: [PATCH mm-unstable RFC 01/26] mm/debug_vm_pgtable: more pte_swp_exclusive() sanity checks
Message-Id: <20221206144730.163732-2-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221206144730.163732-1-david@redhat.com>
In-Reply-To: <20221206144730.163732-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, David Hildenbrand <david@redhat.com>

We want to implement __HAVE_ARCH_PTE_SWP_EXCLUSIVE on all architectures.
Let's extend our sanity checks, especially testing that our PTE bit
does not affect:
* is_swap_pte() -> pte_present() and pte_none()
* the swap entry + type
* pte_swp_soft_dirty()

Especially, the pfn_pte() is dodgy when the swap PTE layout differs
heavily from ordinary PTEs. Let's properly construct a swap PTE from
swap type+offset.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/debug_vm_pgtable.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/mm/debug_vm_pgtable.c b/mm/debug_vm_pgtable.c
index c631ade3f1d2..0506622016d9 100644
--- a/mm/debug_vm_pgtable.c
+++ b/mm/debug_vm_pgtable.c
@@ -807,13 +807,34 @@ static void __init pmd_swap_soft_dirty_tests(struct pgtable_debug_args *args) {
 static void __init pte_swap_exclusive_tests(struct pgtable_debug_args *args)
 {
 #ifdef __HAVE_ARCH_PTE_SWP_EXCLUSIVE
-	pte_t pte = pfn_pte(args->fixed_pte_pfn, args->page_prot);
+	unsigned long max_swapfile_size = generic_max_swapfile_size();
+	swp_entry_t entry, entry2;
+	pte_t pte;
 
 	pr_debug("Validating PTE swap exclusive\n");
+
+	/* Create a swp entry with all possible bits set */
+	entry = swp_entry((1 << MAX_SWAPFILES_SHIFT) - 1,
+			  max_swapfile_size - 1);
+
+	pte = swp_entry_to_pte(entry);
+	WARN_ON(pte_swp_exclusive(pte));
+	WARN_ON(!is_swap_pte(pte));
+	entry2 = pte_to_swp_entry(pte);
+	WARN_ON(memcmp(&entry, &entry2, sizeof(entry)));
+
 	pte = pte_swp_mkexclusive(pte);
 	WARN_ON(!pte_swp_exclusive(pte));
+	WARN_ON(!is_swap_pte(pte));
+	WARN_ON(pte_swp_soft_dirty(pte));
+	entry2 = pte_to_swp_entry(pte);
+	WARN_ON(memcmp(&entry, &entry2, sizeof(entry)));
+
 	pte = pte_swp_clear_exclusive(pte);
 	WARN_ON(pte_swp_exclusive(pte));
+	WARN_ON(!is_swap_pte(pte));
+	entry2 = pte_to_swp_entry(pte);
+	WARN_ON(memcmp(&entry, &entry2, sizeof(entry)));
 #endif /* __HAVE_ARCH_PTE_SWP_EXCLUSIVE */
 }
 
-- 
2.38.1
