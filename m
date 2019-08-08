From: Mike Rapoport <rppt@linux.ibm.com>
Date: Thu, 08 Aug 2019 07:52:05 +0000
Subject: [PATCH 0/3] mm: remove quicklist page table caches
Message-Id: <1565250728-21721-1-git-send-email-rppt@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Hi,

I while ago Nicholas proposed to remove quicklist page table caches [1].

I've rebased his patch on the curren upstream and switched ia64 and sh to
use generic versions of PTE allocation.

[1] https://lore.kernel.org/linux-mm/20190711030339.20892-1-npiggin@gmail.com

Mike Rapoport (2):
  ia64: switch to generic version of pte allocation
  sh: switch to generic version of pte allocation

Nicholas Piggin (1):
  mm: remove quicklist page table caches

 arch/alpha/include/asm/pgalloc.h      |   2 -
 arch/arc/include/asm/pgalloc.h        |   1 -
 arch/arm/include/asm/pgalloc.h        |   2 -
 arch/arm64/include/asm/pgalloc.h      |   2 -
 arch/csky/include/asm/pgalloc.h       |   2 -
 arch/hexagon/include/asm/pgalloc.h    |   2 -
 arch/ia64/Kconfig                     |   4 --
 arch/ia64/include/asm/pgalloc.h       |  52 +++--------------
 arch/m68k/include/asm/pgtable_mm.h    |   2 -
 arch/m68k/include/asm/pgtable_no.h    |   2 -
 arch/microblaze/include/asm/pgalloc.h |  89 +++--------------------------
 arch/microblaze/mm/pgtable.c          |   4 --
 arch/mips/include/asm/pgalloc.h       |   2 -
 arch/nds32/include/asm/pgalloc.h      |   2 -
 arch/nios2/include/asm/pgalloc.h      |   2 -
 arch/openrisc/include/asm/pgalloc.h   |   2 -
 arch/parisc/include/asm/pgalloc.h     |   2 -
 arch/powerpc/include/asm/pgalloc.h    |   2 -
 arch/riscv/include/asm/pgalloc.h      |   4 --
 arch/s390/include/asm/pgtable.h       |   1 -
 arch/sh/include/asm/pgalloc.h         |  44 +--------------
 arch/sh/mm/Kconfig                    |   3 -
 arch/sparc/include/asm/pgalloc_32.h   |   2 -
 arch/sparc/include/asm/pgalloc_64.h   |   2 -
 arch/sparc/mm/init_32.c               |   1 -
 arch/um/include/asm/pgalloc.h         |   2 -
 arch/unicore32/include/asm/pgalloc.h  |   2 -
 arch/x86/include/asm/pgtable_32.h     |   1 -
 arch/x86/include/asm/pgtable_64.h     |   1 -
 arch/xtensa/include/asm/tlbflush.h    |   3 -
 fs/proc/meminfo.c                     |   4 --
 include/asm-generic/pgalloc.h         |   5 --
 include/linux/quicklist.h             |  94 -------------------------------
 kernel/sched/idle.c                   |   1 -
 lib/show_mem.c                        |   5 --
 mm/Kconfig                            |   5 --
 mm/Makefile                           |   1 -
 mm/mmu_gather.c                       |   2 -
 mm/quicklist.c                        | 103 ----------------------------------
 39 files changed, 16 insertions(+), 446 deletions(-)
 delete mode 100644 include/linux/quicklist.h
 delete mode 100644 mm/quicklist.c

-- 
2.7.4
