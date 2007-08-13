From: Andrew Burgess <andrew@transitive.com>
Date: Mon, 13 Aug 2007 13:23:50 +0000
Subject: [PATCH] Failure to grow RBS
Message-Id: <20070813132350.GC14980@transitive.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I recently uncovered a bug in the ia64_do_page_fault code that can
cause a failure to grow the register backing store, or any mapping
that is marked as VM_GROWSUP if the mapping is the highest mapped area
of memory.

The problem was revealed when I switched to a RedHat 5 system that
turns on some of the address space randomisation features, this can
cause the user stack and the register backing store to be laid out in
a different order in memory, this caused the register backing store to
fail to grow correctly.

In detail, the problem is caused by the use of find_vma_prev. When an
access is made outside of any mapped page a call to find_vma_prev is
used to find the mapping above and below the address accessed, this
information is then used to work out if one of these regions needs to
grow to cover the address accessed.

When the address accessed is below the first mapping the previous
mapping is returned as NULL, and this case is handled.
However, when the address accessed is above the highest mapping the
vma returned is NULL, this case is not handled correctly, and it fails
to spot that this access might require an existing mapping to grow
upwards.

The patch included should apply to a 2.6.22 kernel.




--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="growup.patch"

diff -urp linux-2.6.18/arch/ia64/mm/fault.c linux-2.6.18/arch/ia64/mm/fault.c
--- linux-2.6.18/arch/ia64/mm/fault.c	2006-09-20 04:42:06.000000000 +0100
+++ linux-2.6.18/arch/ia64/mm/fault.c	2007-08-07 08:18:11.000000000 +0100
@@ -125,11 +125,17 @@ ia64_do_page_fault (unsigned long addres
 	down_read(&mm->mmap_sem);
 
 	vma = find_vma_prev(mm, address, &prev_vma);
-	if (!vma)
+	if (!vma && !prev_vma )
 		goto bad_area;
 
-	/* find_vma_prev() returns vma such that address < vma->vm_end or NULL */
-	if (address < vma->vm_start)
+        /*
+         * find_vma_prev() returns vma such that address < vma->vm_end or NULL
+         *
+         * May find no vma, but could be that the last vm area is the
+         * register backing store that needs to expand upwards, in
+         * this case vma will be null, but prev_vma will ne non-null
+         */
+        if (( !vma && prev_vma ) || (address < vma->vm_start) )
 		goto check_expansion;
 
   good_area:
@@ -184,6 +190,8 @@ ia64_do_page_fault (unsigned long addres
 
   check_expansion:
 	if (!(prev_vma && (prev_vma->vm_flags & VM_GROWSUP) && (address == prev_vma->vm_end))) {
+		if (!vma)
+			goto bad_area;
 		if (!(vma->vm_flags & VM_GROWSDOWN))
 			goto bad_area;
 		if (REGION_NUMBER(address) != REGION_NUMBER(vma->vm_start)

--J2SCkAp4GZ/dPZZf--
