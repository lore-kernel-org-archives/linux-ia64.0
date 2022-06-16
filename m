From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Thu, 16 Jun 2022 21:05:14 +0000
Subject: [PATCH 0/4] hugetlb: speed up linear address scanning
Message-Id: <20220616210518.125287-1-mike.kravetz@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: Muchun Song <songmuchun@bytedance.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Peter Xu <peterx@redhat.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, James Houghton <jthoughton@google.com>, Mina Almasry <almasrymina@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, catalin.marinas@arm.com, will@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

At unmap, fork and remap time hugetlb address ranges are linearly
scanned.  We can optimize these scans if the ranges are sparsely
populated.

Also, enable page table "Lazy copy" for hugetlb at fork.

NOTE: Architectures not defining CONFIG_ARCH_WANT_GENERAL_HUGETLB
need to add an arch specific version hugetlb_mask_last_page() to
take advantage of sparse address scanning improvements.  Baolin Wang
added the routine for arm64.  Other architectures which could be
optimized are: ia64, mips, parisc, powerpc, s390, sh and sparc.

Baolin Wang (1):
  arm64/hugetlb: Implement arm64 specific hugetlb_mask_last_page

Mike Kravetz (3):
  hugetlb: skip to end of PT page mapping when pte not present
  hugetlb: do not update address in huge_pmd_unshare
  hugetlb: Lazy page table copies in fork()

 arch/arm64/mm/hugetlbpage.c |  20 +++++++
 include/linux/hugetlb.h     |   5 +-
 mm/hugetlb.c                | 109 +++++++++++++++++++++++++-----------
 mm/memory.c                 |   2 +-
 mm/rmap.c                   |   4 +-
 5 files changed, 103 insertions(+), 37 deletions(-)

-- 
2.35.3
