From: Zi Yan <zi.yan@sent.com>
Date: Thu, 06 May 2021 15:26:23 +0000
Subject: [RFC PATCH 7/7] [not for merge] mm: increase SECTION_SIZE_BITS to 31
Message-Id: <20210506152623.178731-8-zi.yan@sent.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
In-Reply-To: <20210506152623.178731-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

This is only used to test onlining/offlining subsection memory in
a x86_64 system by increasing section size to 2GB and pageblock size to
1GB when MAX_ORDER is set to 20.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/Kconfig                 | 15 +++++++++++++++
 arch/x86/include/asm/sparsemem.h |  2 +-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0045e1b44190..d8faf59fa5ff 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1654,6 +1654,21 @@ config X86_PMEM_LEGACY
 
 	  Say Y if unsure.
 
+config FORCE_MAX_ZONEORDER
+	int "Maximum zone order"
+	range 11 20
+	default "20"
+	help
+	  The kernel memory allocator divides physically contiguous memory
+	  blocks into "zones", where each zone is a power of two number of
+	  pages.  This option selects the largest power of two that the kernel
+	  keeps in the memory allocator.  If you need to allocate very large
+	  blocks of physically contiguous memory, then you may need to
+	  increase this value.
+
+	  This config option is actually maximum order plus one. For example,
+	  a value of 11 means that the largest free memory block is 2^10 pages.
+
 config HIGHPTE
 	bool "Allocate 3rd-level pagetables from highmem"
 	depends on HIGHMEM
diff --git a/arch/x86/include/asm/sparsemem.h b/arch/x86/include/asm/sparsemem.h
index 6a9ccc1b2be5..c5a9d498a7e7 100644
--- a/arch/x86/include/asm/sparsemem.h
+++ b/arch/x86/include/asm/sparsemem.h
@@ -23,7 +23,7 @@
 #  define MAX_PHYSMEM_BITS	32
 # endif
 #else /* CONFIG_X86_32 */
-# define SECTION_SIZE_BITS	27 /* matt - 128 is convenient right now */
+# define SECTION_SIZE_BITS	31 /* matt - 128 is convenient right now */
 # define MAX_PHYSMEM_BITS	(pgtable_l5_enabled() ? 52 : 46)
 #endif
 
-- 
2.30.2
