From: Keith Owens <kaos@sgi.com>
Date: Mon, 23 Feb 2004 02:46:28 +0000
Subject: [patch] 2.4.25 sync unwind code with 2.6.3
Message-Id: <3792.1077504388@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The unwind code in 2.4.25 has drifted away from the 2.6.3 version,
including some missing bug fixes.  This patch bring 2.4.25 unwind as
close to 2.6.3 as possible.  Changes are :-

* Move unw_table_entry from one header to another.
* Add Fenghua Yu's change to pt_regs_off.  This is not really in 2.4
  yet, even though the comment says it is.
* Comment and white space changes.
* Bug fix to alloc_reg_state().
* Replace struct_offset() with offsetof().
* Export unw_* symbols.
* Avoid deadlock on script->lock.


I am not happy with the kludge that avoids the deadlock on
script->lock, anybody got a better solution?  The kludge assumes that
the first field in an ia64 rwsem is a spinlock.  I have hit this unwind
deadlock a couple of times during processing of asynchronous MCA
events, so I want it fixed.

After this patch, the main differences between 2.4 and 2.6 are the
handing of the gate page and its DSO data.


Index: 25.4/include/asm-ia64/unwind.h
--- 25.4/include/asm-ia64/unwind.h Tue, 16 Sep 2003 19:32:24 +1000 kaos (linux-2.4/s/17_unwind.h 1.1.3.1.3.1.1.1.1.1 644)
+++ 25.4(w)/include/asm-ia64/unwind.h Mon, 23 Feb 2004 12:24:35 +1100 kaos (linux-2.4/s/17_unwind.h 1.1.3.1.3.1.1.1.1.1 644)
@@ -93,6 +93,12 @@ struct unw_frame_info {
  * The official API follows below:
  */
 
+struct unw_table_entry {
+	u64 start_offset;
+	u64 end_offset;
+	u64 info_offset;
+};
+
 /*
  * Initialize unwind support.
  */
Index: 25.4/arch/ia64/kernel/unwind_i.h
--- 25.4/arch/ia64/kernel/unwind_i.h Sun, 06 Jul 2003 14:16:24 +1000 kaos (linux-2.4/r/c/33_unwind_i.h 1.1.2.1.1.2.1.1 644)
+++ 25.4(w)/arch/ia64/kernel/unwind_i.h Mon, 23 Feb 2004 12:38:43 +1100 kaos (linux-2.4/r/c/33_unwind_i.h 1.1.2.1.1.2.1.1 644)
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2000, 2002 Hewlett-Packard Co
+ * Copyright (C) 2000, 2002-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Kernel unwind support.
@@ -45,12 +45,6 @@ struct unw_info_block {
 	/* personality routine and language-specific data follow behind descriptors */
 };
 
-struct unw_table_entry {
-	u64 start_offset;
-	u64 end_offset;
-	u64 info_offset;
-};
-
 struct unw_table {
 	struct unw_table *next;		/* must be first member! */
 	const char *name;
@@ -148,7 +142,7 @@ struct unw_insn {
 };
 
 /*
- * Preserved general static registers (r2-r5) give rise to two script
+ * Preserved general static registers (r4-r7) give rise to two script
  * instructions; everything else yields at most one instruction; at
  * the end of the script, the psp gets popped, accounting for one more
  * instruction.
Index: 25.4/arch/ia64/kernel/unwind.c
--- 25.4/arch/ia64/kernel/unwind.c Wed, 11 Feb 2004 11:17:55 +1100 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.1.2.3.1.1.1.1.3.1.1.1.2 644)
+++ 25.4(w)/arch/ia64/kernel/unwind.c Mon, 23 Feb 2004 12:38:43 +1100 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.1.2.3.1.1.1.1.3.1.1.1.2 644)
@@ -1,9 +1,8 @@
 /*
- * Copyright (C) 2003 Fenghua Yu <fenghua.yu@intel.com>
- * 	- Change pt_regs_off() to make it less dependant on pt_regs structure.
- *
  * Copyright (C) 1999-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2003 Fenghua Yu <fenghua.yu@intel.com>
+ * 	- Change pt_regs_off() to make it less dependant on pt_regs structure.
  */
 /*
  * This file implements call frame unwind support for the Linux
@@ -27,7 +26,9 @@
  *	o if both the unw.lock spinlock and a script's read-write lock must be
  *	  acquired, then the read-write lock must be acquired first.
  */
+#include <linux/module.h>
 #include <linux/bootmem.h>
+#include <linux/elf.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -79,7 +80,7 @@
 # define STAT(x...)
 #endif
 
-#define alloc_reg_state()	kmalloc(sizeof(struct unw_state_record), GFP_ATOMIC)
+#define alloc_reg_state()	kmalloc(sizeof(struct unw_reg_state), GFP_ATOMIC)
 #define free_reg_state(usr)	kfree(usr)
 #define alloc_labeled_state()	kmalloc(sizeof(struct unw_labeled_state), GFP_ATOMIC)
 #define free_labeled_state(usr)	kfree(usr)
@@ -87,8 +88,6 @@
 typedef unsigned long unw_word;
 typedef unsigned char unw_hash_index_t;
 
-#define struct_offset(str,fld)	((char *)&((str *)NULL)->fld - (char *) 0)
-
 static struct {
 	spinlock_t lock;			/* spinlock for unwind data */
 
@@ -107,6 +106,8 @@ static struct {
 	/* index into unw_frame_info for preserved register i */
 	unsigned short preg_index[UNW_NUM_REGS];
 
+	short pt_regs_offsets[32];
+
 	/* unwind table for the kernel: */
 	struct unw_table kernel_table;
 
@@ -156,47 +157,78 @@ static struct {
 		UNW_REG_UNAT, UNW_REG_LC, UNW_REG_FPSR, UNW_REG_PRI_UNAT_GR
 	},
 	.preg_index = {
-		struct_offset(struct unw_frame_info, pri_unat_loc)/8,	/* PRI_UNAT_GR */
-		struct_offset(struct unw_frame_info, pri_unat_loc)/8,	/* PRI_UNAT_MEM */
-		struct_offset(struct unw_frame_info, bsp_loc)/8,
-		struct_offset(struct unw_frame_info, bspstore_loc)/8,
-		struct_offset(struct unw_frame_info, pfs_loc)/8,
-		struct_offset(struct unw_frame_info, rnat_loc)/8,
-		struct_offset(struct unw_frame_info, psp)/8,
-		struct_offset(struct unw_frame_info, rp_loc)/8,
-		struct_offset(struct unw_frame_info, r4)/8,
-		struct_offset(struct unw_frame_info, r5)/8,
-		struct_offset(struct unw_frame_info, r6)/8,
-		struct_offset(struct unw_frame_info, r7)/8,
-		struct_offset(struct unw_frame_info, unat_loc)/8,
-		struct_offset(struct unw_frame_info, pr_loc)/8,
-		struct_offset(struct unw_frame_info, lc_loc)/8,
-		struct_offset(struct unw_frame_info, fpsr_loc)/8,
-		struct_offset(struct unw_frame_info, b1_loc)/8,
-		struct_offset(struct unw_frame_info, b2_loc)/8,
-		struct_offset(struct unw_frame_info, b3_loc)/8,
-		struct_offset(struct unw_frame_info, b4_loc)/8,
-		struct_offset(struct unw_frame_info, b5_loc)/8,
-		struct_offset(struct unw_frame_info, f2_loc)/8,
-		struct_offset(struct unw_frame_info, f3_loc)/8,
-		struct_offset(struct unw_frame_info, f4_loc)/8,
-		struct_offset(struct unw_frame_info, f5_loc)/8,
-		struct_offset(struct unw_frame_info, fr_loc[16 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[17 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[18 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[19 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[20 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[21 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[22 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[23 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[24 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[25 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[26 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[27 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[28 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[29 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[30 - 16])/8,
-		struct_offset(struct unw_frame_info, fr_loc[31 - 16])/8,
+		offsetof(struct unw_frame_info, pri_unat_loc)/8,	/* PRI_UNAT_GR */
+		offsetof(struct unw_frame_info, pri_unat_loc)/8,	/* PRI_UNAT_MEM */
+		offsetof(struct unw_frame_info, bsp_loc)/8,
+		offsetof(struct unw_frame_info, bspstore_loc)/8,
+		offsetof(struct unw_frame_info, pfs_loc)/8,
+		offsetof(struct unw_frame_info, rnat_loc)/8,
+		offsetof(struct unw_frame_info, psp)/8,
+		offsetof(struct unw_frame_info, rp_loc)/8,
+		offsetof(struct unw_frame_info, r4)/8,
+		offsetof(struct unw_frame_info, r5)/8,
+		offsetof(struct unw_frame_info, r6)/8,
+		offsetof(struct unw_frame_info, r7)/8,
+		offsetof(struct unw_frame_info, unat_loc)/8,
+		offsetof(struct unw_frame_info, pr_loc)/8,
+		offsetof(struct unw_frame_info, lc_loc)/8,
+		offsetof(struct unw_frame_info, fpsr_loc)/8,
+		offsetof(struct unw_frame_info, b1_loc)/8,
+		offsetof(struct unw_frame_info, b2_loc)/8,
+		offsetof(struct unw_frame_info, b3_loc)/8,
+		offsetof(struct unw_frame_info, b4_loc)/8,
+		offsetof(struct unw_frame_info, b5_loc)/8,
+		offsetof(struct unw_frame_info, f2_loc)/8,
+		offsetof(struct unw_frame_info, f3_loc)/8,
+		offsetof(struct unw_frame_info, f4_loc)/8,
+		offsetof(struct unw_frame_info, f5_loc)/8,
+		offsetof(struct unw_frame_info, fr_loc[16 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[17 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[18 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[19 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[20 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[21 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[22 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[23 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[24 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[25 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[26 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[27 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[28 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[29 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[30 - 16])/8,
+		offsetof(struct unw_frame_info, fr_loc[31 - 16])/8,
+	},
+	.pt_regs_offsets = {
+		[0] = -1,
+		offsetof(struct pt_regs,  r1),
+		offsetof(struct pt_regs,  r2),
+		offsetof(struct pt_regs,  r3),
+		[4] = -1, [5] = -1, [6] = -1, [7] = -1,
+		offsetof(struct pt_regs,  r8),
+		offsetof(struct pt_regs,  r9),
+		offsetof(struct pt_regs, r10),
+		offsetof(struct pt_regs, r11),
+		offsetof(struct pt_regs, r12),
+		offsetof(struct pt_regs, r13),
+		offsetof(struct pt_regs, r14),
+		offsetof(struct pt_regs, r15),
+		offsetof(struct pt_regs, r16),
+		offsetof(struct pt_regs, r17),
+		offsetof(struct pt_regs, r18),
+		offsetof(struct pt_regs, r19),
+		offsetof(struct pt_regs, r20),
+		offsetof(struct pt_regs, r21),
+		offsetof(struct pt_regs, r22),
+		offsetof(struct pt_regs, r23),
+		offsetof(struct pt_regs, r24),
+		offsetof(struct pt_regs, r25),
+		offsetof(struct pt_regs, r26),
+		offsetof(struct pt_regs, r27),
+		offsetof(struct pt_regs, r28),
+		offsetof(struct pt_regs, r29),
+		offsetof(struct pt_regs, r30),
+		offsetof(struct pt_regs, r31),
 	},
 	.hash = { [0 ... UNW_HASH_SIZE - 1] = -1 },
 #ifdef UNW_DEBUG
@@ -212,11 +244,6 @@ static struct {
 #endif
 };
 
-#define OFF_CASE(reg, reg_num) 					\
-	case reg:						\
-		off=struct_offset(struct pt_regs, reg_num);	\
-		break;
-
 /* Unwind accessors.  */
 
 /*
@@ -225,43 +252,16 @@ static struct {
 static inline unsigned long
 pt_regs_off (unsigned long reg)
 {
-	unsigned long off =0;
+	short off = -1;
 
-	switch (reg)
-	{
-		OFF_CASE(1,r1)
-		OFF_CASE(2,r2)
-		OFF_CASE(3,r3)
-		OFF_CASE(8,r8)
-		OFF_CASE(9,r9)
-		OFF_CASE(10,r10)
-		OFF_CASE(11,r11)
-		OFF_CASE(12,r12)
-		OFF_CASE(13,r13)
-		OFF_CASE(14,r14)
-		OFF_CASE(15,r15)
-		OFF_CASE(16,r16)
-		OFF_CASE(17,r17)
-		OFF_CASE(18,r18)
-		OFF_CASE(19,r19)
-		OFF_CASE(20,r20)
-		OFF_CASE(21,r21)
-		OFF_CASE(22,r22)
-		OFF_CASE(23,r23)
-		OFF_CASE(24,r24)
-		OFF_CASE(25,r25)
-		OFF_CASE(26,r26)
-		OFF_CASE(27,r27)
-		OFF_CASE(28,r28)
-		OFF_CASE(29,r29)
-		OFF_CASE(30,r30)
-		OFF_CASE(31,r31)
-		default:
-			UNW_DPRINT(0, "unwind.%s: bad scratch reg r%lu\n", __FUNCTION__, reg);
-			break;
-	}
+	if (reg < ARRAY_SIZE(unw.pt_regs_offsets))
+		off = unw.pt_regs_offsets[reg];
 
-	return off;
+	if (off < 0) {
+		UNW_DPRINT(0, "unwind.%s: bad scratch reg r%lu\n", __FUNCTION__, reg);
+		off = 0;
+	}
+	return (unsigned long) off;
 }
 
 static inline struct pt_regs *
@@ -398,6 +398,7 @@ unw_access_gr (struct unw_frame_info *in
 	}
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_gr);
 
 int
 unw_access_br (struct unw_frame_info *info, int regnum, unsigned long *val, int write)
@@ -429,6 +430,7 @@ unw_access_br (struct unw_frame_info *in
 		*val = *addr;
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_br);
 
 int
 unw_access_fr (struct unw_frame_info *info, int regnum, struct ia64_fpreg *val, int write)
@@ -473,6 +475,7 @@ unw_access_fr (struct unw_frame_info *in
 		*val = *addr;
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_fr);
 
 int
 unw_access_ar (struct unw_frame_info *info, int regnum, unsigned long *val, int write)
@@ -565,6 +568,7 @@ unw_access_ar (struct unw_frame_info *in
 		*val = *addr;
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_ar);
 
 int
 unw_access_pr (struct unw_frame_info *info, unsigned long *val, int write)
@@ -581,6 +585,7 @@ unw_access_pr (struct unw_frame_info *in
 		*val = *addr;
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_pr);
 
 
 /* Routines to manipulate the state stack.  */
@@ -1177,9 +1182,10 @@ desc_spill_sprel_p (unsigned char qp, un
 static inline unw_hash_index_t
 hash (unsigned long ip)
 {
-#	define magic	0x9e3779b97f4a7c16	/* based on (sqrt(5)/2-1)*2^64 */
+#	define hashmagic	0x9e3779b97f4a7c16	/* based on (sqrt(5)/2-1)*2^64 */
 
-	return (ip >> 4)*magic >> (64 - UNW_LOG_HASH_SIZE);
+	return (ip >> 4)*hashmagic >> (64 - UNW_LOG_HASH_SIZE);
+#undef hashmagic
 }
 
 static inline long
@@ -1258,13 +1264,18 @@ script_new (unsigned long ip)
 	spin_unlock(&unw.lock);
 
 	/*
-	 * XXX We'll deadlock here if we interrupt a thread that is
-	 * holding a read lock on script->lock.  A try_write_lock()
-	 * might be mighty handy here...  Alternatively, we could
-	 * disable interrupts whenever we hold a read-lock, but that
-	 * seems silly.
+	 * We'd deadlock here if we interrupted a thread that is holding a read lock on
+	 * script->lock.  Thus, if the write_trylock() fails, we simply bail out.  The
+	 * alternative would be to disable interrupts whenever we hold a read-lock, but
+	 * that seems silly.
 	 */
-	write_lock(&script->lock);
+	/* Kludge: 2.4 has down_write_trylock on semaphores but not write_trylock on
+	 * spinlocks, even though they are both in 2.6 and are identical.  Pretend
+	 * that script lock is a rw_semaphore so we can use the only 2.4 code that
+	 * avoids a deadlock.  KAO.
+	 */
+	if (!down_write_trylock((struct rw_semaphore *)(&script->lock)))
+		return NULL;
 
 	spin_lock(&unw.lock);
 	{
@@ -1421,7 +1432,7 @@ compile_reg (struct unw_state_record *sr
 		else {
 			opc = UNW_INSN_MOVE_SCRATCH;
 			if (rval <= 11)
-				val = struct_offset(struct pt_regs, f6) + 16*(rval - 6);
+				val = offsetof(struct pt_regs, f6) + 16*(rval - 6);
 			else
 				UNW_DPRINT(0, "unwind.%s: kernel may not touch f%lu\n",
 					   __FUNCTION__, rval);
@@ -1434,11 +1445,11 @@ compile_reg (struct unw_state_record *sr
 		else {
 			opc = UNW_INSN_MOVE_SCRATCH;
 			if (rval = 0)
-				val = struct_offset(struct pt_regs, b0);
+				val = offsetof(struct pt_regs, b0);
 			else if (rval = 6)
-				val = struct_offset(struct pt_regs, b6);
+				val = offsetof(struct pt_regs, b6);
 			else
-				val = struct_offset(struct pt_regs, b7);
+				val = offsetof(struct pt_regs, b7);
 		}
 		break;
 
@@ -1638,7 +1649,7 @@ build_script (struct unw_frame_info *inf
 	    && sr.curr.reg[UNW_REG_PSP].val != 0) {
 		/* new psp is sp plus frame size */
 		insn.opc = UNW_INSN_ADD;
-		insn.dst = struct_offset(struct unw_frame_info, psp)/8;
+		insn.dst = offsetof(struct unw_frame_info, psp)/8;
 		insn.val = sr.curr.reg[UNW_REG_PSP].val;	/* frame size */
 		script_emit(script, insn);
 	}
@@ -1772,13 +1783,13 @@ run_script (struct unw_script *script, s
   lazy_init:
 	off = unw.sw_off[val];
 	s[val] = (unsigned long) state->sw + off;
-	if (off >= struct_offset(struct switch_stack, r4) && off <= struct_offset(struct switch_stack, r7))
+	if (off >= offsetof(struct switch_stack, r4) && off <= offsetof(struct switch_stack, r7))
 		/*
 		 * We're initializing a general register: init NaT info, too.  Note that
 		 * the offset is a multiple of 8 which gives us the 3 bits needed for
 		 * the type field.
 		 */
-		s[val+1] = (struct_offset(struct switch_stack, ar_unat) - off) | UNW_NAT_MEMSTK;
+		s[val+1] = (offsetof(struct switch_stack, ar_unat) - off) | UNW_NAT_MEMSTK;
 	goto redo;
 }
 
@@ -1868,7 +1879,7 @@ unw_unwind (struct unw_frame_info *info)
 		if ((pr & (1UL << pNonSys)) != 0)
 			num_regs = *info->cfm_loc & 0x7f;		/* size of frame */
 		info->pfs_loc -			(unsigned long *) (info->pt + struct_offset(struct pt_regs, ar_pfs));
+			(unsigned long *) (info->pt + offsetof(struct pt_regs, ar_pfs));
 		UNW_DPRINT(3, "unwind.%s: interrupt_frame pt 0x%lx\n", __FUNCTION__, info->pt);
 	} else
 		num_regs = (*info->cfm_loc >> 7) & 0x7f;	/* size of locals */
@@ -1906,6 +1917,7 @@ unw_unwind (struct unw_frame_info *info)
 	STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 	return retval;
 }
+EXPORT_SYMBOL(unw_unwind);
 
 int
 unw_unwind_to_user (struct unw_frame_info *info)
@@ -1930,6 +1942,7 @@ unw_unwind_to_user (struct unw_frame_inf
 	UNW_DPRINT(0, "unwind.%s: failed to unwind to user-level (ip=0x%lx)\n", __FUNCTION__, ip);
 	return -1;
 }
+EXPORT_SYMBOL(unw_unwind_to_user);
 
 static void
 init_frame_info (struct unw_frame_info *info, struct task_struct *t,
@@ -1987,6 +2000,8 @@ unw_init_from_interruption (struct unw_f
 
 	init_frame_info(info, t, sw, pt->r12);
 	info->cfm_loc = &pt->cr_ifs;
+	info->unat_loc = &pt->ar_unat;
+	info->pfs_loc = &pt->ar_pfs;
 	sof = *info->cfm_loc & 0x7f;
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->regstk.top, -sof);
 	info->ip = pt->cr_iip + ia64_psr(pt)->ri;
@@ -2025,6 +2040,7 @@ unw_init_from_blocked_task (struct unw_f
 	UNW_DPRINT(1, "unwind.%s\n", __FUNCTION__);
 	unw_init_frame_info(info, t, sw);
 }
+EXPORT_SYMBOL(unw_init_from_blocked_task);
 
 static void
 init_unwind_table (struct unw_table *table, const char *name, unsigned long segment_base,
Index: 25.4/arch/ia64/kernel/Makefile
--- 25.4/arch/ia64/kernel/Makefile Tue, 16 Sep 2003 19:32:24 +1000 kaos (linux-2.4/s/c/19_Makefile 1.1.3.1.3.1.2.1.1.2.1.1 644)
+++ 25.4(w)/arch/ia64/kernel/Makefile Mon, 23 Feb 2004 11:45:55 +1100 kaos (linux-2.4/s/c/19_Makefile 1.1.3.1.3.1.2.1.1.2.1.1 644)
@@ -11,7 +11,7 @@ all: kernel.o head.o init_task.o
 
 O_TARGET := kernel.o
 
-export-objs := ia64_ksyms.o
+export-objs := ia64_ksyms.o unwind.o
 
 obj-y := acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_ia64.o irq_lsapic.o ivt.o \
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o salinfo.o semaphore.o setup.o	 \

