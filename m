From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Thu, 16 Jun 2022 21:05:18 +0000
Subject: [PATCH 4/4] hugetlb: Lazy page table copies in fork()
Message-Id: <20220616210518.125287-5-mike.kravetz@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220616210518.125287-1-mike.kravetz@oracle.com>
In-Reply-To: <20220616210518.125287-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: Muchun Song <songmuchun@bytedance.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Peter Xu <peterx@redhat.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, James Houghton <jthoughton@google.com>, Mina Almasry <almasrymina@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, catalin.marinas@arm.com, will@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, David Hildenbrand <david@redhat.com>

Lazy page table copying at fork time was introduced with commit
commit d992895ba2b2 ("[PATCH] Lazy page table copies in fork()").
At the time, hugetlb was very new and did not support page faulting.
As a result, it was excluded.  When full page fault support was added
for hugetlb, the exclusion was not removed.

Simply remove the check that prevents lazy copying of hugetlb page
tables at fork.  Of course, like other mappings this only applies to
shared mappings.

Lazy page table copying at fork will be less advantageous for hugetlb
mappings because:
- There are fewer page table entries with hugetlb
- hugetlb pmds can be shared instead of copied

In any case, completely eliminating the copy at fork time should speed
things up.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Acked-by: Muchun Song <songmuchun@bytedance.com>
Acked-by: David Hildenbrand <david@redhat.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index fee2884481f2..90d2a614b2de 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1262,7 +1262,7 @@ vma_needs_copy(struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma)
 	if (userfaultfd_wp(dst_vma))
 		return true;
 
-	if (src_vma->vm_flags & (VM_HUGETLB | VM_PFNMAP | VM_MIXEDMAP))
+	if (src_vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
 		return true;
 
 	if (src_vma->anon_vma)
-- 
2.35.3
