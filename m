From: Jack Steiner <steiner@sgi.com>
Date: Sun, 02 May 2004 12:30:28 +0000
Subject: [PATCH] - deleting huge pages
Message-Id: <20040502123028.GA13812@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I found this problem in 2.4,21, but AFAICT, the same problem
exists in 2.6.5.

If you attempt to allocate a LOT more huge pages than are physically available,
the kernel may reference invalid PGDs or PMDs. 

Here is the 2.4 backtrace of a failure. If the mmap fails, do_mmap_pgoff attempts to
unmap the vma range it was mapping. Depending on where it failed during
the mmap, some of the higher level PGD/PMDs may not have been assigned.

The bug (at least in 2.4) exists on all platforms but on our platform
attempts to dereference NULL pointers usually cause MCAs. (If a platform
has zeros in page 0, you may be lucky & the code would appear to work,
but it is still a bug).

	Stack traceback for pid 6817
	0xe00025307ba50000     6817     6663  0  148   D  0xe00025307ba50420  toy
	0xe00000000445e180 unmap_hugepage_range+0x160  << mca surfaced here
	0xe00000000445e300 zap_hugepage_range+0x80
	0xe00000000452dbc0 do_mmap_pgoff+0xea0
	0xe000000004432910 sys_mmap+0x210
	0xe00000000440e2a0 ia64_ret_from_syscall

The MCA was caused by the NULL pmd dereference in huge_pte_offset. The
MCA doesnt surface until the bad data is consumed.

A patch against 2.6.5:



Index: linux/arch/ia64/mm/hugetlbpage.c
=================================--- linux.orig/arch/ia64/mm/hugetlbpage.c	2004-05-01 20:51:52.000000000 -0500
+++ linux/arch/ia64/mm/hugetlbpage.c	2004-05-01 20:51:54.000000000 -0500
@@ -111,9 +111,16 @@
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, taddr);
+	if (pgd_none(*pgd) || pgd_bad(*pgd))
+		goto out;
 	pmd = pmd_offset(pgd, taddr);
+	if (pmd_none(*pmd) || pmd_bad(*pmd))
+		goto out;
 	pte = pte_offset_map(pmd, taddr);
 	return pte;
+
+out:
+	return 0;
 }
 
 #define mk_pte_huge(entry) { pte_val(entry) |= _PAGE_P; }
@@ -331,7 +338,7 @@
 
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		pte = huge_pte_offset(mm, address);
-		if (pte_none(*pte))
+		if (!pte || pte_none(*pte))
 			continue;
 		page = pte_page(*pte);
 		huge_page_release(page);
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


