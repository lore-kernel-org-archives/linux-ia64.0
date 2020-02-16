From: Mike Rapoport <rppt@kernel.org>
Date: Sun, 16 Feb 2020 08:18:30 +0000
Subject: [PATCH v2 00/13] mm: remove __ARCH_HAS_5LEVEL_HACK
Message-Id: <20200216081843.28670-1-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, linux-hexagon@vger.kernel.org, Will Deacon <will@kernel.org>, kvmarm@lists.cs.columbia.edu, Jonas Bonn <jonas@southpole.se>, linux-arch@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, Marc Zyngier <maz@kernel.org>, Russell King <linux@armlinux.org.uk>, Ley Foon Tan <ley.foon.tan@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, kvm-ppc@vger.kernel.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, nios2-dev@lists.rocketboards.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mike Rapoport <rppt@kernel.org>

From: Mike Rapoport <rppt@linux.ibm.com>

Hi,

These patches convert several architectures to use page table folding and
remove __ARCH_HAS_5LEVEL_HACK along with include/asm-generic/5level-fixup.h.

The changes are mostly about mechanical replacement of pgd accessors with p4d
ones and the addition of higher levels to page table traversals.

All the patches were sent separately to the respective arch lists and
maintainers hence the "v2" prefix.

Geert Uytterhoeven (1):
  sh: fault: Modernize printing of kernel messages

Mike Rapoport (12):
  arm/arm64: add support for folded p4d page tables
  h8300: remove usage of __ARCH_USE_5LEVEL_HACK
  hexagon: remove __ARCH_USE_5LEVEL_HACK
  ia64: add support for folded p4d page tables
  nios2: add support for folded p4d page tables
  openrisc: add support for folded p4d page tables
  powerpc: add support for folded p4d page tables
  sh: drop __pXd_offset() macros that duplicate pXd_index() ones
  sh: add support for folded p4d page tables
  unicore32: remove __ARCH_USE_5LEVEL_HACK
  asm-generic: remove pgtable-nop4d-hack.h
  mm: remove __ARCH_HAS_5LEVEL_HACK and include/asm-generic/5level-fixup.h

 arch/arm/include/asm/kvm_mmu.h                |   5 +-
 arch/arm/include/asm/pgtable.h                |   1 -
 arch/arm/include/asm/stage2_pgtable.h         |  15 +-
 arch/arm/lib/uaccess_with_memcpy.c            |   9 +-
 arch/arm/mach-sa1100/assabet.c                |   2 +-
 arch/arm/mm/dump.c                            |  29 ++-
 arch/arm/mm/fault-armv.c                      |   7 +-
 arch/arm/mm/fault.c                           |  28 ++-
 arch/arm/mm/idmap.c                           |   3 +-
 arch/arm/mm/init.c                            |   2 +-
 arch/arm/mm/ioremap.c                         |  12 +-
 arch/arm/mm/mm.h                              |   2 +-
 arch/arm/mm/mmu.c                             |  35 ++-
 arch/arm/mm/pgd.c                             |  40 +++-
 arch/arm64/include/asm/kvm_mmu.h              |  10 +-
 arch/arm64/include/asm/pgalloc.h              |  10 +-
 arch/arm64/include/asm/pgtable-types.h        |   5 +-
 arch/arm64/include/asm/pgtable.h              |  37 ++--
 arch/arm64/include/asm/stage2_pgtable.h       |  48 +++-
 arch/arm64/kernel/hibernate.c                 |  44 +++-
 arch/arm64/mm/fault.c                         |   9 +-
 arch/arm64/mm/hugetlbpage.c                   |  15 +-
 arch/arm64/mm/kasan_init.c                    |  26 ++-
 arch/arm64/mm/mmu.c                           |  52 +++--
 arch/arm64/mm/pageattr.c                      |   7 +-
 arch/h8300/include/asm/pgtable.h              |   1 -
 arch/hexagon/include/asm/fixmap.h             |   4 +-
 arch/hexagon/include/asm/pgtable.h            |   1 -
 arch/ia64/include/asm/pgalloc.h               |   4 +-
 arch/ia64/include/asm/pgtable.h               |  17 +-
 arch/ia64/mm/fault.c                          |   7 +-
 arch/ia64/mm/hugetlbpage.c                    |  18 +-
 arch/ia64/mm/init.c                           |  28 ++-
 arch/nios2/include/asm/pgtable.h              |   3 +-
 arch/nios2/mm/fault.c                         |   9 +-
 arch/nios2/mm/ioremap.c                       |   6 +-
 arch/openrisc/include/asm/pgtable.h           |   1 -
 arch/openrisc/mm/fault.c                      |  10 +-
 arch/openrisc/mm/init.c                       |   4 +-
 arch/powerpc/include/asm/book3s/32/pgtable.h  |   1 -
 arch/powerpc/include/asm/book3s/64/hash.h     |   4 +-
 arch/powerpc/include/asm/book3s/64/pgalloc.h  |   4 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h  |  58 +++--
 arch/powerpc/include/asm/book3s/64/radix.h    |   6 +-
 arch/powerpc/include/asm/nohash/32/pgtable.h  |   1 -
 arch/powerpc/include/asm/nohash/64/pgalloc.h  |   2 +-
 .../include/asm/nohash/64/pgtable-4k.h        |  32 +--
 arch/powerpc/include/asm/nohash/64/pgtable.h  |   6 +-
 arch/powerpc/include/asm/pgtable.h            |   8 +
 arch/powerpc/kvm/book3s_64_mmu_radix.c        |  59 ++++-
 arch/powerpc/lib/code-patching.c              |   7 +-
 arch/powerpc/mm/book3s32/mmu.c                |   2 +-
 arch/powerpc/mm/book3s32/tlb.c                |   4 +-
 arch/powerpc/mm/book3s64/hash_pgtable.c       |   4 +-
 arch/powerpc/mm/book3s64/radix_pgtable.c      |  19 +-
 arch/powerpc/mm/book3s64/subpage_prot.c       |   6 +-
 arch/powerpc/mm/hugetlbpage.c                 |  28 ++-
 arch/powerpc/mm/kasan/kasan_init_32.c         |   8 +-
 arch/powerpc/mm/mem.c                         |   4 +-
 arch/powerpc/mm/nohash/40x.c                  |   4 +-
 arch/powerpc/mm/nohash/book3e_pgtable.c       |  15 +-
 arch/powerpc/mm/pgtable.c                     |  25 ++-
 arch/powerpc/mm/pgtable_32.c                  |  28 ++-
 arch/powerpc/mm/pgtable_64.c                  |  10 +-
 arch/powerpc/mm/ptdump/hashpagetable.c        |  20 +-
 arch/powerpc/mm/ptdump/ptdump.c               |  22 +-
 arch/powerpc/xmon/xmon.c                      |  17 +-
 arch/sh/include/asm/pgtable-2level.h          |   1 -
 arch/sh/include/asm/pgtable-3level.h          |   1 -
 arch/sh/include/asm/pgtable_32.h              |   5 +-
 arch/sh/include/asm/pgtable_64.h              |   5 +-
 arch/sh/kernel/io_trapped.c                   |   7 +-
 arch/sh/mm/cache-sh4.c                        |   4 +-
 arch/sh/mm/cache-sh5.c                        |   7 +-
 arch/sh/mm/fault.c                            |  65 ++++--
 arch/sh/mm/hugetlbpage.c                      |  28 ++-
 arch/sh/mm/init.c                             |  15 +-
 arch/sh/mm/kmap.c                             |   2 +-
 arch/sh/mm/tlbex_32.c                         |   6 +-
 arch/sh/mm/tlbex_64.c                         |   7 +-
 arch/unicore32/include/asm/pgtable.h          |   1 -
 arch/unicore32/kernel/hibernate.c             |   4 +-
 include/asm-generic/5level-fixup.h            |  58 -----
 include/asm-generic/pgtable-nop4d-hack.h      |  64 ------
 include/asm-generic/pgtable-nopud.h           |   4 -
 include/linux/mm.h                            |   6 -
 mm/kasan/init.c                               |  11 -
 mm/memory.c                                   |   8 -
 virt/kvm/arm/mmu.c                            | 209 +++++++++++++++---
 89 files changed, 988 insertions(+), 500 deletions(-)
 delete mode 100644 include/asm-generic/5level-fixup.h
 delete mode 100644 include/asm-generic/pgtable-nop4d-hack.h

-- 
2.24.0
