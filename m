From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 13 Jan 2005 08:37:21 +0000
Subject: [patch] make ptrace.c fit in 80 cols
Message-Id: <16870.13121.763942.597591@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Should make Jesse and Willy happy (or at least happier)...

The patch is relative to 2.6.10, but I think it'll apply on your tree,
too.  If not, just give a holler.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/12 23:34:57-08:00 davidm@tiger.hpl.hp.com 
#   ia64: Format arch/ia64/kernel/ptrace.c to fit in 80 cols.
# 
# arch/ia64/kernel/ptrace.c
#   2005/01/12 23:34:46-08:00 davidm@tiger.hpl.hp.com +385 -263
#   Format to make it fit in 80 cols.
# 
diff -Nru a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
--- a/arch/ia64/kernel/ptrace.c	2005-01-13 00:22:21 -08:00
+++ b/arch/ia64/kernel/ptrace.c	2005-01-13 00:22:21 -08:00
@@ -1,11 +1,10 @@
 /*
  * Kernel support for the ptrace() and syscall tracing interfaces.
  *
- * Copyright (C) 1999-2004 Hewlett-Packard Co
+ * Copyright (C) 1999-2005 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
- * Derived from the x86 and Alpha versions.  Most of the code in here
- * could actually be factored into a common set of routines.
+ * Derived from the x86 and Alpha versions.
  */
 #include <linux/config.h>
 #include <linux/kernel.h>
@@ -43,9 +42,11 @@
  *	ri (restart instruction; two bits)
  *	is (instruction set; one bit)
  */
-#define IPSR_WRITE_MASK \
-	(IA64_PSR_UM | IA64_PSR_DB | IA64_PSR_IS | IA64_PSR_ID | IA64_PSR_DD | IA64_PSR_RI)
-#define IPSR_READ_MASK	IPSR_WRITE_MASK
+#define IPSR_MASK (IA64_PSR_UM | IA64_PSR_DB | IA64_PSR_IS	\
+		   | IA64_PSR_ID | IA64_PSR_DD | IA64_PSR_RI)
+
+#define MASK(nbits)	((1UL << (nbits)) - 1)	/* mask with NBITS bits set */
+#define PFM_MASK	MASK(38)
 
 #define PTRACE_DEBUG	0
 
@@ -71,23 +72,24 @@
 unsigned long
 ia64_get_scratch_nat_bits (struct pt_regs *pt, unsigned long scratch_unat)
 {
-#	define GET_BITS(first, last, unat)						\
-	({										\
-		unsigned long bit = ia64_unat_pos(&pt->r##first);			\
-		unsigned long mask = ((1UL << (last - first + 1)) - 1) << first;	\
-		unsigned long dist;							\
-		if (bit < first)							\
-			dist = 64 + bit - first;					\
-		else									\
-			dist = bit - first;						\
-		ia64_rotr(unat, dist) & mask;						\
+#	define GET_BITS(first, last, unat)				\
+	({								\
+		unsigned long bit = ia64_unat_pos(&pt->r##first);	\
+		unsigned long nbits = (last - first + 1);		\
+		unsigned long mask = MASK(nbits) << first;		\
+		unsigned long dist;					\
+		if (bit < first)					\
+			dist = 64 + bit - first;			\
+		else							\
+			dist = bit - first;				\
+		ia64_rotr(unat, dist) & mask;				\
 	})
 	unsigned long val;
 
 	/*
-	 * Registers that are stored consecutively in struct pt_regs can be handled in
-	 * parallel.  If the register order in struct_pt_regs changes, this code MUST be
-	 * updated.
+	 * Registers that are stored consecutively in struct pt_regs
+	 * can be handled in parallel.  If the register order in
+	 * struct_pt_regs changes, this code MUST be updated.
 	 */
 	val  = GET_BITS( 1,  1, scratch_unat);
 	val |= GET_BITS( 2,  3, scratch_unat);
@@ -109,23 +111,24 @@
 unsigned long
 ia64_put_scratch_nat_bits (struct pt_regs *pt, unsigned long nat)
 {
-#	define PUT_BITS(first, last, nat)						\
-	({										\
-		unsigned long bit = ia64_unat_pos(&pt->r##first);			\
-		unsigned long mask = ((1UL << (last - first + 1)) - 1) << first;	\
-		long dist;								\
-		if (bit < first)							\
-			dist = 64 + bit - first;					\
-		else									\
-			dist = bit - first;						\
-		ia64_rotl(nat & mask, dist);						\
+#	define PUT_BITS(first, last, nat)				\
+	({								\
+		unsigned long bit = ia64_unat_pos(&pt->r##first);	\
+		unsigned long nbits = (last - first + 1);		\
+		unsigned long mask = MASK(nbits) << first;		\
+		long dist;						\
+		if (bit < first)					\
+			dist = 64 + bit - first;			\
+		else							\
+			dist = bit - first;				\
+		ia64_rotl(nat & mask, dist);				\
 	})
 	unsigned long scratch_unat;
 
 	/*
-	 * Registers that are stored consecutively in struct pt_regs can be handled in
-	 * parallel.  If the register order in struct_pt_regs changes, this code MUST be
-	 * updated.
+	 * Registers that are stored consecutively in struct pt_regs
+	 * can be handled in parallel.  If the register order in
+	 * struct_pt_regs changes, this code MUST be updated.
 	 */
 	scratch_unat  = PUT_BITS( 1,  1, nat);
 	scratch_unat |= PUT_BITS( 2,  3, nat);
@@ -188,10 +191,12 @@
 }
 
 /*
- * This routine is used to read an rnat bits that are stored on the kernel backing store.
- * Since, in general, the alignment of the user and kernel are different, this is not
- * completely trivial.  In essence, we need to construct the user RNAT based on up to two
- * kernel RNAT values and/or the RNAT value saved in the child's pt_regs.
+ * This routine is used to read an rnat bits that are stored on the
+ * kernel backing store.  Since, in general, the alignment of the user
+ * and kernel are different, this is not completely trivial.  In
+ * essence, we need to construct the user RNAT based on up to two
+ * kernel RNAT values and/or the RNAT value saved in the child's
+ * pt_regs.
  *
  * user rbs
  *
@@ -224,24 +229,28 @@
  *					+--------+
  *						  <--- child_stack->ar_bspstore
  *
- * The way to think of this code is as follows: bit 0 in the user rnat corresponds to some
- * bit N (0 <= N <= 62) in one of the kernel rnat value.  The kernel rnat value holding
- * this bit is stored in variable rnat0.  rnat1 is loaded with the kernel rnat value that
+ * The way to think of this code is as follows: bit 0 in the user rnat
+ * corresponds to some bit N (0 <= N <= 62) in one of the kernel rnat
+ * value.  The kernel rnat value holding this bit is stored in
+ * variable rnat0.  rnat1 is loaded with the kernel rnat value that
  * form the upper bits of the user rnat value.
  *
  * Boundary cases:
  *
- * o when reading the rnat "below" the first rnat slot on the kernel backing store,
- *   rnat0/rnat1 are set to 0 and the low order bits are merged in from pt->ar_rnat.
+ * o when reading the rnat "below" the first rnat slot on the kernel
+ *   backing store, rnat0/rnat1 are set to 0 and the low order bits are
+ *   merged in from pt->ar_rnat.
  *
- * o when reading the rnat "above" the last rnat slot on the kernel backing store,
- *   rnat0/rnat1 gets its value from sw->ar_rnat.
+ * o when reading the rnat "above" the last rnat slot on the kernel
+ *   backing store, rnat0/rnat1 gets its value from sw->ar_rnat.
  */
 static unsigned long
 get_rnat (struct task_struct *task, struct switch_stack *sw,
-	  unsigned long *krbs, unsigned long *urnat_addr, unsigned long *urbs_end)
+	  unsigned long *krbs, unsigned long *urnat_addr,
+	  unsigned long *urbs_end)
 {
-	unsigned long rnat0 = 0, rnat1 = 0, urnat = 0, *slot0_kaddr, umask = 0, mask, m;
+	unsigned long rnat0 = 0, rnat1 = 0, urnat = 0, *slot0_kaddr;
+	unsigned long umask = 0, mask, m;
 	unsigned long *kbsp, *ubspstore, *rnat0_kaddr, *rnat1_kaddr, shift;
 	long num_regs, nbits;
 	struct pt_regs *pt;
@@ -254,11 +263,12 @@
 		nbits = ia64_rse_num_regs(urnat_addr - 63, urbs_end);
 	else
 		nbits = 63;
-	mask = (1UL << nbits) - 1;
+	mask = MASK(nbits);
 	/*
-	 * First, figure out which bit number slot 0 in user-land maps to in the kernel
-	 * rnat.  Do this by figuring out how many register slots we're beyond the user's
-	 * backingstore and then computing the equivalent address in kernel space.
+	 * First, figure out which bit number slot 0 in user-land maps
+	 * to in the kernel rnat.  Do this by figuring out how many
+	 * register slots we're beyond the user's backingstore and
+	 * then computing the equivalent address in kernel space.
 	 */
 	num_regs = ia64_rse_num_regs(ubspstore, urnat_addr + 1);
 	slot0_kaddr = ia64_rse_skip_regs(krbs, num_regs);
@@ -268,7 +278,7 @@
 
 	if (ubspstore + 63 > urnat_addr) {
 		/* some bits need to be merged in from pt->ar_rnat */
-		umask = ((1UL << ia64_rse_slot_num(ubspstore)) - 1) & mask;
+		umask = MASK(ia64_rse_slot_num(ubspstore)) & mask;
 		urnat = (pt->ar_rnat & umask);
 		mask &= ~umask;
 		if (!mask)
@@ -326,12 +336,13 @@
 			return;
 		nbits = ia64_rse_num_regs(urnat_addr - 63, urbs_kargs);
 	}
-	mask = (1UL << nbits) - 1;
+	mask = MASK(nbits);
 
 	/*
-	 * First, figure out which bit number slot 0 in user-land maps to in the kernel
-	 * rnat.  Do this by figuring out how many register slots we're beyond the user's
-	 * backingstore and then computing the equivalent address in kernel space.
+	 * First, figure out which bit number slot 0 in user-land maps
+	 * to in the kernel rnat.  Do this by figuring out how many
+	 * register slots we're beyond the user's backingstore and
+	 * then computing the equivalent address in kernel space.
 	 */
 	num_regs = ia64_rse_num_regs(ubspstore, urnat_addr + 1);
 	slot0_kaddr = ia64_rse_skip_regs(krbs, num_regs);
@@ -341,7 +352,7 @@
 
 	if (ubspstore + 63 > urnat_addr) {
 		/* some bits need to be place in pt->ar_rnat: */
-		umask = ((1UL << ia64_rse_slot_num(ubspstore)) - 1) & mask;
+		umask = MASK(ia64_rse_slot_num(ubspstore)) & mask;
 		pt->ar_rnat = (pt->ar_rnat & ~umask) | (urnat & umask);
 		mask &= ~umask;
 		if (!mask)
@@ -367,25 +378,28 @@
 }
 
 static inline int
-on_kernel_rbs (unsigned long addr, unsigned long bspstore, unsigned long urbs_end)
+on_kernel_rbs (unsigned long addr, unsigned long bspstore,
+	       unsigned long urbs_end)
 {
-	return (addr >= bspstore
-		&& addr <= (unsigned long) ia64_rse_rnat_addr((unsigned long *) urbs_end));
+	unsigned long *rnat_addr = ia64_rse_rnat_addr((unsigned long *)
+						      urbs_end);
+	return (addr >= bspstore && addr <= (unsigned long) rnat_addr);
 }
 
 /*
- * Read a word from the user-level backing store of task CHILD.  ADDR is the user-level
- * address to read the word from, VAL a pointer to the return value, and USER_BSP gives
- * the end of the user-level backing store (i.e., it's the address that would be in ar.bsp
- * after the user executed a "cover" instruction).
+ * Read a word from the user-level backing store of task CHILD.  ADDR
+ * is the user-level address to read the word from, VAL a pointer to
+ * the return value, and USER_BSP gives the end of the user-level
+ * backing store (i.e., it's the address that would be in ar.bsp after
+ * the user executed a "cover" instruction).
  *
- * This routine takes care of accessing the kernel register backing store for those
- * registers that got spilled there.  It also takes care of calculating the appropriate
- * RNaT collection words.
+ * This routine takes care of accessing the kernel register backing
+ * store for those registers that got spilled there.  It also takes
+ * care of calculating the appropriate RNaT collection words.
  */
 long
-ia64_peek (struct task_struct *child, struct switch_stack *child_stack, unsigned long user_rbs_end,
-	   unsigned long addr, long *val)
+ia64_peek (struct task_struct *child, struct switch_stack *child_stack,
+	   unsigned long user_rbs_end, unsigned long addr, long *val)
 {
 	unsigned long *bspstore, *krbs, regnum, *laddr, *urbs_end, *rnat_addr;
 	struct pt_regs *child_regs;
@@ -397,10 +411,13 @@
 	child_regs = ia64_task_regs(child);
 	bspstore = (unsigned long *) child_regs->ar_bspstore;
 	krbs = (unsigned long *) child + IA64_RBS_OFFSET/8;
-	if (on_kernel_rbs(addr, (unsigned long) bspstore, (unsigned long) urbs_end)) {
+	if (on_kernel_rbs(addr, (unsigned long) bspstore,
+			  (unsigned long) urbs_end))
+	{
 		/*
-		 * Attempt to read the RBS in an area that's actually on the kernel RBS =>
-		 * read the corresponding bits in the kernel RBS.
+		 * Attempt to read the RBS in an area that's actually
+		 * on the kernel RBS => read the corresponding bits in
+		 * the kernel RBS.
 		 */
 		rnat_addr = ia64_rse_rnat_addr(laddr);
 		ret = get_rnat(child, child_stack, krbs, rnat_addr, urbs_end);
@@ -413,18 +430,23 @@
 
 		if (((1UL << ia64_rse_slot_num(laddr)) & ret) != 0) {
 			/*
-			 * It is implementation dependent whether the data portion of a
-			 * NaT value gets saved on a st8.spill or RSE spill (e.g., see
-			 * EAS 2.6, 4.4.4.6 Register Spill and Fill).  To get consistent
-			 * behavior across all possible IA-64 implementations, we return
-			 * zero in this case.
+			 * It is implementation dependent whether the
+			 * data portion of a NaT value gets saved on a
+			 * st8.spill or RSE spill (e.g., see EAS 2.6,
+			 * 4.4.4.6 Register Spill and Fill).  To get
+			 * consistent behavior across all possible
+			 * IA-64 implementations, we return zero in
+			 * this case.
 			 */
 			*val = 0;
 			return 0;
 		}
 
 		if (laddr < urbs_end) {
-			/* the desired word is on the kernel RBS and is not a NaT */
+			/*
+			 * The desired word is on the kernel RBS and
+			 * is not a NaT.
+			 */
 			regnum = ia64_rse_num_regs(bspstore, laddr);
 			*val = *ia64_rse_skip_regs(krbs, regnum);
 			return 0;
@@ -438,43 +460,51 @@
 }
 
 long
-ia64_poke (struct task_struct *child, struct switch_stack *child_stack, unsigned long user_rbs_end,
-	   unsigned long addr, long val)
+ia64_poke (struct task_struct *child, struct switch_stack *child_stack,
+	   unsigned long user_rbs_end, unsigned long addr, long val)
 {
-	unsigned long *bspstore, *krbs, regnum, *laddr, *urbs_end = (long *) user_rbs_end;
+	unsigned long *bspstore, *krbs, regnum, *laddr;
+	unsigned long *urbs_end = (long *) user_rbs_end;
 	struct pt_regs *child_regs;
 
 	laddr = (unsigned long *) addr;
 	child_regs = ia64_task_regs(child);
 	bspstore = (unsigned long *) child_regs->ar_bspstore;
 	krbs = (unsigned long *) child + IA64_RBS_OFFSET/8;
-	if (on_kernel_rbs(addr, (unsigned long) bspstore, (unsigned long) urbs_end)) {
+	if (on_kernel_rbs(addr, (unsigned long) bspstore,
+			  (unsigned long) urbs_end))
+	{
 		/*
-		 * Attempt to write the RBS in an area that's actually on the kernel RBS
-		 * => write the corresponding bits in the kernel RBS.
+		 * Attempt to write the RBS in an area that's actually
+		 * on the kernel RBS => write the corresponding bits
+		 * in the kernel RBS.
 		 */
 		if (ia64_rse_is_rnat_slot(laddr))
-			put_rnat(child, child_stack, krbs, laddr, val, urbs_end);
+			put_rnat(child, child_stack, krbs, laddr, val,
+				 urbs_end);
 		else {
 			if (laddr < urbs_end) {
 				regnum = ia64_rse_num_regs(bspstore, laddr);
 				*ia64_rse_skip_regs(krbs, regnum) = val;
 			}
 		}
-	} else if (access_process_vm(child, addr, &val, sizeof(val), 1) != sizeof(val)) {
+	} else if (access_process_vm(child, addr, &val, sizeof(val), 1)
+		   != sizeof(val))
 		return -EIO;
-	}
 	return 0;
 }
 
 /*
- * Calculate the address of the end of the user-level register backing store.  This is the
- * address that would have been stored in ar.bsp if the user had executed a "cover"
- * instruction right before entering the kernel.  If CFMP is not NULL, it is used to
- * return the "current frame mask" that was active at the time the kernel was entered.
+ * Calculate the address of the end of the user-level register backing
+ * store.  This is the address that would have been stored in ar.bsp
+ * if the user had executed a "cover" instruction right before
+ * entering the kernel.  If CFMP is not NULL, it is used to return the
+ * "current frame mask" that was active at the time the kernel was
+ * entered.
  */
 unsigned long
-ia64_get_user_rbs_end (struct task_struct *child, struct pt_regs *pt, unsigned long *cfmp)
+ia64_get_user_rbs_end (struct task_struct *child, struct pt_regs *pt,
+		       unsigned long *cfmp)
 {
 	unsigned long *krbs, *bspstore, cfm = pt->cr_ifs;
 	long ndirty;
@@ -494,9 +524,11 @@
 }
 
 /*
- * Synchronize (i.e, write) the RSE backing store living in kernel space to the VM of the
- * CHILD task.  SW and PT are the pointers to the switch_stack and pt_regs structures,
- * respectively.  USER_RBS_END is the user-level address at which the backing store ends.
+ * Synchronize (i.e, write) the RSE backing store living in kernel
+ * space to the VM of the CHILD task.  SW and PT are the pointers to
+ * the switch_stack and pt_regs structures, respectively.
+ * USER_RBS_END is the user-level address at which the backing store
+ * ends.
  */
 long
 ia64_sync_user_rbs (struct task_struct *child, struct switch_stack *sw,
@@ -510,7 +542,8 @@
 		ret = ia64_peek(child, sw, user_rbs_end, addr, &val);
 		if (ret < 0)
 			return ret;
-		if (access_process_vm(child, addr, &val, sizeof(val), 1) != sizeof(val))
+		if (access_process_vm(child, addr, &val, sizeof(val), 1)
+		    != sizeof(val))
 			return -EIO;
 	}
 	return 0;
@@ -524,13 +557,14 @@
 
 	if (ptrace_check_attach(thread, 0) < 0)
 		/*
-		 * If the thread is not in an attachable state, we'll ignore it.
-		 * The net effect is that if ADDR happens to overlap with the
-		 * portion of the thread's register backing store that is
-		 * currently residing on the thread's kernel stack, then ptrace()
-		 * may end up accessing a stale value.  But if the thread isn't
-		 * stopped, that's a problem anyhow, so we're doing as well as we
-		 * can...
+		 * If the thread is not in an attachable state, we'll
+		 * ignore it.  The net effect is that if ADDR happens
+		 * to overlap with the portion of the thread's
+		 * register backing store that is currently residing
+		 * on the thread's kernel stack, then ptrace() may end
+		 * up accessing a stale value.  But if the thread
+		 * isn't stopped, that's a problem anyhow, so we're
+		 * doing as well as we can...
 		 */
 		return 0;
 
@@ -543,10 +577,11 @@
 }
 
 /*
- * GDB apparently wants to be able to read the register-backing store of any thread when
- * attached to a given process.  If we are peeking or poking an address that happens to
- * reside in the kernel-backing store of another thread, we need to attach to that thread,
- * because otherwise we end up accessing stale data.
+ * GDB apparently wants to be able to read the register-backing store
+ * of any thread when attached to a given process.  If we are peeking
+ * or poking an address that happens to reside in the kernel-backing
+ * store of another thread, we need to attach to that thread, because
+ * otherwise we end up accessing stale data.
  *
  * task_list_lock must be read-locked before calling this routine!
  */
@@ -560,7 +595,8 @@
 	if (!(mm = get_task_mm(child)))
 		return child;
 
-	mm_users = atomic_read(&mm->mm_users) - 1;	/* -1 because of our get_task_mm()... */
+	/* -1 because of our get_task_mm(): */
+	mm_users = atomic_read(&mm->mm_users) - 1;
 	if (mm_users <= 1)
 		goto out;		/* not multi-threaded */
 
@@ -630,7 +666,8 @@
 }
 
 static int
-access_fr (struct unw_frame_info *info, int regnum, int hi, unsigned long *data, int write_access)
+access_fr (struct unw_frame_info *info, int regnum, int hi,
+	   unsigned long *data, int write_access)
 {
 	struct ia64_fpreg fpval;
 	int ret;
@@ -652,7 +689,8 @@
  * kernel exit-path, rather than the syscall-exit path.
  */
 static void
-convert_to_non_syscall (struct task_struct *child, struct pt_regs  *pt, unsigned long cfm)
+convert_to_non_syscall (struct task_struct *child, struct pt_regs  *pt,
+			unsigned long cfm)
 {
 	struct unw_frame_info info, prev_info;
 	unsigned long ip, pr;
@@ -677,11 +715,51 @@
 }
 
 static int
-access_uarea (struct task_struct *child, unsigned long addr, unsigned long *data, int write_access)
+access_nat_bits (struct task_struct *child, struct pt_regs *pt,
+		 struct unw_frame_info *info,
+		 unsigned long *data, int write_access)
+{
+	unsigned long regnum, nat_bits, scratch_unat, dummy = 0;
+	char nat = 0;
+
+	if (write_access) {
+		nat_bits = *data;
+		scratch_unat = ia64_put_scratch_nat_bits(pt, nat_bits);
+		if (unw_set_ar(info, UNW_AR_UNAT, scratch_unat) < 0) {
+			dprintk("ptrace: failed to set ar.unat\n");
+			return -1;
+		}
+		for (regnum = 4; regnum <= 7; ++regnum) {
+			unw_get_gr(info, regnum, &dummy, &nat);
+			unw_set_gr(info, regnum, dummy,
+				   (nat_bits >> regnum) & 1);
+		}
+	} else {
+		if (unw_get_ar(info, UNW_AR_UNAT, &scratch_unat) < 0) {
+			dprintk("ptrace: failed to read ar.unat\n");
+			return -1;
+		}
+		nat_bits = ia64_get_scratch_nat_bits(pt, scratch_unat);
+		for (regnum = 4; regnum <= 7; ++regnum) {
+			unw_get_gr(info, regnum, &dummy, &nat);
+			nat_bits |= (nat != 0) << regnum;
+		}
+		*data = nat_bits;
+	}
+	return 0;
+}
+
+static int
+access_uarea (struct task_struct *child, unsigned long addr,
+	      unsigned long *data, int write_access)
 {
 	unsigned long *ptr, regnum, urbs_end, rnat_addr, cfm;
 	struct switch_stack *sw;
 	struct pt_regs *pt;
+#	define pt_reg_addr(pt, reg)	((void *)			    \
+					 ((unsigned long) (pt)		    \
+					  + offsetof(struct pt_regs, reg)))
+
 
 	pt = ia64_task_regs(child);
 	sw = (struct switch_stack *) (child->thread.ksp + 16);
@@ -697,17 +775,20 @@
 			ia64_sync_fph(child);
 		else
 			ia64_flush_fph(child);
-		ptr = (unsigned long *) ((unsigned long) &child->thread.fph + addr);
+		ptr = (unsigned long *)
+			((unsigned long) &child->thread.fph + addr);
 	} else if ((addr >= PT_F10) && (addr < PT_F11 + 16)) {
 		/* scratch registers untouched by kernel (saved in pt_regs) */
-		ptr = (unsigned long *)
-			((long) pt + offsetof(struct pt_regs, f10) + addr - PT_F10);
+		ptr = pt_reg_addr(pt, f10) + (addr - PT_F10);
 	} else if (addr >= PT_F12 && addr < PT_F15 + 16) {
-		/* scratch registers untouched by kernel (saved in switch_stack) */
-		ptr = (unsigned long *) ((long) sw + (addr - PT_NAT_BITS - 32));
+		/*
+		 * Scratch registers untouched by kernel (saved in
+		 * switch_stack).
+		 */
+		ptr = (unsigned long *) ((long) sw
+					 + (addr - PT_NAT_BITS - 32));
 	} else if (addr < PT_AR_LC + 8) {
 		/* preserved state: */
-		unsigned long nat_bits, scratch_unat, dummy = 0;
 		struct unw_frame_info info;
 		char nat = 0;
 		int ret;
@@ -718,62 +799,48 @@
 
 		switch (addr) {
 		      case PT_NAT_BITS:
-			if (write_access) {
-				nat_bits = *data;
-				scratch_unat = ia64_put_scratch_nat_bits(pt, nat_bits);
-				if (unw_set_ar(&info, UNW_AR_UNAT, scratch_unat) < 0) {
-					dprintk("ptrace: failed to set ar.unat\n");
-					return -1;
-				}
-				for (regnum = 4; regnum <= 7; ++regnum) {
-					unw_get_gr(&info, regnum, &dummy, &nat);
-					unw_set_gr(&info, regnum, dummy, (nat_bits >> regnum) & 1);
-				}
-			} else {
-				if (unw_get_ar(&info, UNW_AR_UNAT, &scratch_unat) < 0) {
-					dprintk("ptrace: failed to read ar.unat\n");
-					return -1;
-				}
-				nat_bits = ia64_get_scratch_nat_bits(pt, scratch_unat);
-				for (regnum = 4; regnum <= 7; ++regnum) {
-					unw_get_gr(&info, regnum, &dummy, &nat);
-					nat_bits |= (nat != 0) << regnum;
-				}
-				*data = nat_bits;
-			}
-			return 0;
+			return access_nat_bits(child, pt, &info,
+					       data, write_access);
 
 		      case PT_R4: case PT_R5: case PT_R6: case PT_R7:
 			if (write_access) {
 				/* read NaT bit first: */
 				unsigned long dummy;
 
-				ret = unw_get_gr(&info, (addr - PT_R4)/8 + 4, &dummy, &nat);
+				ret = unw_get_gr(&info, (addr - PT_R4)/8 + 4,
+						 &dummy, &nat);
 				if (ret < 0)
 					return ret;
 			}
-			return unw_access_gr(&info, (addr - PT_R4)/8 + 4, data, &nat,
-					     write_access);
+			return unw_access_gr(&info, (addr - PT_R4)/8 + 4, data,
+					     &nat, write_access);
 
-		      case PT_B1: case PT_B2: case PT_B3: case PT_B4: case PT_B5:
-			return unw_access_br(&info, (addr - PT_B1)/8 + 1, data, write_access);
+		      case PT_B1: case PT_B2: case PT_B3:
+		      case PT_B4: case PT_B5:
+			return unw_access_br(&info, (addr - PT_B1)/8 + 1, data,
+					     write_access);
 
 		      case PT_AR_EC:
-			return unw_access_ar(&info, UNW_AR_EC, data, write_access);
+			return unw_access_ar(&info, UNW_AR_EC, data,
+					     write_access);
 
 		      case PT_AR_LC:
-			return unw_access_ar(&info, UNW_AR_LC, data, write_access);
+			return unw_access_ar(&info, UNW_AR_LC, data,
+					     write_access);
 
 		      default:
 			if (addr >= PT_F2 && addr < PT_F5 + 16)
-				return access_fr(&info, (addr - PT_F2)/16 + 2, (addr & 8) != 0,
-						 data, write_access);
+				return access_fr(&info, (addr - PT_F2)/16 + 2,
+						 (addr & 8) != 0, data,
+						 write_access);
 			else if (addr >= PT_F16 && addr < PT_F31 + 16)
-				return access_fr(&info, (addr - PT_F16)/16 + 16, (addr & 8) != 0,
+				return access_fr(&info,
+						 (addr - PT_F16)/16 + 16,
+						 (addr & 8) != 0,
 						 data, write_access);
 			else {
-				dprintk("ptrace: rejecting access to register address 0x%lx\n",
-					addr);
+				dprintk("ptrace: rejecting access to register "
+					"address 0x%lx\n", addr);
 				return -1;
 			}
 		}
@@ -782,34 +849,49 @@
 		switch (addr) {
 		      case PT_AR_BSP:
 			/*
-			 * By convention, we use PT_AR_BSP to refer to the end of the user-level
-			 * backing store.  Use ia64_rse_skip_regs(PT_AR_BSP, -CFM.sof) to get
-			 * the real value of ar.bsp at the time the kernel was entered.
+			 * By convention, we use PT_AR_BSP to refer to
+			 * the end of the user-level backing store.
+			 * Use ia64_rse_skip_regs(PT_AR_BSP, -CFM.sof)
+			 * to get the real value of ar.bsp at the time
+			 * the kernel was entered.
 			 *
-			 * Furthermore, when changing the contents of PT_AR_BSP (or
-			 * PT_CFM) we MUST copy any users-level stacked registers that are
-			 * stored on the kernel stack back to user-space because
-			 * otherwise, we might end up clobbering kernel stacked registers.
-			 * Also, if this happens while the task is blocked in a system
-			 * call, which convert the state such that the non-system-call
-			 * exit path is used.  This ensures that the proper state will be
-			 * picked up when resuming execution.  However, it *also* means
-			 * that once we write PT_AR_BSP/PT_CFM, it won't be possible to
-			 * modify the syscall arguments of the pending system call any
-			 * longer.  This shouldn't be an issue because modifying
-			 * PT_AR_BSP/PT_CFM generally implies that we're either abandoning
-			 * the pending system call or that we defer it's re-execution
-			 * (e.g., due to GDB doing an inferior function call).
+			 * Furthermore, when changing the contents of
+			 * PT_AR_BSP (or PT_CFM) we MUST copy any
+			 * users-level stacked registers that are
+			 * stored on the kernel stack back to
+			 * user-space because otherwise, we might end
+			 * up clobbering kernel stacked registers.
+			 * Also, if this happens while the task is
+			 * blocked in a system call, which convert the
+			 * state such that the non-system-call exit
+			 * path is used.  This ensures that the proper
+			 * state will be picked up when resuming
+			 * execution.  However, it *also* means that
+			 * once we write PT_AR_BSP/PT_CFM, it won't be
+			 * possible to modify the syscall arguments of
+			 * the pending system call any longer.  This
+			 * shouldn't be an issue because modifying
+			 * PT_AR_BSP/PT_CFM generally implies that
+			 * we're either abandoning the pending system
+			 * call or that we defer it's re-execution
+			 * (e.g., due to GDB doing an inferior
+			 * function call).
 			 */
 			urbs_end = ia64_get_user_rbs_end(child, pt, &cfm);
 			if (write_access) {
 				if (*data != urbs_end) {
 					if (ia64_sync_user_rbs(child, sw,
-							       pt->ar_bspstore, urbs_end) < 0)
+							       pt->ar_bspstore,
+							       urbs_end) < 0)
 						return -1;
 					if (in_syscall(pt))
-						convert_to_non_syscall(child, pt, cfm);
-					/* simulate user-level write of ar.bsp: */
+						convert_to_non_syscall(child,
+								       pt,
+								       cfm);
+					/*
+					 * Simulate user-level write
+					 * of ar.bsp:
+					 */
 					pt->loadrs = 0;
 					pt->ar_bspstore = *data;
 				}
@@ -820,14 +902,17 @@
 		      case PT_CFM:
 			urbs_end = ia64_get_user_rbs_end(child, pt, &cfm);
 			if (write_access) {
-				if (((cfm ^ *data) & 0x3fffffffffUL) != 0) {
+				if (((cfm ^ *data) & PFM_MASK) != 0) {
 					if (ia64_sync_user_rbs(child, sw,
-							       pt->ar_bspstore, urbs_end) < 0)
+							       pt->ar_bspstore,
+							       urbs_end) < 0)
 						return -1;
 					if (in_syscall(pt))
-						convert_to_non_syscall(child, pt, cfm);
-					pt->cr_ifs = ((pt->cr_ifs & ~0x3fffffffffUL)
-						      | (*data & 0x3fffffffffUL));
+						convert_to_non_syscall(child,
+								       pt,
+								       cfm);
+					pt->cr_ifs = ((pt->cr_ifs & ~PFM_MASK)
+						      | (*data & PFM_MASK));
 				}
 			} else
 				*data = cfm;
@@ -835,99 +920,94 @@
 
 		      case PT_CR_IPSR:
 			if (write_access)
-				pt->cr_ipsr = ((*data & IPSR_WRITE_MASK)
-					       | (pt->cr_ipsr & ~IPSR_WRITE_MASK));
+				pt->cr_ipsr = ((*data & IPSR_MASK)
+					       | (pt->cr_ipsr & ~IPSR_MASK));
 			else
-				*data = (pt->cr_ipsr & IPSR_READ_MASK);
+				*data = (pt->cr_ipsr & IPSR_MASK);
 			return 0;
 
 		      case PT_AR_RNAT:
 			urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
-			rnat_addr = (long) ia64_rse_rnat_addr((long *) urbs_end);
+			rnat_addr = (long) ia64_rse_rnat_addr((long *)
+							      urbs_end);
 			if (write_access)
-				return ia64_poke(child, sw, urbs_end, rnat_addr, *data);
+				return ia64_poke(child, sw, urbs_end,
+						 rnat_addr, *data);
 			else
-				return ia64_peek(child, sw, urbs_end, rnat_addr, data);
+				return ia64_peek(child, sw, urbs_end,
+						 rnat_addr, data);
 
 		      case PT_R1:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, r1));
+			ptr = pt_reg_addr(pt, r1);
 			break;
-
 		      case PT_R2:  case PT_R3:
-			ptr = (unsigned long *)
-				((long) pt + offsetof(struct pt_regs, r2) + addr - PT_R2);
+			ptr = pt_reg_addr(pt, r2) + (addr - PT_R2);
 			break;
 		      case PT_R8:  case PT_R9:  case PT_R10: case PT_R11:
-			ptr = (unsigned long *)
-				((long) pt + offsetof(struct pt_regs, r8)+  addr - PT_R8);
+			ptr = pt_reg_addr(pt, r8) + (addr - PT_R8);
 			break;
 		      case PT_R12: case PT_R13:
-			ptr = (unsigned long *)
-				((long) pt + offsetof(struct pt_regs, r12)+  addr - PT_R12);
+			ptr = pt_reg_addr(pt, r12) + (addr - PT_R12);
 			break;
 		      case PT_R14:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, r14));
+			ptr = pt_reg_addr(pt, r14);
 			break;
 		      case PT_R15:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, r15));
+			ptr = pt_reg_addr(pt, r15);
 			break;
 		      case PT_R16: case PT_R17: case PT_R18: case PT_R19:
 		      case PT_R20: case PT_R21: case PT_R22: case PT_R23:
 		      case PT_R24: case PT_R25: case PT_R26: case PT_R27:
 		      case PT_R28: case PT_R29: case PT_R30: case PT_R31:
-			ptr = (unsigned long *)
-				((long) pt + offsetof(struct pt_regs, r16) + addr - PT_R16);
+			ptr = pt_reg_addr(pt, r16) + (addr - PT_R16);
 			break;
 		      case PT_B0:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, b0));
+			ptr = pt_reg_addr(pt, b0);
 			break;
 		      case PT_B6:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, b6));
+			ptr = pt_reg_addr(pt, b6);
 			break;
 		      case PT_B7:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, b7));
+			ptr = pt_reg_addr(pt, b7);
 			break;
 		      case PT_F6:  case PT_F6+8: case PT_F7: case PT_F7+8:
 		      case PT_F8:  case PT_F8+8: case PT_F9: case PT_F9+8:
-			ptr = (unsigned long *)
-				((long) pt + offsetof(struct pt_regs, f6) + addr - PT_F6);
+			ptr = pt_reg_addr(pt, f6) + (addr - PT_F6);
 			break;
 		      case PT_AR_BSPSTORE:
-			ptr = (unsigned long *)
-				((long) pt + offsetof(struct pt_regs, ar_bspstore));
+			ptr = pt_reg_addr(pt, ar_bspstore);
 			break;
 		      case PT_AR_RSC:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, ar_rsc));
+			ptr = pt_reg_addr(pt, ar_rsc);
 			break;
 		      case PT_AR_UNAT:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, ar_unat));
+			ptr = pt_reg_addr(pt, ar_unat);
 			break;
 		      case PT_AR_PFS:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, ar_pfs));
+			ptr = pt_reg_addr(pt, ar_pfs);
 			break;
 		      case PT_AR_CCV:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, ar_ccv));
+			ptr = pt_reg_addr(pt, ar_ccv);
 			break;
 		      case PT_AR_FPSR:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, ar_fpsr));
+			ptr = pt_reg_addr(pt, ar_fpsr);
 			break;
 		      case PT_CR_IIP:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, cr_iip));
+			ptr = pt_reg_addr(pt, cr_iip);
 			break;
 		      case PT_PR:
-			ptr = (unsigned long *) ((long) pt + offsetof(struct pt_regs, pr));
+			ptr = pt_reg_addr(pt, pr);
 			break;
 			/* scratch register */
 
 		      default:
 			/* disallow accessing anything else... */
-			dprintk("ptrace: rejecting access to register address 0x%lx\n",
-				addr);
+			dprintk("ptrace: rejecting access to register "
+				"address 0x%lx\n", addr);
 			return -1;
 		}
 	} else if (addr <= PT_AR_SSD) {
-		ptr = (unsigned long *)
-			((long) pt + offsetof(struct pt_regs, ar_csd) + addr - PT_AR_CSD);
+		ptr = pt_reg_addr(pt, ar_csd) + (addr - PT_AR_CSD);
 	} else {
 		/* access debug registers */
 
@@ -940,37 +1020,43 @@
 		}
 
 		if (regnum >= 8) {
-			dprintk("ptrace: rejecting access to register address 0x%lx\n", addr);
+			dprintk("ptrace: rejecting access to register "
+				"address 0x%lx\n", addr);
 			return -1;
 		}
 #ifdef CONFIG_PERFMON
 		/*
-		 * Check if debug registers are used by perfmon. This test must be done
-		 * once we know that we can do the operation, i.e. the arguments are all
-		 * valid, but before we start modifying the state.
+		 * Check if debug registers are used by perfmon. This
+		 * test must be done once we know that we can do the
+		 * operation, i.e. the arguments are all valid, but
+		 * before we start modifying the state.
 		 *
-		 * Perfmon needs to keep a count of how many processes are trying to
-		 * modify the debug registers for system wide monitoring sessions.
+		 * Perfmon needs to keep a count of how many processes
+		 * are trying to modify the debug registers for system
+		 * wide monitoring sessions.
 		 *
-		 * We also include read access here, because they may cause the
-		 * PMU-installed debug register state (dbr[], ibr[]) to be reset. The two
-		 * arrays are also used by perfmon, but we do not use
-		 * IA64_THREAD_DBG_VALID. The registers are restored by the PMU context
-		 * switch code.
+		 * We also include read access here, because they may
+		 * cause the PMU-installed debug register state
+		 * (dbr[], ibr[]) to be reset. The two arrays are also
+		 * used by perfmon, but we do not use
+		 * IA64_THREAD_DBG_VALID. The registers are restored
+		 * by the PMU context switch code.
 		 */
 		if (pfm_use_debug_registers(child)) return -1;
 #endif
 
 		if (!(child->thread.flags & IA64_THREAD_DBG_VALID)) {
 			child->thread.flags |= IA64_THREAD_DBG_VALID;
-			memset(child->thread.dbr, 0, sizeof(child->thread.dbr));
-			memset(child->thread.ibr, 0, sizeof(child->thread.ibr));
+			memset(child->thread.dbr, 0,
+			       sizeof(child->thread.dbr));
+			memset(child->thread.ibr, 0,
+			       sizeof(child->thread.ibr));
 		}
 
 		ptr += regnum;
 
 		if (write_access)
-			/* don't let the user set kernel-level breakpoints... */
+			/* don't let the user set kernel-level breakpoints: */
 			*ptr = *data & ~(7UL << 56);
 		else
 			*data = *ptr;
@@ -995,7 +1081,8 @@
 	char nat = 0;
 	int i;
 
-	retval = verify_area(VERIFY_WRITE, ppr, sizeof(struct pt_all_user_regs));
+	retval = verify_area(VERIFY_WRITE, ppr,
+			     sizeof(struct pt_all_user_regs));
 	if (retval != 0) {
 		return -EIO;
 	}
@@ -1097,11 +1184,13 @@
 
 	/* fr6-fr11 */
 
-	retval |= __copy_to_user(&ppr->fr[6], &pt->f6, sizeof(struct ia64_fpreg) * 6);
+	retval |= __copy_to_user(&ppr->fr[6], &pt->f6,
+				 sizeof(struct ia64_fpreg) * 6);
 
 	/* fp scratch regs(12-15) */
 
-	retval |= __copy_to_user(&ppr->fr[12], &sw->f12, sizeof(struct ia64_fpreg) * 4);
+	retval |= __copy_to_user(&ppr->fr[12], &sw->f12,
+				 sizeof(struct ia64_fpreg) * 4);
 
 	/* fr16-fr31 */
 
@@ -1114,7 +1203,8 @@
 	/* fph */
 
 	ia64_flush_fph(child);
-	retval |= __copy_to_user(&ppr->fr[32], &child->thread.fph, sizeof(ppr->fr[32]) * 96);
+	retval |= __copy_to_user(&ppr->fr[32], &child->thread.fph,
+				 sizeof(ppr->fr[32]) * 96);
 
 	/*  preds */
 
@@ -1141,7 +1231,8 @@
 
 	memset(&fpval, 0, sizeof(fpval));
 
-	retval = verify_area(VERIFY_READ, ppr, sizeof(struct pt_all_user_regs));
+	retval = verify_area(VERIFY_READ, ppr,
+			     sizeof(struct pt_all_user_regs));
 	if (retval != 0) {
 		return -EIO;
 	}
@@ -1189,7 +1280,8 @@
 
 	for (i = 4; i < 8; i++) {
 		retval |= __get_user(val, &ppr->gr[i]);
-		if (unw_set_gr(&info, i, val, 0) < 0)	 /* NaT bit will be set via PT_NAT_BITS */
+		/* NaT bit will be set via PT_NAT_BITS: */
+		if (unw_set_gr(&info, i, val, 0) < 0)
 			return -EIO;
 	}
 
@@ -1233,16 +1325,19 @@
 
 	/* fr6-fr11 */
 
-	retval |= __copy_from_user(&pt->f6, &ppr->fr[6], sizeof(ppr->fr[6]) * 6);
+	retval |= __copy_from_user(&pt->f6, &ppr->fr[6],
+				   sizeof(ppr->fr[6]) * 6);
 
 	/* fp scratch regs(12-15) */
 
-	retval |= __copy_from_user(&sw->f12, &ppr->fr[12], sizeof(ppr->fr[12]) * 4);
+	retval |= __copy_from_user(&sw->f12, &ppr->fr[12],
+				   sizeof(ppr->fr[12]) * 4);
 
 	/* fr16-fr31 */
 
 	for (i = 16; i < 32; i++) {
-		retval |= __copy_from_user(&fpval, &ppr->fr[i], sizeof(fpval));
+		retval |= __copy_from_user(&fpval, &ppr->fr[i],
+					   sizeof(fpval));
 		if (unw_set_fr(&info, i, fpval) < 0)
 			return -EIO;
 	}
@@ -1250,7 +1345,8 @@
 	/* fph */
 
 	ia64_sync_fph(child);
-	retval |= __copy_from_user(&child->thread.fph, &ppr->fr[32], sizeof(ppr->fr[32]) * 96);
+	retval |= __copy_from_user(&child->thread.fph, &ppr->fr[32],
+				   sizeof(ppr->fr[32]) * 96);
 
 	/* preds */
 
@@ -1311,8 +1407,10 @@
 		goto out;
 	}
 
-	peek_or_poke = (request = PTRACE_PEEKTEXT || request = PTRACE_PEEKDATA
-			|| request = PTRACE_POKETEXT || request = PTRACE_POKEDATA);
+	peek_or_poke = (request = PTRACE_PEEKTEXT
+			|| request = PTRACE_PEEKDATA
+			|| request = PTRACE_POKETEXT
+			|| request = PTRACE_POKEDATA);
 	ret = -ESRCH;
 	read_lock(&tasklist_lock);
 	{
@@ -1344,31 +1442,37 @@
 
 	switch (request) {
 	      case PTRACE_PEEKTEXT:
-	      case PTRACE_PEEKDATA:		/* read word at location addr */
+	      case PTRACE_PEEKDATA:
+		/* read word at location addr */
 		urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
 		ret = ia64_peek(child, sw, urbs_end, addr, &data);
 		if (ret = 0) {
 			ret = data;
-			regs->r8 = 0;	/* ensure "ret" is not mistaken as an error code */
+			/* ensure "ret" is not mistaken as an error code: */
+			regs->r8 = 0;
 		}
 		goto out_tsk;
 
 	      case PTRACE_POKETEXT:
-	      case PTRACE_POKEDATA:		/* write the word at location addr */
+	      case PTRACE_POKEDATA:
+		/* write the word at location addr */
 		urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
 		ret = ia64_poke(child, sw, urbs_end, addr, data);
 		goto out_tsk;
 
-	      case PTRACE_PEEKUSR:		/* read the word at addr in the USER area */
+	      case PTRACE_PEEKUSR:
+		/* read the word at addr in the USER area */
 		if (access_uarea(child, addr, &data, 0) < 0) {
 			ret = -EIO;
 			goto out_tsk;
 		}
 		ret = data;
-		regs->r8 = 0;	/* ensure "ret" is not mistaken as an error code */
+		/* ensure "ret" is not mistaken as an error code */
+		regs->r8 = 0;
 		goto out_tsk;
 
-	      case PTRACE_POKEUSR:	      /* write the word at addr in the USER area */
+	      case PTRACE_POKEUSR:
+		/* write the word at addr in the USER area */
 		if (access_uarea(child, addr, &data, 1) < 0) {
 			ret = -EIO;
 			goto out_tsk;
@@ -1376,16 +1480,20 @@
 		ret = 0;
 		goto out_tsk;
 
-	      case PTRACE_OLD_GETSIGINFO:		/* for backwards-compatibility */
+	      case PTRACE_OLD_GETSIGINFO:
+		/* for backwards-compatibility */
 		ret = ptrace_request(child, PTRACE_GETSIGINFO, addr, data);
 		goto out_tsk;
 
-	      case PTRACE_OLD_SETSIGINFO:		/* for backwards-compatibility */
+	      case PTRACE_OLD_SETSIGINFO:
+		/* for backwards-compatibility */
 		ret = ptrace_request(child, PTRACE_SETSIGINFO, addr, data);
 		goto out_tsk;
 
-	      case PTRACE_SYSCALL:	/* continue and stop at next (return from) syscall */
-	      case PTRACE_CONT:		/* restart after signal. */
+	      case PTRACE_SYSCALL:
+		/* continue and stop at next (return from) syscall */
+	      case PTRACE_CONT:
+		/* restart after signal. */
 		ret = -EIO;
 		if (data > _NSIG)
 			goto out_tsk;
@@ -1395,7 +1503,10 @@
 			clear_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
 		child->exit_code = data;
 
-		/* make sure the single step/taken-branch trap bits are not set: */
+		/*
+		 * Make sure the single step/taken-branch trap bits
+		 * are not set:
+		 */
 		ia64_psr(pt)->ss = 0;
 		ia64_psr(pt)->tb = 0;
 
@@ -1409,11 +1520,15 @@
 		 * sigkill.  Perhaps it should be put in the status
 		 * that it wants to exit.
 		 */
-		if (child->exit_state = EXIT_ZOMBIE)		/* already dead */
+		if (child->exit_state = EXIT_ZOMBIE)
+			/* already dead */
 			goto out_tsk;
 		child->exit_code = SIGKILL;
 
-		/* make sure the single step/take-branch tra bits are not set: */
+		/*
+		 * Make sure the single step/take-branch trap bits are
+		 * not set:
+		 */
 		ia64_psr(pt)->ss = 0;
 		ia64_psr(pt)->tb = 0;
 
@@ -1421,7 +1536,8 @@
 		ret = 0;
 		goto out_tsk;
 
-	      case PTRACE_SINGLESTEP:		/* let child execute for one instruction */
+	      case PTRACE_SINGLESTEP:
+		/* let child execute for one instruction */
 	      case PTRACE_SINGLEBLOCK:
 		ret = -EIO;
 		if (data > _NSIG)
@@ -1440,16 +1556,19 @@
 		ret = 0;
 		goto out_tsk;
 
-	      case PTRACE_DETACH:		/* detach a process that was attached. */
+	      case PTRACE_DETACH:
+		/* detach a process that was attached. */
 		ret = ptrace_detach(child, data);
 		goto out_tsk;
 
 	      case PTRACE_GETREGS:
-		ret = ptrace_getregs(child, (struct pt_all_user_regs __user *) data);
+		ret = ptrace_getregs(child,
+				     (struct pt_all_user_regs __user *) data);
 		goto out_tsk;
 
 	      case PTRACE_SETREGS:
-		ret = ptrace_setregs(child, (struct pt_all_user_regs __user *) data);
+		ret = ptrace_setregs(child,
+				     (struct pt_all_user_regs __user *) data);
 		goto out_tsk;
 
 	      default:
@@ -1472,15 +1591,16 @@
 	if (!(current->ptrace & PT_PTRACED))
 		return;
 	/*
-	 * The 0x80 provides a way for the tracing parent to distinguish between a syscall
-	 * stop and SIGTRAP delivery.
+	 * The 0x80 provides a way for the tracing parent to
+	 * distinguish between a syscall stop and SIGTRAP delivery.
 	 */
-	ptrace_notify(SIGTRAP | ((current->ptrace & PT_TRACESYSGOOD) ? 0x80 : 0));
+	ptrace_notify(SIGTRAP
+		      | ((current->ptrace & PT_TRACESYSGOOD) ? 0x80 : 0));
 
 	/*
-	 * This isn't the same as continuing with a signal, but it will do for normal use.
-	 * strace only continues with a signal if the stopping signal is not SIGTRAP.
-	 * -brl
+	 * This isn't the same as continuing with a signal, but it
+	 * will do for normal use.  strace only continues with a
+	 * signal if the stopping signal is not SIGTRAP.  -brl
 	 */
 	if (current->exit_code) {
 		send_sig(current->exit_code, current, 1);
@@ -1506,7 +1626,8 @@
 		audit_syscall_entry(current, syscall, arg0, arg1, arg2, arg3);
 	}
 
-	if (test_thread_flag(TIF_SYSCALL_TRACE) && (current->ptrace & PT_PTRACED))
+	if (test_thread_flag(TIF_SYSCALL_TRACE)
+	    && (current->ptrace & PT_PTRACED))
 		syscall_trace();
 }
 
@@ -1519,6 +1640,7 @@
 	if (unlikely(current->audit_context))
 		audit_syscall_exit(current, ((struct pt_regs *) &stack)->r8);
 
-	if (test_thread_flag(TIF_SYSCALL_TRACE) && (current->ptrace & PT_PTRACED))
+	if (test_thread_flag(TIF_SYSCALL_TRACE)
+	    && (current->ptrace & PT_PTRACED))
 		syscall_trace();
 }
