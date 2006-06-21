From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 21 Jun 2006 03:17:19 +0000
Subject: [RFC 2/2] init.c - use modified macros
Message-Id: <20060621031719.22750.17417.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove an un-needed extra definition of the PTE size

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 init.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

Index: linux-2.6.17/arch/ia64/mm/init.c
=================================--- linux-2.6.17.orig/arch/ia64/mm/init.c	2006-06-18 11:49:35.000000000 +1000
+++ linux-2.6.17/arch/ia64/mm/init.c	2006-06-21 11:08:08.000000000 +1000
@@ -366,17 +366,14 @@
 	 * problem in practice.  Alternatively, we could truncate the top of the mapped
 	 * address space to not permit mappings that would overlap with the VMLPT.
 	 * --davidm 00/12/06
-	 */
-#	define pte_bits			3
-#	define mapped_space_bits	(3*(PAGE_SHIFT - pte_bits) + PAGE_SHIFT)
-	/*
+	 *
 	 * The virtual page table has to cover the entire implemented address space within
 	 * a region even though not all of this space may be mappable.  The reason for
 	 * this is that the Access bit and Dirty bit fault handlers perform
 	 * non-speculative accesses to the virtual page table, so the address range of the
 	 * virtual page table itself needs to be covered by virtual page table.
 	 */
-#	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
+#	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + PTD_ENTRY_BITS)
 #	define POW2(n)			(1ULL << (n))
 
 	impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
@@ -389,8 +386,8 @@
 	 * the test makes sure that our mapped space doesn't overlap the
 	 * unimplemented hole in the middle of the region.
 	 */
-	if ((mapped_space_bits - PAGE_SHIFT > vmlpt_bits - pte_bits) ||
-	    (mapped_space_bits > impl_va_bits - 1))
+	if ((MAPPED_SPACE_BITS - PAGE_SHIFT > vmlpt_bits - PTD_ENTRY_BITS) ||
+	    (MAPPED_SPACE_BITS > impl_va_bits - 1))
 		panic("Cannot build a big enough virtual-linear page table"
 		      " to cover mapped address space.\n"
 		      " Try using a smaller page size.\n");
