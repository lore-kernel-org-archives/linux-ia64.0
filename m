From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Date: Thu, 28 May 2015 11:52:32 +0000
Subject: [PATCH 0/5] Remove s390 sw-emulated hugepages and cleanup
Message-Id: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Hi everyone,

there is a potential bug with KVM and hugetlbfs if the hardware does not
support hugepages (EDAT1).
We fix this by making EDAT1 a hard requirement for hugepages and 
therefore removing and simplifying code.

As s390, with the sw-emulated hugepages, was the only user of arch_prepare/release_hugepage
I also removed theses calls from common and other architecture code.

Thanks,
    Dominik

Dominik Dingel (5):
  s390/mm: make hugepages_supported a boot time decision
  mm/hugetlb: remove unused arch hook prepare/release_hugepage
  mm/hugetlb: remove arch_prepare/release_hugepage from arch headers
  s390/hugetlb: remove dead code for sw emulated huge pages
  s390/mm: forward check for huge pmds to pmd_large()

 arch/arm/include/asm/hugetlb.h     |  9 ------
 arch/arm64/include/asm/hugetlb.h   |  9 ------
 arch/ia64/include/asm/hugetlb.h    |  9 ------
 arch/metag/include/asm/hugetlb.h   |  9 ------
 arch/mips/include/asm/hugetlb.h    |  9 ------
 arch/powerpc/include/asm/hugetlb.h |  9 ------
 arch/s390/include/asm/hugetlb.h    |  3 --
 arch/s390/include/asm/page.h       |  8 ++---
 arch/s390/kernel/setup.c           |  2 ++
 arch/s390/mm/hugetlbpage.c         | 65 +++-----------------------------------
 arch/s390/mm/pgtable.c             |  2 ++
 arch/sh/include/asm/hugetlb.h      |  9 ------
 arch/sparc/include/asm/hugetlb.h   |  9 ------
 arch/tile/include/asm/hugetlb.h    |  9 ------
 arch/x86/include/asm/hugetlb.h     |  9 ------
 mm/hugetlb.c                       | 10 ------
 16 files changed, 12 insertions(+), 168 deletions(-)

-- 
2.3.7

