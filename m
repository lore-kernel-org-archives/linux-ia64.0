From: Don Dugger <n0ano@n0ano.com>
Date: Tue, 05 Mar 2002 15:13:01 +0000
Subject: [Linux-ia64] Fix for for memory leak in IA32 mmap
MIME-Version: 1
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Message-Id: <marc-linux-ia64-105590701905222@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

David-

Here is a patch against `linux-2.4.17-ia64-011226.diff' that fixes a
memory leak with the IA32 `mmap'/`munmap' calls.  The problem occurs
when a non-fixed `mmap' allocates a range that ends in the middle of
a page.  To handle problems with fixed requests the `munmap' call rounds
down the the area freed, causing the memory leak.  The only solution I
can think of to deal with this is to create a list of the allocated
starting addresses for all non-fixed `mmap' requests.  `munmap' then
checks this list and, if it finds a match, rounds the request size up
rather than down.

I've tried the patch and it appears pretty reliable for me, I've run
competing IA32 processes overnight with no problem and OpenOffice
runs fine.

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com
Ph: 303/449-0877

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_0227.l"

diff -Naur linux-2.4.17-orig/arch/ia64/ia32/sys_ia32.c linux-2.4.17/arch/ia64/ia32/sys_ia32.c
--- linux-2.4.17-orig/arch/ia64/ia32/sys_ia32.c	Thu Feb  7 20:53:36 2002
+++ linux-2.4.17/arch/ia64/ia32/sys_ia32.c	Tue Feb 26 23:09:16 2002
@@ -324,14 +324,72 @@
 	return ret;
 }
 
+static void
+ia32_set_range(struct mmap_range *rp, unsigned int start)
+{
+	struct mmap_range *rg;
+
+	if ((rg = kmalloc(sizeof(*rg), GFP_KERNEL)) == (struct mmap_range *)0)
+		return;
+	rg->base = start;
+	rg->next = rp->next;
+	rp->next = rg;
+	return;
+}
+
+static int
+ia32_in_range(struct mmap_range *rp, unsigned int start)
+{
+	struct mmap_range *rg;
+
+	while ((rg = rp->next))
+		if (rg->base == start) {
+			rp->next = rg->next;
+			kfree(rg);
+			return(1);
+		} else
+			rp = rg;
+	return(0);
+}
+
+void
+ia32_delete_range(struct mmap_range *rp)
+{
+	struct mmap_range *rg;
+
+	while ((rg = rp)) {
+		rp = rp->next;
+		kfree(rg);
+	}
+	return;
+}
+
+void
+ia32_copy_range(struct mmap_range *rp)
+{
+	struct mmap_range *rg, *cg;
+
+	rp->next = (struct mmap_range *)0;
+	cg = (struct mmap_range *)&current->thread.mmap_range;
+	while ((cg = cg->next)) {
+		if ((rg = kmalloc(sizeof(*rg), GFP_KERNEL)) == (struct mmap_range *)0)
+			return;
+		rg->base = cg->base;
+		rg->next = rp->next;
+		rp->next = rg;
+	}
+	return;
+}
+
 static unsigned long
 emulate_mmap (struct file *file, unsigned long start, unsigned long len, int prot, int flags,
 	      loff_t off)
 {
-	unsigned long tmp, end, pend, pstart, ret, is_congruent, fudge = 0;
+	unsigned long tmp, end, orig, pend, pstart, ret, is_congruent, fudge = 0;
 	struct inode *inode;
 	loff_t poff;
 
+	orig = start;
 	end = start + len;
 	pstart = PAGE_START(start);
 	pend = PAGE_ALIGN(end);
@@ -415,6 +473,8 @@
 		if (!(prot & PROT_WRITE) && sys_mprotect(pstart, pend - pstart, prot) < 0)
 			return EINVAL;
 	}
+	if (orig == 0)
+		ia32_set_range((struct mmap_range *)&current->thread.mmap_range, (unsigned int)start);
 	return start;
 }
 
@@ -550,8 +610,11 @@
 	if (start > end)
 		return -EINVAL;
 
+	if (ia32_in_range((struct mmap_range *)&current->thread.mmap_range, start))
+		end = PAGE_ALIGN(end);
+	else
+		end = PAGE_START(end);
 	start = PAGE_ALIGN(start);
-	end = PAGE_START(end);
 
 	if (start >= end)
 		return 0;
diff -Naur linux-2.4.17-orig/arch/ia64/kernel/process.c linux-2.4.17/arch/ia64/kernel/process.c
--- linux-2.4.17-orig/arch/ia64/kernel/process.c	Mon Feb 11 21:33:55 2002
+++ linux-2.4.17/arch/ia64/kernel/process.c	Tue Feb 26 22:41:36 2002
@@ -308,8 +308,13 @@
 	 * If we're cloning an IA32 task then save the IA32 extra
 	 * state from the current task to the new task
 	 */
-	if (IS_IA32_PROCESS(ia64_task_regs(current)))
+	if (IS_IA32_PROCESS(ia64_task_regs(current))) {
 		ia32_save_state(p);
+		/*
+		 * Copy mmap ranges that might be needed for munmap calls
+		 */
+		ia32_copy_range((struct mmap_range *)&p->thread.mmap_range);
+	}
 #endif
 #ifdef CONFIG_PERFMON
 	if (p->thread.pfm_context)
@@ -516,6 +521,10 @@
 		 */
 		current->thread.flags &= ~IA64_THREAD_PM_VALID;
 	}
+#endif
+#ifdef CONFIG_IA32_SUPPORT
+	if (IS_IA32_PROCESS(ia64_task_regs(current)))
+		ia32_delete_range(current->thread.mmap_range);
 #endif
 }
 
diff -Naur linux-2.4.17-orig/include/asm-ia64/processor.h linux-2.4.17/include/asm-ia64/processor.h
--- linux-2.4.17-orig/include/asm-ia64/processor.h	Thu Feb  7 21:15:44 2002
+++ linux-2.4.17/include/asm-ia64/processor.h	Tue Feb 26 22:42:20 2002
@@ -348,6 +348,14 @@
 
 struct siginfo;
 
+struct mmap_range {
+	struct mmap_range	*next;
+	unsigned int		base;
+};
+
+void ia32_copy_range(struct mmap_range *);
+void ia32_delet_range(struct mmap_range *);
+
 struct thread_struct {
 	__u64 ksp;			/* kernel stack pointer */
 	unsigned long flags;		/* various flags */
@@ -365,7 +373,8 @@
 	__u64 ssd;			/* IA32 stack selector descriptor */
 	__u64 old_k1;			/* old value of ar.k1 */
 	__u64 old_iob;			/* old IOBase value */
-# define INIT_THREAD_IA32	0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, 0,
+	struct mmap_range *mmap_range;	/* mmap ranges */
+# define INIT_THREAD_IA32	0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, 0, 0,
 #else
 # define INIT_THREAD_IA32
 #endif /* CONFIG_IA32_SUPPORT */

--BOKacYhQ+x31HxR3--

