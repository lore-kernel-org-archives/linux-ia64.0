From: Jack Steiner <steiner@sgi.com>
Date: Fri, 16 Jan 2004 20:47:47 +0000
Subject: [PATCH] - Align RSE save area
Message-Id: <20040116204747.GA19034@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Due to a bug in ia64_set_rbs_bot(), the VMA that is created for the RSE
save area is not page aligned. The following shows the vma's of a
process with a bad alignment for the  RSE area (pagesize is 0x4000):

	vm_start            vm_end              vm_flags
	0x0000000000000000  0x0000000000004000  READ MAYREAD IO
>>>>	0x600007ffffffe000  0x6000080000002000  READ WRITE MAYREAD MAYWRITE GROWSUP
	0x60000ffffff58000  0x60000fffffffc000  READ WRITE MAYREAD MAYWRITE MAYEXEC GROWSDOWN

This is not expected nor correctly handled by the VM code.


When a process that has an unaligned VMA exits, the teardown of the process
address space fails. The result is that a pte may be left in a pagetable page
when the pagetable page is freed. Pagetable pages are assumed to be all zeros
and are cached in a quicklist for subsequent reuse. Pagetable pages
that are allocated from this quicklist not zeroed out on reuse (they are *suppose*
to be zero).

The process that reuses the pagetable page will "inherit" the stale pages left
over from the previous process that used the pagetable page. This was causing 
really weird failures.



Here is a proposed fix:


--- linux.base/arch/ia64/mm/init.c	Fri Jan  9 00:59:26 2004
+++ linux/arch/ia64/mm/init.c	Fri Jan 16 14:40:14 2004
@@ -98,7 +98,7 @@
 
 	if (stack_size > MAX_USER_STACK_SIZE)
 		stack_size = MAX_USER_STACK_SIZE;
-	current->thread.rbs_bot = STACK_TOP - stack_size;
+	current->thread.rbs_bot = PAGE_ALIGN(STACK_TOP - stack_size);
 }
 
 /*



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


