From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 Jul 2004 01:18:15 +0000
Subject: Re: Using GDB kills kernel
Message-Id: <16620.41175.419863.881926@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
In-Reply-To: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 7 Jul 2004 20:57:27 +1000, Peter Chubb <peterc@gelato.unsw.edu.au> said:

  Peter> OK, the problem arises when GDB tries to step over or access something
  Peter> in the gate page.  The changeset mentioned above changes things so that
  Peter> instead of doing
  Peter> pgd = pgd_offset_k(addr)
  Peter> it does
  Peter> pgd = pgd_offset(mm, addr)
  Peter> for a gate page address.

Yeah, that'd do it.

Does the attached patch work for you?

	--david

=== include/asm-generic/pgtable.h 1.6 vs edited ==--- 1.6/include/asm-generic/pgtable.h	Wed May 26 07:56:17 2004
+++ edited/include/asm-generic/pgtable.h	Wed Jul  7 18:02:20 2004
@@ -122,4 +122,8 @@
 #define page_test_and_clear_young(page) (0)
 #endif
 
+#ifndef __HAVE_ARCH_PGD_OFFSET_GATE
+#define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
=== include/asm-ia64/pgtable.h 1.43 vs edited ==--- 1.43/include/asm-ia64/pgtable.h	Sat Jun 19 07:48:59 2004
+++ edited/include/asm-ia64/pgtable.h	Wed Jul  7 18:03:55 2004
@@ -321,6 +321,11 @@
 #define pgd_offset_k(addr) \
 	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
 
+/* Look up a pgd entry in the gate area.  On IA-64, the gate-area
+   resides in the kernel-mapped segment, hence we use pgd_offset_k()
+   here.  */
+#define pgd_offset_gate(mm, addr)	pgd_offset_k(addr)
+
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(dir,addr) \
 	((pmd_t *) pgd_page(*(dir)) + (((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1)))
@@ -552,6 +557,7 @@
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTEP_MKDIRTY
 #define __HAVE_ARCH_PTE_SAME
+#define __HAVE_ARCH_PGD_OFFSET_GATE
 #include <asm-generic/pgtable.h>
 
 #endif /* _ASM_IA64_PGTABLE_H */
=== mm/memory.c 1.148 vs edited ==--- 1.148/mm/memory.c	Tue Jul  6 22:19:26 2004
+++ edited/mm/memory.c	Wed Jul  7 18:02:29 2004
@@ -727,7 +727,7 @@
 			pte_t *pte;
 			if (write) /* user gate pages are read-only */
 				return i ? : -EFAULT;
-			pgd = pgd_offset(mm, pg);
+			pgd = pgd_offset_gate(mm, pg);
 			if (!pgd)
 				return i ? : -EFAULT;
 			pmd = pmd_offset(pgd, pg);
