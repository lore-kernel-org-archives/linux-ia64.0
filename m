From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Fri, 01 Nov 2002 08:08:10 +0000
Subject: [Linux-ia64] mremap and "negative" addresses
Message-Id: <marc-linux-ia64-105590709805322@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

mremap, like mmap, can return addresses in region 4 which
are "negative" (when interpreted as signed values) and thus
interpreted as syscall failure.  The following patch
implements the same workaround as for mmap and other such
syscalls.

(It looks like 2.5 also has the same issue, if this seems
sensible I can produce a patch for that as well.)

Matt


diff -ru linux-2.4.19-020821.orig/arch/ia64/kernel/entry.S linux-2.4.19-020821/arch/ia64/kernel/entry.S
--- linux-2.4.19-020821.orig/arch/ia64/kernel/entry.S	2002-09-17 16:18:06.000000000 +1000
+++ linux-2.4.19-020821/arch/ia64/kernel/entry.S	2002-11-01 15:11:50.000000000 +1100
@@ -1109,7 +1109,7 @@
 	data8 sys_mlock
 	data8 sys_mlockall
 	data8 sys_mprotect			// 1155
-	data8 sys_mremap
+	data8 ia64_mremap
 	data8 sys_msync
 	data8 sys_munlock
 	data8 sys_munlockall
diff -ru linux-2.4.19-020821.orig/arch/ia64/kernel/sys_ia64.c linux-2.4.19-020821/arch/ia64/kernel/sys_ia64.c
--- linux-2.4.19-020821.orig/arch/ia64/kernel/sys_ia64.c	2002-09-17 16:18:06.000000000 +1000
+++ linux-2.4.19-020821/arch/ia64/kernel/sys_ia64.c	2002-11-01 18:36:10.000000000 +1100
@@ -253,6 +253,21 @@
 	return addr;
 }
 
+asmlinkage unsigned long
+ia64_mremap (unsigned long addr, unsigned long old_len, unsigned long new_len, unsigned long flags,
+	     unsigned long new_addr, long arg5, long arg6, long arg7, long stack)
+{
+	struct pt_regs *regs = (struct pt_regs *) &stack;
+
+	down_write(&current->mm->mmap_sem);
+	addr = do_mremap(addr, old_len, new_len, flags, new_addr);
+	up_write(&current->mm->mmap_sem);
+
+	if (!IS_ERR((void *) addr))
+		regs->r8 = 0;	/* ensure large addresses are not mistaken as failures... */
+	return addr;
+}
+
 asmlinkage long
 sys_vm86 (long arg0, long arg1, long arg2, long arg3)
 {
diff -ru linux-2.4.19-020821.orig/include/linux/mm.h linux-2.4.19-020821/include/linux/mm.h
--- linux-2.4.19-020821.orig/include/linux/mm.h	2002-09-17 16:18:07.000000000 +1000
+++ linux-2.4.19-020821/include/linux/mm.h	2002-11-01 18:34:15.000000000 +1100
@@ -559,8 +559,10 @@
 }
 
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
-
 extern unsigned long do_brk(unsigned long, unsigned long);
+extern unsigned long do_mremap(unsigned long addr,
+	unsigned long old_len, unsigned long new_len,
+	unsigned long flags, unsigned long new_addr);
 
 static inline void __vma_unlink(struct mm_struct * mm, struct vm_area_struct * vma, struct vm_area_struct * prev)
 {

