From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 07 Jul 2004 10:57:27 +0000
Subject: Re: Using GDB kills kernel
Message-Id: <16619.55063.4174.538889@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
In-Reply-To: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
>>>>> On Wed, 7 Jul 2004 11:03:08 +1000, Peter Chubb <peterc@gelato.unsw.edu.au> said:
Peter> I'm currently trying binary chop to see what change(s) caused
Peter> the problem.  But there were a lot of them in a very tangled
Peter> revision history, so progress is slow.

David> I'd guess that it may be another bug related to moving
David> "current" for init_task to region 5.  Though it's not apparent
David> how or why this would only bite you (so far).

Peter> The problem is changeset

Peter>   roland@redhat.com[torvalds]|ChangeSet|20040624165002|30880

Peter> which changes the way PTEs are looked up for the gate page.


OK, the problem arises when GDB tries to step over or access something
in the gate page.  The changeset mentioned above changes things so that
instead of doing
	pgd = pgd_offset_k(addr)
it does
	pgd = pgd_offset(mm, addr)
for a gate page address.

Here's a patch that makes pgd_offset work for gate page addresses.
I'm not entirely happy about adding work everywhere to satisfy one
fairly rare use of pgd_offset() to get a gate page address.
Is there a better solution?  The problematical change was to fix
X86_64 when ptracing 32-bit processes.


Index: linux-2.5-fixit/include/asm-ia64/pgtable.h
=================================--- linux-2.5-fixit.orig/include/asm-ia64/pgtable.h
+++ linux-2.5-fixit/include/asm-ia64/pgtable.h
@@ -308,18 +308,21 @@
 	return (region << (PAGE_SHIFT - 6)) | l1index;
 }
 
+/* In the kernel's mapped region we have a full 43 bit space available and completely
+   ignore the region number (since we know its in region number 5). */
+#define pgd_offset_k(addr) \
+	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
+
 /* The offset in the 1-level directory is given by the 3 region bits
    (61..63) and the seven level-1 bits (33-39).  */
 static inline pgd_t*
 pgd_offset (struct mm_struct *mm, unsigned long address)
 {
+	if ((address >> 61) = 5)
+		return pgd_offset_k(address);
 	return mm->pgd + pgd_index(address);
 }
 
-/* In the kernel's mapped region we have a full 43 bit space available and completely
-   ignore the region number (since we know its in region number 5). */
-#define pgd_offset_k(addr) \
-	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
 
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(dir,addr) \

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
