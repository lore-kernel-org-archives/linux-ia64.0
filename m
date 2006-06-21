From: Horms <horms@verge.net.au>
Date: Wed, 21 Jun 2006 08:05:35 +0000
Subject: Re: [RFC 2/2] init.c - use modified macros
Message-Id: <20060621080535.8270B3402E@koto.vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060621031719.22750.17417.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060621031719.22750.17417.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In article <20060621031719.22750.17417.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU> you wrote:
> Remove an un-needed extra definition of the PTE size

Here is a patch relative to yours that makes the surrounding comments
< 80 columns wide.

-- 
Horms                                           http://www.vergenet.net/~horms/

ia64, mm: Make VMLPT comment < 80 characters wide

Signed-off-by: Horms <horms@verge.net.au>
---
 arch/ia64/mm/init.c |   30 +++++++++++++++++-------------
 1 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index df46f15..2bfdaa0 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -340,22 +340,26 @@ static void ia64_initialize_pta(int vhpt
 	unsigned long pta, impl_va_bits;
 
 	/*
-	 * Check if the virtually mapped linear page table (VMLPT) overlaps with a mapped
-	 * address space.  The IA-64 architecture guarantees that at least 50 bits of
-	 * virtual address space are implemented but if we pick a large enough page size
-	 * (e.g., 64KB), the mapped address space is big enough that it will overlap with
-	 * VMLPT.  I assume that once we run on machines big enough to warrant 64KB pages,
-	 * IMPL_VA_MSB will be significantly bigger, so this is unlikely to become a
-	 * problem in practice.  Alternatively, we could truncate the top of the mapped
-	 * address space to not permit mappings that would overlap with the VMLPT.
+	 * Check if the virtually mapped linear page table (VMLPT) overlaps
+	 * with a mapped address space.  The IA-64 architecture guarantees
+	 * that at least 50 bits of virtual address space are implemented
+	 * but if we pick a large enough page size (e.g., 64KB), the mapped
+	 * address space is big enough that it will overlap with VMLPT.  I
+	 * assume that once we run on machines big enough to warrant 64KB
+	 * pages, IMPL_VA_MSB will be significantly bigger, so this is
+	 * unlikely to become a problem in practice.  Alternatively, we
+	 * could truncate the top of the mapped address space to not permit
+	 * mappings that would overlap with the VMLPT.
 	 * --davidm 00/12/06
 	 *
-	 * The virtual page table has to cover the entire implemented address space within
-	 * a region even though not all of this space may be mappable.  The reason for
-	 * this is that the Access bit and Dirty bit fault handlers perform
-	 * non-speculative accesses to the virtual page table, so the address range of the
-	 * virtual page table itself needs to be covered by virtual page table.
+	 * The virtual page table has to cover the entire implemented
+	 * address space within a region even though not all of this space
+	 * may be mappable.  The reason for this is that the Access bit and
+	 * Dirty bit fault handlers perform non-speculative accesses to the
+	 * virtual page table, so the address range of the virtual page
+	 * table itself needs to be covered by virtual page table.
 	 */
+
 #	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + PTD_ENTRY_BITS)
 #	define POW2(n)			(1ULL << (n))
 
-- 
1.4.0.gd281


