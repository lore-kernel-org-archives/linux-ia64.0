From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Tue, 10 May 2022 03:45:57 +0000
Subject: [PATCH v3 0/3] Fix CONT-PTE/PMD size hugetlb issue when unmapping or migrating
Message-Id: <cover.1652147571.git.baolin.wang@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, mike.kravetz@oracle.com, catalin.marinas@arm.com, will@kernel.org
Cc: songmuchun@bytedance.com, tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, baolin.wang@linux.alibaba.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Hi,

Now migrating a hugetlb page or unmapping a poisoned hugetlb page, we'll
use ptep_clear_flush() and set_pte_at() to nuke the page table entry
and remap it, and this is incorrect for CONT-PTE or CONT-PMD size hugetlb
page, which will cause potential data consistent issue. This patch set
will change to use hugetlb related APIs to fix this issue, please find
details in each patch. Thanks.

Note: Mike pointed out the huge_ptep_get() will only return the one specific
value, and it would not take into account the dirty or young bits of CONT-PTE/PMDs
like the huge_ptep_get_and_clear() [1]. This inconsistent issue is not introduced
by this patch set, and will address this issue in another thread [2]. Meanwhile
the uffd for hugetlb case [3] pointed by Gerald also need another patch to address.

[1] https://lore.kernel.org/linux-mm/85bd80b4-b4fd-0d3f-a2e5-149559f2f387@oracle.com/
[2] https://lore.kernel.org/all/cover.1651998586.git.baolin.wang@linux.alibaba.com/
[3] https://lore.kernel.org/linux-mm/20220503120343.6264e126@thinkpad/

Changes from v2:
 - Collect reviewed tags from Muchun and Mike.
 - Drop the unnecessary casting in hugetlb.c.
 - Fix building errors with adding dummy functions for !CONFIG_HUGETLB_PAGE.

Changes from v1:
 - Add acked tag from Mike.
 - Update some commit message.
 - Add VM_BUG_ON in try_to_unmap() for hugetlb case.
 - Add an explict void casting for huge_ptep_clear_flush() in hugetlb.c.

Baolin Wang (3):
  mm: change huge_ptep_clear_flush() to return the original pte
  mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when migration
  mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when unmapping

 arch/arm64/include/asm/hugetlb.h   |  4 +--
 arch/arm64/mm/hugetlbpage.c        | 12 +++-----
 arch/ia64/include/asm/hugetlb.h    |  4 +--
 arch/mips/include/asm/hugetlb.h    |  9 ++++--
 arch/parisc/include/asm/hugetlb.h  |  4 +--
 arch/powerpc/include/asm/hugetlb.h |  9 ++++--
 arch/s390/include/asm/hugetlb.h    |  6 ++--
 arch/sh/include/asm/hugetlb.h      |  4 +--
 arch/sparc/include/asm/hugetlb.h   |  4 +--
 include/asm-generic/hugetlb.h      |  4 +--
 include/linux/hugetlb.h            | 11 +++++++
 mm/rmap.c                          | 63 ++++++++++++++++++++++++--------------
 12 files changed, 83 insertions(+), 51 deletions(-)

-- 
1.8.3.1
