From: Zi Yan <zi.yan@sent.com>
Date: Thu, 06 May 2021 15:26:16 +0000
Subject: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <20210506152623.178731-1-zi.yan@sent.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

Hi all,

This patchset tries to remove the restriction on memory hotplug/hotremove
granularity, which is always greater or equal to memory section size[1].
With the patchset, kernel is able to online/offline memory at a size independent
of memory section size, as small as 2MB (the subsection size).

The motivation is to increase MAX_ORDER of the buddy allocator and pageblock
size without increasing memory hotplug/hotremove granularity at the same time,
so that the kernel can allocator 1GB pages using buddy allocator and utilizes
existing pageblock based anti-fragmentation, paving the road for 1GB THP
support[2].

The patchset utilizes the existing subsection support[3] and changes the
section size alignment checks to subsection size alignment checks. There are
also changes to pageblock code to support partial pageblocks, when pageblock
size is increased along with MAX_ORDER. Increasing pageblock size can enable
kernel to utilize existing anti-fragmentation mechanism for gigantic page
allocations.

The last patch increases SECTION_SIZE_BITS to demonstrate the use of memory
hotplug/hotremove subsection, but is not intended to be merged as is. It is
there in case one wants to try this out and will be removed during the final
submission.

Feel free to give suggestions and comments. I am looking forward to your
feedback.

Thanks.

Zi Yan (7):
  mm: sparse: set/clear subsection bitmap when pages are
    onlined/offlined.
  mm: set pageblock_order to the max of HUGETLB_PAGE_ORDER and
    MAX_ORDER-1
  mm: memory_hotplug: decouple memory_block size with section size.
  mm: pageblock: allow set/unset migratetype for partial pageblock
  mm: memory_hotplug, sparse: enable memory hotplug/hotremove
    subsections
  arch: x86: no MAX_ORDER exceeds SECTION_SIZE check for 32bit vdso.
  [not for merge] mm: increase SECTION_SIZE_BITS to 31

 arch/ia64/Kconfig                |   1 -
 arch/powerpc/Kconfig             |   1 -
 arch/x86/Kconfig                 |  15 +++
 arch/x86/entry/vdso/Makefile     |   1 +
 arch/x86/include/asm/sparsemem.h |   2 +-
 drivers/base/memory.c            | 176 +++++++++++++++----------------
 drivers/base/node.c              |   2 +-
 include/linux/memory.h           |   8 +-
 include/linux/mmzone.h           |   2 +
 include/linux/page-isolation.h   |   8 +-
 include/linux/pageblock-flags.h  |   9 --
 mm/Kconfig                       |   7 --
 mm/memory_hotplug.c              |  22 ++--
 mm/page_alloc.c                  |  40 ++++---
 mm/page_isolation.c              |  30 +++---
 mm/sparse.c                      |  55 ++++++++--
 16 files changed, 219 insertions(+), 160 deletions(-)

-- 
2.30.2
