From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 10 Sep 2001 15:41:05 +0000
Subject: [Linux-ia64] ia32 cleanup patch
Message-Id: <marc-linux-ia64-105590698805154@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a cleanup patch for the ia32 subsystem.  Originally, the goal
was to fix the problems that kept the ia32 subsystem from working when
using an ia64 page size of 4KB, but I ended up cleaning up the ia32
mmap() and mprotect() in the end.  The result is that 4KB page size
should now work, plus realplayer seems to work fine now, too.

Don, could you take a look at it and perhaps run whatever ia32 test
suite you have?  If it looks good, I'd like to include these changes
in the next ia64 patch.

	--david

diff -urN lia64/arch/ia64/ia32/binfmt_elf32.c lia64-kdb/arch/ia64/ia32/binfmt_elf32.c
--- lia64/arch/ia64/ia32/binfmt_elf32.c	Mon Apr 23 12:04:15 2001
+++ lia64-kdb/arch/ia64/ia32/binfmt_elf32.c	Sun Sep  9 23:40:56 2001
@@ -3,7 +3,7 @@
  *
  * Copyright (C) 1999 Arun Sharma <arun.sharma@intel.com>
  * Copyright (C) 2001 Hewlett-Packard Co
- * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 06/16/00	A. Mallick	initialize csd/ssd/tssd/cflg for ia32_load_state
  * 04/13/01	D. Mosberger	dropped saving tssd in ar.k1---it's not needed
@@ -51,16 +51,13 @@
 /* Global descriptor table */
 unsigned long *ia32_gdt_table, *ia32_tss;
 
-struct page *
+static struct page *
 put_shared_page (struct task_struct * tsk, struct page *page, unsigned long address)
 {
 	pgd_t * pgd;
 	pmd_t * pmd;
 	pte_t * pte;
 
-	if (page_count(page) != 1)
-		printk("mem_map disagrees with %p at %08lx\n", (void *) page, address);
-
 	pgd = pgd_offset(tsk->mm, address);
 
 	spin_lock(&tsk->mm->page_table_lock);
@@ -96,6 +93,9 @@
 	 * Map GDT and TSS below 4GB, where the processor can find them.  We need to map
 	 * it with privilege level 3 because the IVE uses non-privileged accesses to these
 	 * tables.  IA-32 segmentation is used to protect against IA-32 accesses to them.
+	 *
+	 * Note: Since we don't have a vmarea for the GDT and TSS pages, we don't need
+	 *	 to worry about an exit()ing IA-32 task freeing these pages.
 	 */
 	put_shared_page(current, virt_to_page(ia32_gdt_table), IA32_GDT_OFFSET);
 	if (PAGE_SHIFT <= IA32_PAGE_SHIFT)
@@ -213,6 +213,7 @@
 	return 0;
 }
 
+#if 0
 static unsigned long
 ia32_mm_addr (unsigned long addr)
 {
@@ -224,34 +225,38 @@
 		return ELF_PAGESTART(addr);
 	return ELF_PAGEALIGN(addr);
 }
+#endif
 
 /*
- *  Normally we would do an `mmap' to map in the process's text section.
- *  This doesn't work with IA32 processes as the ELF file might specify
- *  a non page size aligned address.  Instead we will just allocate
- *  memory and read the data in from the file.  Slightly less efficient
- *  but it works.
+ * Normally we would do an `mmap' to map in the process's text section.  This doesn't work
+ * with IA32 processes as the ELF file might specify a non page size aligned address.
+ * Instead we will just allocate memory and read the data in from the file.  Slightly less
+ * efficient but it works.
  */
-extern long ia32_do_mmap (struct file *filep, unsigned int len, unsigned int prot,
-			  unsigned int flags, unsigned int fd, unsigned int offset);
-
 static unsigned long
 elf_map32 (struct file *filep, unsigned long addr, struct elf_phdr *eppnt, int prot, int type)
 {
 	unsigned long retval;
 
-	if (eppnt->p_memsz >= (1UL<<32) || addr > (1UL<<32) - eppnt->p_memsz)
-		return -EINVAL;
-
 	/*
-	 *  Make sure the elf interpreter doesn't get loaded at location 0
-	 *    so that NULL pointers correctly cause segfaults.
+	 * Make sure the elf interpreter doesn't get loaded at location 0 so that NULL
+	 * pointers correctly cause segfaults.
 	 */
 	if (addr = 0)
 		addr += PAGE_SIZE;
+
+#if 0
+	if (eppnt->p_memsz >= (1UL<<32) || addr > (1UL<<32) - eppnt->p_memsz)
+		return -EINVAL;
+
 	set_brk(ia32_mm_addr(addr), addr + eppnt->p_memsz);
 	memset((char *) addr + eppnt->p_filesz, 0, eppnt->p_memsz - eppnt->p_filesz);
 	kernel_read(filep, eppnt->p_offset, (char *) addr, eppnt->p_filesz);
 	retval = (unsigned long) addr;
+#else
+	retval = ia32_do_mmap(filep, (addr & IA32_PAGE_MASK),
+			      eppnt->p_filesz + (eppnt->p_vaddr & ~IA32_PAGE_MASK), prot, type,
+			      eppnt->p_offset - (eppnt->p_vaddr & ~IA32_PAGE_MASK));
+#endif
 	return retval;
 }
diff -urN lia64/arch/ia64/ia32/ia32_entry.S lia64-kdb/arch/ia64/ia32/ia32_entry.S
--- lia64/arch/ia64/ia32/ia32_entry.S	Tue Jun 26 22:21:54 2001
+++ lia64-kdb/arch/ia64/ia32/ia32_entry.S	Sun Sep  9 16:35:30 2001
@@ -85,7 +85,7 @@
 	st8.spill [r2]=r8			// store return value in slot for r8
 	br.call.sptk.few rp=invoke_syscall_trace // give parent a chance to catch return value
 .ret2:	alloc r2=ar.pfs,0,0,0,0			// drop the syscall argument frame
-	br.cond.sptk.many ia64_leave_kernel	// rp MUST be != ia64_leave_kernel!
+	br.cond.sptk.many ia64_leave_kernel
 END(ia32_trace_syscall)
 
 GLOBAL_ENTRY(sys32_vfork)
diff -urN lia64/arch/ia64/ia32/sys_ia32.c lia64-kdb/arch/ia64/ia32/sys_ia32.c
--- lia64/arch/ia64/ia32/sys_ia32.c	Mon Aug 20 12:20:42 2001
+++ lia64-kdb/arch/ia64/ia32/sys_ia32.c	Sun Sep  9 23:56:16 2001
@@ -7,8 +7,8 @@
  * Copyright (C) 1999		Arun Sharma <arun.sharma@intel.com>
  * Copyright (C) 1997,1998	Jakub Jelinek (jj@sunsite.mff.cuni.cz)
  * Copyright (C) 1997		David S. Miller (davem@caip.rutgers.edu)
- * Copyright (C) 2000		Hewlett-Packard Co.
- * Copyright (C) 2000		David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2000-2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * These routines maintain argument size conversion between 32bit and 64bit
  * environment.
@@ -66,6 +66,10 @@
 
 extern asmlinkage long sys_execve (char *, char **, char **, struct pt_regs *);
 extern asmlinkage long sys_mprotect (unsigned long, size_t, unsigned long);
+extern asmlinkage long sys_munmap (unsigned long, size_t);
+
+/* forward declaration: */
+asmlinkage long sys32_mprotect (unsigned int, unsigned int, int);
 
 static int
 nargs (unsigned int arg, char **ap)
@@ -217,96 +221,137 @@
 
 #define OFFSET4K(a)	((a) & 0xfff)
 
-unsigned long
-do_mmap_fake(struct file *file, unsigned long addr, unsigned long len,
-	unsigned long prot, unsigned long flags, loff_t off)
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
+
+static unsigned long
+do_mmap_fake (struct file *file, unsigned long addr, unsigned long len, int prot, int flags,
+	      loff_t off)
 {
+	unsigned long faddr = (addr & PAGE_MASK), end, front_len, back_len, retval;
+	void *front = 0, *back = 0;
 	struct inode *inode;
-	void *front, *back;
-	unsigned long baddr;
-	int r;
 	char c;
 
-	if (OFFSET4K(addr) || OFFSET4K(off))
-		return -EINVAL;
+	/*
+	 * Allow any kind of access: this lets us avoid having to figure out what the
+	 * protection of the partial front and back pages is...
+	 */
 	prot |= PROT_WRITE;
-	front = NULL;
-	back = NULL;
-	if ((baddr = (addr & PAGE_MASK)) != addr && get_user(c, (char *)baddr) = 0) {
-		front = kmalloc(addr - baddr, GFP_KERNEL);
+
+	if (OFFSET4K(addr))
+		return -EINVAL;
+
+	end = addr + len;
+	front_len = addr - faddr;
+	back_len = (end & ~PAGE_MASK);
+
+	if (front_len && get_user(c, (char *)faddr) = 0) {
+		front = kmalloc(front_len, GFP_KERNEL);
 		if (!front)
 			return -ENOMEM;
-		__copy_user(front, (void *)baddr, addr - baddr);
+		__copy_user(front, (void *)faddr, front_len);
 	}
-	if (addr && ((addr + len) & ~PAGE_MASK) && get_user(c, (char *)(addr + len)) = 0) {
-		back = kmalloc(PAGE_SIZE - ((addr + len) & ~PAGE_MASK), GFP_KERNEL);
+
+	if (addr && back_len && get_user(c, (char *)end) = 0) {
+		back = kmalloc(PAGE_SIZE - back_len, GFP_KERNEL);
 		if (!back) {
-			if (front)
-				kfree(front);
-			return -ENOMEM;
+			addr = -ENOMEM;
+			goto fail;
 		}
-		__copy_user(back, (char *)addr + len, PAGE_SIZE - ((addr + len) & ~PAGE_MASK));
+		__copy_user(back, (char *)end, PAGE_SIZE - back_len);
 	}
+
 	down_write(&current->mm->mmap_sem);
-	r = do_mmap(0, baddr, len + (addr - baddr), prot, flags | MAP_ANONYMOUS, 0);
+	{
+		retval = do_mmap(0, faddr, len + front_len, prot, flags | MAP_ANONYMOUS, 0);
+	}
 	up_write(&current->mm->mmap_sem);
-	if (r < 0)
-		return(r);
-	if (addr = 0)
-		addr = r;
+
+	if (IS_ERR((void *) retval)) {
+		addr = retval;
+		goto fail;
+	}
+
+	if (!addr)
+		addr = retval;
+
+	end = addr + len;
+
 	if (back) {
-		__copy_user((char *)addr + len, back, PAGE_SIZE - ((addr + len) & ~PAGE_MASK));
+		__copy_user((char *) end, back, PAGE_SIZE - back_len);
 		kfree(back);
 	}
 	if (front) {
-		__copy_user((void *)baddr, front, addr - baddr);
+		__copy_user((void *) faddr, front, front_len);
 		kfree(front);
 	}
-	if (flags & MAP_ANONYMOUS) {
-		clear_user((char *)addr, len);
-		return(addr);
+
+	if (!(flags & MAP_ANONYMOUS)) {
+		inode = file->f_dentry->d_inode;
+		if (!inode->i_fop
+		    || !file->f_op->read
+		    || (*file->f_op->read)(file, (char *)addr, len, &off) < 0)
+		{
+			sys_munmap(addr, len + front_len);
+			return -EINVAL;
+		}
 	}
-	if (!file)
-		return -EINVAL;
-	inode = file->f_dentry->d_inode;
-	if (!inode->i_fop)
-		return -EINVAL;
-	if (!file->f_op->read)
-		return -EINVAL;
-	r = file->f_op->read(file, (char *)addr, len, &off);
-	return (r < 0) ? -EINVAL : addr;
+	return addr;
+
+  fail:
+	if (front)
+		kfree(front);
+	if (back)
+		kfree(back);
+	return addr;
 }
 
-long
-ia32_do_mmap (struct file *file, unsigned int addr, unsigned int len, unsigned int prot,
-	      unsigned int flags, unsigned int fd, unsigned int offset)
+#endif /* PAGE_SHIFT > IA32_PAGE_SHIFT */
+
+unsigned long
+ia32_do_mmap (struct file *file, unsigned long addr, unsigned long len, int prot, int flags,
+	      loff_t offset)
 {
-	long error = -EFAULT;
-	unsigned int poff;
+	if (file && (!file->f_op || !file->f_op->mmap))
+		return -ENODEV;
 
-	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	prot |= PROT_EXEC;
+	len = IA32_PAGE_ALIGN(len);
+	if (len = 0)
+		return addr;
+
+	if (len > IA32_PAGE_OFFSET || addr > IA32_PAGE_OFFSET - len)
+		return -EINVAL;
+
+	if (OFFSET4K(offset))
+		return -EINVAL;
+
+	if (prot & (PROT_READ | PROT_WRITE))
+		prot |= PROT_EXEC;	/* x86 has no "execute" permission bit... */
 
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
 	if ((flags & MAP_FIXED) && ((addr & ~PAGE_MASK) || (offset & ~PAGE_MASK)))
-		error = do_mmap_fake(file, addr, len, prot, flags, (loff_t)offset);
-	else {
-		poff = offset & PAGE_MASK;
-		len += offset - poff;
+		addr = do_mmap_fake(file, addr, len, prot, flags, offset);
+	else
+#endif
+	{
+		loff_t pgoff = offset & PAGE_MASK;
+		len += offset - pgoff;
 
 		down_write(&current->mm->mmap_sem);
-		error = do_mmap_pgoff(file, addr, len, prot, flags, poff >> PAGE_SHIFT);
+		{
+			addr = do_mmap(file, addr, len, prot, flags, pgoff);
+		}
 		up_write(&current->mm->mmap_sem);
 
-		if (!IS_ERR((void *) error))
-			error += offset - poff;
+		if (!IS_ERR((void *) addr))
+			addr += offset - pgoff;
 	}
-	return error;
+	return addr;
 }
 
 /*
- * Linux/i386 didn't use to be able to handle more than
- * 4 system call parameters, so these system calls used a memory
- * block for parameter passing..
+ * Linux/i386 didn't use to be able to handle more than 4 system call parameters, so these
+ * system calls used a memory block for parameter passing..
  */
 
 struct mmap_arg_struct {
@@ -319,56 +364,114 @@
 };
 
 asmlinkage long
-sys32_mmap(struct mmap_arg_struct *arg)
+sys32_mmap (struct mmap_arg_struct *arg)
 {
 	struct mmap_arg_struct a;
 	struct file *file = NULL;
-	long retval;
+	unsigned long addr;
+	int flags;
 
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
 
-	if (PAGE_ALIGN(a.len) = 0)
-		return a.addr;
+	if (OFFSET4K(a.offset))
+		return -EINVAL;
+
+	flags = a.flags;
 
-	if (!(a.flags & MAP_ANONYMOUS)) {
+	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
+	if (!(flags & MAP_ANONYMOUS)) {
 		file = fget(a.fd);
 		if (!file)
 			return -EBADF;
 	}
-#ifdef	CONFIG_IA64_PAGE_SIZE_4KB
-	if ((a.offset & ~PAGE_MASK) != 0)
-		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
-	retval = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, a.offset >> PAGE_SHIFT);
-	up_write(&current->mm->mmap_sem);
-#else
-	retval = ia32_do_mmap(file, a.addr, a.len, a.prot, a.flags, a.fd, a.offset);
-#endif
+	addr = ia32_do_mmap(file, a.addr, a.len, a.prot, flags, a.offset);
+
 	if (file)
 		fput(file);
-	return retval;
+	return addr;
+}
+
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
+
+/*
+ * When mprotect()ing a partial page, we set the permission to the union of the old
+ * settings and the new settings.  In other words, it's only possible to make access to a
+ * partial page less restrictive.
+ */
+static long
+mprotect_partial_page (unsigned long address, int new_prot)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	int old_prot = 0;
+
+	if (new_prot = PROT_NONE)
+		return 0;		/* optimize case where nothing changes... */
+
+	address &= ~PAGE_MASK;
+
+	down_read(&mm->mmap_sem);
+	{
+		vma = find_vma(mm, address);
+		if (vma && vma->vm_start <= address)
+			old_prot = (vma->vm_flags & 0xf);
+	}
+	up_read(&mm->mmap_sem);
+
+	return sys_mprotect(address, PAGE_SIZE, new_prot | old_prot);
 }
 
+#endif /* PAGE_SHIFT > IA32_PAGE_SHIFT */
+
 asmlinkage long
-sys32_mprotect(unsigned long start, size_t len, unsigned long prot)
+sys32_mprotect (unsigned int start, unsigned int len, int prot)
 {
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
+	unsigned long end;
+	long retval;
+#endif
 
-#ifdef	CONFIG_IA64_PAGE_SIZE_4KB
-	return(sys_mprotect(start, len, prot));
-#else	// CONFIG_IA64_PAGE_SIZE_4KB
-	if (prot = 0)
-		return(0);
-	len += start & ~PAGE_MASK;
-	if ((start & ~PAGE_MASK) && (prot & PROT_WRITE))
+	if (prot & (PROT_READ | PROT_WRITE))
+		/* on x86, PROT_WRITE implies PROT_READ and PROT_READ implies PROT_EXEC... */
 		prot |= PROT_EXEC;
-	return(sys_mprotect(start & PAGE_MASK, len & PAGE_MASK, prot));
-#endif	// CONFIG_IA64_PAGE_SIZE_4KB
+
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
+	if (OFFSET4K(start))
+		return -EINVAL;
+
+	len = IA32_PAGE_ALIGN(len);
+	end = start + len;
+	if (end < start)
+		return -EINVAL;
+
+	if (start & ~PAGE_MASK) {
+		/* start address is 4KB aligned but not page aligned. */
+		retval = mprotect_partial_page(start, prot);
+		if (retval < 0)
+			return retval;
+
+		len -= (start & ~PAGE_MASK);
+		start = PAGE_ALIGN(start);
+
+		if (start >= end)
+			return 0;
+	}
+
+	if (end & ~PAGE_MASK) {
+		/* end address is 4KB aligned but not page aligned. */
+		retval = mprotect_partial_page(end, prot);
+		if (retval < 0)
+			return retval;
+		len -= (len & ~PAGE_MASK);
+	}
+#endif
+	return sys_mprotect(start, len, prot);
 }
 
 asmlinkage long
-sys32_pipe(int *fd)
+sys32_pipe (int *fd)
 {
 	int retval;
 	int fds[2];
@@ -397,8 +500,8 @@
 }
 
 asmlinkage long
-sys32_rt_sigaction(int sig, struct sigaction32 *act,
-		   struct sigaction32 *oact,  unsigned int sigsetsize)
+sys32_rt_sigaction (int sig, struct sigaction32 *act,
+		    struct sigaction32 *oact,  unsigned int sigsetsize)
 {
 	struct k_sigaction new_ka, old_ka;
 	int ret;
diff -urN lia64/include/asm-ia64/ia32.h lia64-kdb/include/asm-ia64/ia32.h
--- lia64/include/asm-ia64/ia32.h	Mon Jul 23 14:38:14 2001
+++ lia64-kdb/include/asm-ia64/ia32.h	Sun Sep  9 22:38:10 2001
@@ -34,6 +34,8 @@
 
 #define IA32_PAGE_SHIFT		12	/* 4KB pages */
 #define IA32_PAGE_SIZE		(1ULL << IA32_PAGE_SHIFT)
+#define IA32_PAGE_MASK		(~(IA32_PAGE_SIZE - 1))
+#define IA32_PAGE_ALIGN(addr)	(((addr) + IA32_PAGE_SIZE - 1) & IA32_PAGE_MASK)
 #define IA32_CLOCKS_PER_SEC	100	/* Cast in stone for IA32 Linux */
 #define IA32_TICK(tick)		((unsigned long long)(tick) * IA32_CLOCKS_PER_SEC / CLOCKS_PER_SEC)
 
@@ -421,6 +423,7 @@
 extern void ia32_init_addr_space (struct pt_regs *regs);
 extern int ia32_setup_arg_pages (struct linux_binprm *bprm);
 extern int ia32_exception (struct pt_regs *regs, unsigned long isr);
+extern unsigned long ia32_do_mmap (struct file *, unsigned long, unsigned long, int, int, loff_t);
 
 #endif /* !CONFIG_IA32_SUPPORT */
 

