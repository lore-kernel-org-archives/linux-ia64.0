From: William Taber <wtaber@rational.com>
Date: Wed, 17 Jan 2001 18:12:41 +0000
Subject: [Linux-ia64] PATCH:  Building on ia32
Message-Id: <marc-linux-ia64-105590693005061@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I downloaded Linux 2.4.0 and applied the linux-2.4.0-ia64-010109.diff
patch, I discovered that I could no longer compile ia32 kernels.  It turned
out that there were reletively few changes needed to get the ia32 kernel to
compile cleanly and come up and run. As I promised yesterday, here are the
patches I needed to make.  This may not be exhaustive, since I do not have
all options turned on and I didn't try to build many drivers. Note that this
patch will remove the buggy code that I reported yesterday, rather than 
just conditionalizing it.  Since the code was broken and would not run
properly, as well as being non-portable, I just took it out pending a fix.
In the interest of getting the latest ia64 changes ready for merging into the
the main 2.4.x tree at some point, here are the diffs. 

Enjoy.

Will Taber

diff -Nur linux-2.4.0-base/drivers/char/mem.c linux-2.4.0/drivers/char/mem.c
--- linux-2.4.0-base/drivers/char/mem.c	Mon Jan 15 10:40:33 2001
+++ linux-2.4.0/drivers/char/mem.c	Mon Jan 15 16:17:14 2001
@@ -205,8 +205,10 @@
 	    || vma->vm_flags & VM_NONCACHED)
 		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
+#if defined(__ia64__)
 	if (vma->vm_flags & VM_WRITECOMBINED)
 		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
+#endif
 
 	/* Don't try to swap out physical pages.. */
 	vma->vm_flags |= VM_RESERVED;
diff -Nur linux-2.4.0-base/fs/fcntl.c linux-2.4.0/fs/fcntl.c
--- linux-2.4.0-base/fs/fcntl.c	Mon Jan 15 10:40:34 2001
+++ linux-2.4.0/fs/fcntl.c	Tue Jan 16 14:07:39 2001
@@ -269,7 +269,9 @@
 			 * to fix this will be in libc.
 			 */
 			err = filp->f_owner.pid;
+#if (__ia64__)
 			force_successful_syscall_return();
+#endif
 			break;
 		case F_SETOWN:
 			lock_kernel();
diff -Nur linux-2.4.0-base/include/asm-ia64/irq.h 
linux-2.4.0/include/asm-ia64/irq.h
--- linux-2.4.0-base/include/asm-ia64/irq.h	Fri Mar 10 18:24:02 2000
+++ linux-2.4.0/include/asm-ia64/irq.h	Tue Jan 16 10:46:28 2001
@@ -27,5 +27,8 @@
 extern void disable_irq (unsigned int);
 extern void disable_irq_nosync (unsigned int);
 extern void enable_irq (unsigned int);
+extern unsigned int do_IRQ (unsigned long irq, struct pt_regs *regs);
+extern void do_IRQ_per_cpu (unsigned long irq, struct pt_regs *regs);
+
 
 #endif /* _ASM_IA64_IRQ_H */
diff -Nur linux-2.4.0-base/include/asm-ia64/pgalloc.h 
linux-2.4.0/include/asm-ia64/pgalloc.h
--- linux-2.4.0-base/include/asm-ia64/pgalloc.h	Thu Jan  4 15:50:18 2001
+++ linux-2.4.0/include/asm-ia64/pgalloc.h	Mon Jan 15 14:38:09 2001
@@ -281,14 +281,14 @@
 }
 
 static inline void
-clear_user_page (void *addr, unsigned long vaddr, struct page *page)
+clear_user_page (void *addr, struct page *page)
 {
 	clear_page(addr);
 	flush_dcache_page(page);
 }
 
 static inline void
-copy_user_page (void *to, void *from, unsigned long vaddr, struct page *page)
+copy_user_page (void *to, void *from, struct page *page)
 {
 	copy_page(to, from);
 	flush_dcache_page(page);
diff -Nur linux-2.4.0-base/include/linux/highmem.h 
linux-2.4.0/include/linux/highmem.h
--- linux-2.4.0-base/include/linux/highmem.h	Mon Jan 15 15:46:09 2001
+++ linux-2.4.0/include/linux/highmem.h	Tue Jan 16 10:52:19 2001
@@ -45,7 +45,7 @@
 /* when CONFIG_HIGHMEM is not set these will be plain clear/copy_page */
 static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	clear_user_page(kmap(page), vaddr);
+	clear_user_page(kmap(page), page);
 	kunmap(page);
 }
 
@@ -87,7 +87,7 @@
 
 	vfrom = kmap(from);
 	vto = kmap(to);
-	copy_user_page(vto, vfrom, vaddr);
+	copy_user_page(vto, vfrom, to);
 	kunmap(from);
 	kunmap(to);
 }
diff -Nur linux-2.4.0-base/include/linux/irq.h linux-2.4.0/include/linux/irq.h
--- linux-2.4.0-base/include/linux/irq.h	Mon Jan 15 10:40:34 2001
+++ linux-2.4.0/include/linux/irq.h	Tue Jan 16 10:47:15 2001
@@ -56,8 +56,6 @@
 
 #include <asm/hw_irq.h> /* the arch dependent stuff */
 
-extern unsigned int do_IRQ (unsigned long irq, struct pt_regs *regs);
-extern void do_IRQ_per_cpu (unsigned long irq, struct pt_regs *regs);
 extern int handle_IRQ_event(unsigned int, struct pt_regs *, struct irqaction 
*);
 extern int setup_irq(unsigned int , struct irqaction * );
 
diff -Nur linux-2.4.0-base/mm/memory.c linux-2.4.0/mm/memory.c
--- linux-2.4.0-base/mm/memory.c	Mon Jan 15 10:40:34 2001
+++ linux-2.4.0/mm/memory.c	Tue Jan 16 12:58:33 2001
@@ -1150,10 +1150,8 @@
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 	struct vm_area_struct * vma, unsigned long address,
-	int access_type, pte_t * pte)
+	int write_access, pte_t * pte)
 {
-	int write_access = is_write_access(access_type);
-	int exec_access = is_exec_access(access_type);
 	pte_t entry;
 
 	/*
@@ -1180,8 +1178,6 @@
 
 		entry = pte_mkdirty(entry);
 	}
-	if (exec_access)
-		entry = pte_mkexec(entry);
 	entry = pte_mkyoung(entry);
 	establish_pte(vma, address, pte, entry);
 	spin_unlock(&mm->page_table_lock);


+---------------------------------------------------------------------+
| Will Taber                                                          |
| Software Engineer, CMBU                 E-mail  wtaber@rational.com |
| Rational Software Corporation           Phone:  781-676-2436        |
| 20 Maguire Road, Lexington, Mass. 02421                             |
+---------------------------------------------------------------------+


