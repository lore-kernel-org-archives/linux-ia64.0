From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Dec 2002 03:13:31 +0000
Subject: [Linux-ia64] more unaligned.c cleanup/fixes
Message-Id: <marc-linux-ia64-105590709805532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While working on unaligned.c, I found some opportunities to simplify
the existing rotation code and while doing that, discovered two more
bugs:

 - the old code rotated one register beyond the rotating partition
   (e.g., with 8 registers allocated, r40 would incorrectly get
   rotated)

 - the old code inadvertently leaked kernel bits when an unaligned
   access read from an out-of-frame register occurred

 - someone was a bit overeager in "fixing" printk() formats; printing
   KERN_ERR as the first format string doesn't do much good...
   (not sure how this happened...)

Bjorn, I think this patch should apply on 2.4 as well.

	--david

=== arch/ia64/kernel/unaligned.c 1.6 vs edited ==--- 1.6/arch/ia64/kernel/unaligned.c	Thu Mar 14 00:28:41 2002
+++ edited/arch/ia64/kernel/unaligned.c	Mon Dec  9 19:05:05 2002
@@ -5,6 +5,10 @@
  *	Stephane Eranian <eranian@hpl.hp.com>
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
+ * 2002/12/09   Fix rotating register handling (off-by-1 error, missing fr-rotation).  Fix
+ *		get_rse_reg() to not leak kernel bits to user-level (reading an out-of-frame
+ *		stacked register returns an undefined value; it does NOT trigger a
+ *		"rsvd register fault").
  * 2001/10/11	Fix unaligned access to rotating registers in s/w pipelined loops.
  * 2001/08/13	Correct size of extended floats (float_fsz) from 16 to 10 bytes.
  * 2001/01/17	Add support emulation of unaligned kernel accesses.
@@ -276,6 +280,15 @@
 #	undef F
 }
 
+static inline unsigned long
+rotate_reg (unsigned long sor, unsigned long rrb, unsigned long reg)
+{
+	reg += rrb;
+	if (reg >= sor)
+		reg -= sor;
+	return reg;
+}
+
 static void
 set_rse_reg (struct pt_regs *regs, unsigned long r1, unsigned long val, int nat)
 {
@@ -287,26 +300,22 @@
 	long sof = (regs->cr_ifs) & 0x7f;
 	long sor = 8 * ((regs->cr_ifs >> 14) & 0xf);
 	long rrb_gr = (regs->cr_ifs >> 18) & 0x7f;
-	long ridx;
-
-	if ((r1 - 32) > sor)
-		ridx = -sof + (r1 - 32);
-	else if ((r1 - 32) < (sor - rrb_gr))
-		ridx = -sof + (r1 - 32) + rrb_gr;
-	else
-		ridx = -sof + (r1 - 32) - (sor - rrb_gr);
-
-	DPRINT("r%lu, sw.bspstore=%lx pt.bspstore=%lx sof=%ld sol=%ld ridx=%ld\n",
-	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> 7) & 0x7f, ridx);
+	long ridx = r1 - 32;
 
-	if ((r1 - 32) >= sof) {
+	if (ridx >= sof) {
 		/* this should never happen, as the "rsvd register fault" has higher priority */
 		DPRINT("ignoring write to r%lu; only %lu registers are allocated!\n", r1, sof);
 		return;
 	}
 
+	if (ridx < sor)
+		ridx = rotate_reg(sor, rrb_gr, ridx);
+
+	DPRINT("r%lu, sw.bspstore=%lx pt.bspstore=%lx sof=%ld sol=%ld ridx=%ld\n",
+	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> 7) & 0x7f, ridx);
+
 	on_kbs = ia64_rse_num_regs(kbs, (unsigned long *) sw->ar_bspstore);
-	addr = ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, ridx);
+	addr = ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, -sof + ridx);
 	if (addr >= kbs) {
 		/* the register is on the kernel backing store: easy... */
 		rnat_addr = ia64_rse_rnat_addr(addr);
@@ -334,7 +343,7 @@
 	bspstore = (unsigned long *)regs->ar_bspstore;
 	ubs_end = ia64_rse_skip_regs(bspstore, on_kbs);
 	bsp     = ia64_rse_skip_regs(ubs_end, -sof);
-	addr    = ia64_rse_skip_regs(bsp, ridx + sof);
+	addr    = ia64_rse_skip_regs(bsp, ridx);
 
 	DPRINT("ubs_end=%p bsp=%p addr=%p\n", (void *) ubs_end, (void *) bsp, (void *) addr);
 
@@ -368,26 +377,22 @@
 	long sof = (regs->cr_ifs) & 0x7f;
 	long sor = 8 * ((regs->cr_ifs >> 14) & 0xf);
 	long rrb_gr = (regs->cr_ifs >> 18) & 0x7f;
-	long ridx;
+	long ridx = r1 - 32;
 
-	if ((r1 - 32) > sor)
-		ridx = -sof + (r1 - 32);
-	else if ((r1 - 32) < (sor - rrb_gr))
-		ridx = -sof + (r1 - 32) + rrb_gr;
-	else
-		ridx = -sof + (r1 - 32) - (sor - rrb_gr);
+	if (ridx >= sof) {
+		/* read of out-of-frame register returns an undefined value; 0 in our case.  */
+		DPRINT("ignoring read from r%lu; only %lu registers are allocated!\n", r1, sof);
+		goto fail;
+	}
+
+	if (ridx < sor)
+		ridx = rotate_reg(sor, rrb_gr, ridx);
 
 	DPRINT("r%lu, sw.bspstore=%lx pt.bspstore=%lx sof=%ld sol=%ld ridx=%ld\n",
 	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> 7) & 0x7f, ridx);
 
-	if ((r1 - 32) >= sof) {
-		/* this should never happen, as the "rsvd register fault" has higher priority */
-		DPRINT("ignoring read from r%lu; only %lu registers are allocated!\n", r1, sof);
-		return;
-	}
-
 	on_kbs = ia64_rse_num_regs(kbs, (unsigned long *) sw->ar_bspstore);
-	addr = ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, ridx);
+	addr = ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, -sof + ridx);
 	if (addr >= kbs) {
 		/* the register is on the kernel backing store: easy... */
 		*val = *addr;
@@ -407,13 +412,13 @@
 	 */
 	if (regs->r12 >= TASK_SIZE) {
 		DPRINT("ignoring kernel read of r%lu; register isn't on the RBS!", r1);
-		return;
+		goto fail;
 	}
 
 	bspstore = (unsigned long *)regs->ar_bspstore;
 	ubs_end = ia64_rse_skip_regs(bspstore, on_kbs);
 	bsp     = ia64_rse_skip_regs(ubs_end, -sof);
-	addr    = ia64_rse_skip_regs(bsp, ridx + sof);
+	addr    = ia64_rse_skip_regs(bsp, ridx);
 
 	DPRINT("ubs_end=%p bsp=%p addr=%p\n", (void *) ubs_end, (void *) bsp, (void *) addr);
 
@@ -428,6 +433,13 @@
 		ia64_peek(current, sw, (unsigned long) ubs_end, (unsigned long) rnat_addr, &rnats);
 		*nat = (rnats & nat_mask) != 0;
 	}
+	return;
+
+  fail:
+	*val = 0;
+	if (nat)
+		*nat = 0;
+	return;
 }
 
 
@@ -486,7 +498,16 @@
 	DPRINT("*0x%lx=0x%lx NaT=%d new unat: %p=%lx\n", addr, val, nat, (void *) unat,*unat);
 }
 
-#define IA64_FPH_OFFS(r) (r - IA64_FIRST_ROTATING_FR)
+/*
+ * Return the (rotated) index for floating point register REGNUM (REGNUM must be in the
+ * range from 32-127, result is in the range from 0-95.
+ */
+static inline unsigned long
+fph_index (struct pt_regs *regs, long regnum)
+{
+	unsigned long rrb_fr = (regs->cr_ifs >> 25) & 0x7f;
+	return rotate_reg(96, rrb_fr, (regnum - IA64_FIRST_ROTATING_FR));
+}
 
 static void
 setfpreg (unsigned long regnum, struct ia64_fpreg *fpval, struct pt_regs *regs)
@@ -507,7 +528,7 @@
 	 */
 	if (regnum >= IA64_FIRST_ROTATING_FR) {
 		ia64_sync_fph(current);
-		current->thread.fph[IA64_FPH_OFFS(regnum)] = *fpval;
+		current->thread.fph[fph_index(regs, regnum)] = *fpval;
 	} else {
 		/*
 		 * pt_regs or switch_stack ?
@@ -566,7 +587,7 @@
 	 */
 	if (regnum >= IA64_FIRST_ROTATING_FR) {
 		ia64_flush_fph(current);
-		*fpval = current->thread.fph[IA64_FPH_OFFS(regnum)];
+		*fpval = current->thread.fph[fph_index(regs, regnum)];
 	} else {
 		/*
 		 * f0 = 0.0, f1= 1.0. Those registers are constant and are thus
@@ -651,7 +672,7 @@
 	 * just in case.
 	 */
 	if (ld.x6_op = 1 || ld.x6_op = 3) {
-		printk("%s %s: register update on speculative load, error\n", KERN_ERR, __FUNCTION__);
+		printk(KERN_ERR "%s: register update on speculative load, error\n", __FUNCTION__);
 		die_if_kernel("unaligned reference on specualtive load with register update\n",
 			      regs, 30);
 	}
@@ -1081,8 +1102,8 @@
 		 * For this reason we keep this sanity check
 		 */
 		if (ld.x6_op = 1 || ld.x6_op = 3)
-			printk("%s %s: register update on speculative load pair, "
-			       "error\n",KERN_ERR, __FUNCTION__);
+			printk(KERN_ERR "%s: register update on speculative load pair, error\n",
+			       __FUNCTION__);
 
 		setreg(ld.r3, ifa, 0, regs);
 	}

