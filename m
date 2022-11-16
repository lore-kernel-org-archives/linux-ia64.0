From: David Hildenbrand <david@redhat.com>
Date: Wed, 16 Nov 2022 10:26:43 +0000
Subject: [PATCH mm-unstable v1 04/20] mm: add early FAULT_FLAG_UNSHARE consistency checks
Message-Id: <20221116102659.70287-5-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221116102659.70287-1-david@redhat.com>
In-Reply-To: <20221116102659.70287-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, etnaviv@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-security-module@vger.kernel.org, linux-kselftest@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Nadav Amit <namit@vmware.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Muchun Song <songmuchun@bytedance.com>, Shuah Khan <shuah@kernel.org>, Lucas Stach <l.stach@pengutronix.de>, David Airlie <airlied@gmail.com>, Oded Gabbay <ogabbay@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>, Alex Williamson <alex.williamson@redhat.com>, David Hildenbrand <david@redhat.com>

For now, FAULT_FLAG_UNSHARE only applies to anonymous pages, which
implies a COW mapping. Let's hide FAULT_FLAG_UNSHARE early if we're not
dealing with a COW mapping, such that we treat it like a read fault as
documented and don't have to worry about the flag throughout all fault
handlers.

While at it, centralize the check for mutual exclusion of
FAULT_FLAG_UNSHARE and FAULT_FLAG_WRITE and just drop the check that
either flag is set in the WP handler.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/huge_memory.c |  3 ---
 mm/hugetlb.c     |  5 -----
 mm/memory.c      | 23 ++++++++++++++++++++---
 3 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ed12cd3acbfd..68d00196b519 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1267,9 +1267,6 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf)
 	vmf->ptl = pmd_lockptr(vma->vm_mm, vmf->pmd);
 	VM_BUG_ON_VMA(!vma->anon_vma, vma);
 
-	VM_BUG_ON(unshare && (vmf->flags & FAULT_FLAG_WRITE));
-	VM_BUG_ON(!unshare && !(vmf->flags & FAULT_FLAG_WRITE));
-
 	if (is_huge_zero_pmd(orig_pmd))
 		goto fallback;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1de986c62976..383b26069b33 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -5314,9 +5314,6 @@ static vm_fault_t hugetlb_wp(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long haddr = address & huge_page_mask(h);
 	struct mmu_notifier_range range;
 
-	VM_BUG_ON(unshare && (flags & FOLL_WRITE));
-	VM_BUG_ON(!unshare && !(flags & FOLL_WRITE));
-
 	/*
 	 * hugetlb does not support FOLL_FORCE-style write faults that keep the
 	 * PTE mapped R/O such as maybe_mkwrite() would do.
@@ -5326,8 +5323,6 @@ static vm_fault_t hugetlb_wp(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	/* Let's take out MAP_SHARED mappings first. */
 	if (vma->vm_flags & VM_MAYSHARE) {
-		if (unlikely(unshare))
-			return 0;
 		set_huge_ptep_writable(vma, haddr, ptep);
 		return 0;
 	}
diff --git a/mm/memory.c b/mm/memory.c
index 2d453736f87c..e014435a87db 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3344,9 +3344,6 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	struct folio *folio;
 
-	VM_BUG_ON(unshare && (vmf->flags & FAULT_FLAG_WRITE));
-	VM_BUG_ON(!unshare && !(vmf->flags & FAULT_FLAG_WRITE));
-
 	if (likely(!unshare)) {
 		if (userfaultfd_pte_wp(vma, *vmf->pte)) {
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -5161,6 +5158,22 @@ static void lru_gen_exit_fault(void)
 }
 #endif /* CONFIG_LRU_GEN */
 
+static vm_fault_t sanitize_fault_flags(struct vm_area_struct *vma,
+				       unsigned int *flags)
+{
+	if (unlikely(*flags & FAULT_FLAG_UNSHARE)) {
+		if (WARN_ON_ONCE(*flags & FAULT_FLAG_WRITE))
+			return VM_FAULT_SIGSEGV;
+		/*
+		 * FAULT_FLAG_UNSHARE only applies to COW mappings. Let's
+		 * just treat it like an ordinary read-fault otherwise.
+		 */
+		if (!is_cow_mapping(vma->vm_flags))
+			*flags &= ~FAULT_FLAG_UNSHARE;
+	}
+	return 0;
+}
+
 /*
  * By the time we get here, we already hold the mm semaphore
  *
@@ -5177,6 +5190,10 @@ vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	count_vm_event(PGFAULT);
 	count_memcg_event_mm(vma->vm_mm, PGFAULT);
 
+	ret = sanitize_fault_flags(vma, &flags);
+	if (ret)
+		return ret;
+
 	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
 					    flags & FAULT_FLAG_INSTRUCTION,
 					    flags & FAULT_FLAG_REMOTE))
-- 
2.38.1
