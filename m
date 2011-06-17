From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 17 Jun 2011 08:38:25 +0000
Subject: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary physical addresses
Message-Id: <201106171038.25988.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

This patch series enhances /dev/mem, so that read and write is possible
at any address. The patchset includes actual implementation for x86.

Petr Tesarik (10):
  Return EOF on out-of-bounds read from /dev/mem
  (un)xlate_dev_mem_ptr: use phys_addr_t for the @phys parameter
  x86: translate highmem /dev/mem pointers
  ia64: change xlate_dev_mem_ptr's argument to phys_addr_t
  valid_phys_addr_range: use phys_addr_t for the @addr parameter
  sh: change valid_phys_addr_range's @addr param to phys_addr_t
  arm: change valid_phys_addr_range's @addr param to phys_addr_t
  ia64: change valid_phys_addr_range's @addr param to phys_addr_t
  x86: provide arch-specific valid_phys_addr_range()
  Allow reading/writing all memory through /dev/mem

 arch/arm/include/asm/io.h       |    2 +-
 arch/arm/mm/mmap.c              |    2 +-
 arch/ia64/include/asm/io.h      |    2 +-
 arch/ia64/include/asm/uaccess.h |    2 +-
 arch/ia64/kernel/efi.c          |    2 +-
 arch/sh/include/asm/io.h        |    2 +-
 arch/sh/mm/mmap.c               |    2 +-
 arch/x86/include/asm/io.h       |   15 +++++++++++++--
 arch/x86/mm/ioremap.c           |   24 ++++++++++++++++++------
 drivers/char/mem.c              |   14 ++++++++++----
 10 files changed, 48 insertions(+), 19 deletions(-)

-- 
1.7.3.4

