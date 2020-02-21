From: Logan Gunthorpe <logang@deltatee.com>
Date: Fri, 21 Feb 2020 18:24:56 +0000
Subject: [PATCH v3 0/7] Allow setting caching mode in arch_add_memory() for P2PDMA
Message-Id: <20200221182503.28317-1-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Badger <ebadger@gigaio.com>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>

Hi,

This is v3 of the patchset which cleans up a number of minor issues
from the feedback of v2 and rebases onto v5.6-rc2. Additional feedback
is welcome.

Thanks,

Logan

--

Changes in v3:
 * Rebased onto v5.6-rc2
 * Rename mhp_modifiers to mhp_params per David with an updated kernel
   doc per Dan
 * Drop support for s390 per David seeing it does not support
   ZONE_DEVICE yet and there was a potential problem with huge pages.
 * Added WARN_ON_ONCE in cases where arches recieve non PAGE_KERNEL
   parameters
 * Collected David and Micheal's Reviewed-By and Acked-by Tags

Changes in v2:
 * Rebased onto v5.5-rc5
 * Renamed mhp_restrictions to mhp_modifiers and added the pgprot field
   to that structure instead of using an argument for
   arch_add_memory().
 * Add patch to drop the unused flags field in mhp_restrictions

A git branch is available here:

https://github.com/sbates130272/linux-p2pmem remap_pages_cache_v3

--

Currently, the page tables created using memremap_pages() are always
created with the PAGE_KERNEL cacheing mode. However, the P2PDMA code
is creating pages for PCI BAR memory which should never be accessed
through the cache and instead use either WC or UC. This still works in
most cases, on x86, because the MTRR registers typically override the
caching settings in the page tables for all of the IO memory to be
UC-. However, this tends not to work so well on other arches or
some rare x86 machines that have firmware which does not setup the
MTRR registers in this way.

Instead of this, this series proposes a change to arch_add_memory()
to take the pgprot required by the mapping which allows us to
explicitly set pagetable entries for P2PDMA memory to WC.

This changes is pretty routine for most of the arches: x86_64, s390, arm64
and powerpc simply need to thread the pgprot through to where the page
tables are setup. x86_32 unfortunately sets up the page tables at boot so
must use _set_memory_prot() to change their caching mode. ia64 and sh
don't appear to have an easy way to change the page tables so, for now
at least, we just return -EINVAL on such mappings and thus they will
not support P2PDMA memory until the work for this is done.

--

Logan Gunthorpe (7):
  mm/memory_hotplug: Drop the flags field from struct mhp_restrictions
  mm/memory_hotplug: Rename mhp_restrictions to mhp_params
  x86/mm: Thread pgprot_t through init_memory_mapping()
  x86/mm: Introduce _set_memory_prot()
  powerpc/mm: Thread pgprot_t through create_section_mapping()
  mm/memory_hotplug: Add pgprot_t to mhp_params
  mm/memremap: Set caching mode for PCI P2PDMA memory to WC

 arch/arm64/mm/mmu.c                        |  7 ++--
 arch/ia64/mm/init.c                        |  7 ++--
 arch/powerpc/include/asm/book3s/64/hash.h  |  3 +-
 arch/powerpc/include/asm/book3s/64/radix.h |  3 +-
 arch/powerpc/include/asm/sparsemem.h       |  3 +-
 arch/powerpc/mm/book3s64/hash_utils.c      |  5 +--
 arch/powerpc/mm/book3s64/pgtable.c         |  7 ++--
 arch/powerpc/mm/book3s64/radix_pgtable.c   | 18 ++++++----
 arch/powerpc/mm/mem.c                      | 10 +++---
 arch/s390/mm/init.c                        |  9 +++--
 arch/sh/mm/init.c                          |  7 ++--
 arch/x86/include/asm/page_types.h          |  3 --
 arch/x86/include/asm/pgtable.h             |  3 ++
 arch/x86/include/asm/set_memory.h          |  1 +
 arch/x86/kernel/amd_gart_64.c              |  3 +-
 arch/x86/mm/init.c                         |  9 ++---
 arch/x86/mm/init_32.c                      | 12 +++++--
 arch/x86/mm/init_64.c                      | 40 ++++++++++++----------
 arch/x86/mm/mm_internal.h                  |  3 +-
 arch/x86/mm/pat/set_memory.c               |  7 ++++
 arch/x86/platform/uv/bios_uv.c             |  3 +-
 include/linux/memory_hotplug.h             | 20 +++++------
 mm/memory_hotplug.c                        | 11 +++---
 mm/memremap.c                              | 17 +++++----
 24 files changed, 130 insertions(+), 81 deletions(-)


base-commit: 11a48a5a18c63fd7621bb050228cebf13566e4d8
--
2.20.1
