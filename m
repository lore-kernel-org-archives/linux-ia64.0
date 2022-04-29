From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Fri, 29 Apr 2022 08:14:40 +0000
Subject: [PATCH 0/3] Fix CONT-PTE/PMD size hugetlb issue when unmapping or migrating
Message-Id: <cover.1651216964.git.baolin.wang@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, mike.kravetz@oracle.com, catalin.marinas@arm.com, will@kernel.org
Cc: tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, baolin.wang@linux.alibaba.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Hi,

Now migrating a hugetlb page or unmapping a poisoned hugetlb page, we'll
use ptep_clear_flush() and set_pte_at() to nuke the page table entry
and remap it, and this is incorrect for CONT-PTE or CONT-PMD size hugetlb
page, which will cause potential data consistent issue. This patch set
will change to use hugetlb related APIs to fix this issue, please find
details in each patch. Thanks.

Baolin Wang (3):
  mm: change huge_ptep_clear_flush() to return the original pte
  mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when migration
  mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when unmapping

 arch/arm64/include/asm/hugetlb.h   |  4 +--
 arch/arm64/mm/hugetlbpage.c        | 12 ++++----
 arch/ia64/include/asm/hugetlb.h    |  4 +--
 arch/mips/include/asm/hugetlb.h    |  9 ++++--
 arch/parisc/include/asm/hugetlb.h  |  4 +--
 arch/powerpc/include/asm/hugetlb.h |  9 ++++--
 arch/s390/include/asm/hugetlb.h    |  6 ++--
 arch/sh/include/asm/hugetlb.h      |  4 +--
 arch/sparc/include/asm/hugetlb.h   |  4 +--
 include/asm-generic/hugetlb.h      |  4 +--
 mm/rmap.c                          | 58 +++++++++++++++++++++++---------------
 11 files changed, 67 insertions(+), 51 deletions(-)

-- 
1.8.3.1
