From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Tue, 21 Jun 2022 23:56:18 +0000
Subject: [PATCH v2 2/4] arm64/hugetlb: Implement arm64 specific hugetlb_mask_last_page
Message-Id: <20220621235620.291305-3-mike.kravetz@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220621235620.291305-1-mike.kravetz@oracle.com>
In-Reply-To: <20220621235620.291305-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: Muchun Song <songmuchun@bytedance.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Peter Xu <peterx@redhat.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, James Houghton <jthoughton@google.com>, Mina Almasry <almasrymina@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, catalin.marinas@arm.com, will@kernel.org, Rolf Eike Beer <eike-kernel@sf-tec.de>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Baolin Wang <baolin.wang@linux.alibaba.com>

The HugeTLB address ranges are linearly scanned during fork, unmap and
remap operations, and the linear scan can skip to the end of range mapped
by the page table page if hitting a non-present entry, which can help
to speed linear scanning of the HugeTLB address ranges.

So hugetlb_mask_last_page() is introduced to help to update the address in
the loop of HugeTLB linear scanning with getting the last huge page mapped
by the associated page table page[1], when a non-present entry is encountered.

Considering ARM64 specific cont-pte/pmd size HugeTLB, this patch implemented
an ARM64 specific hugetlb_mask_last_page() to help this case.

[1] https://lore.kernel.org/linux-mm/20220527225849.284839-1-mike.kravetz@oracle.com/

Signed-off-by: Baolin Wang <baolin.wang@linux.alibaba.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Acked-by: Muchun Song <songmuchun@bytedance.com>
---
 arch/arm64/mm/hugetlbpage.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index e2a5ec9fdc0d..c9e076683e5d 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -368,6 +368,26 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 	return NULL;
 }
 
+unsigned long hugetlb_mask_last_page(struct hstate *h)
+{
+	unsigned long hp_size = huge_page_size(h);
+
+	switch (hp_size) {
+	case PUD_SIZE:
+		return PGDIR_SIZE - PUD_SIZE;
+	case CONT_PMD_SIZE:
+		return PUD_SIZE - CONT_PMD_SIZE;
+	case PMD_SIZE:
+		return PUD_SIZE - PMD_SIZE;
+	case CONT_PTE_SIZE:
+		return PMD_SIZE - CONT_PTE_SIZE;
+	default:
+		break;
+	}
+
+	return 0UL;
+}
+
 pte_t arch_make_huge_pte(pte_t entry, unsigned int shift, vm_flags_t flags)
 {
 	size_t pagesize = 1UL << shift;
-- 
2.35.3
