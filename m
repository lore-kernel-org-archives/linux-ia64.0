From: Keith Owens <kaos@sgi.com>
Date: Thu, 20 Feb 2003 01:29:20 +0000
Subject: [Linux-ia64] Re: [patch] 2.4.20 unwind.c to handle multiple struct pt_regs
Message-Id: <marc-linux-ia64-105590709805882@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 19 Feb 2003 11:21:31 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>  Keith> This patch has been running inside SGI for 2 months.  It
>  Keith> handles kernel stacks with multiple struct pt_regs, as found
>  Keith> while debugging the kernel.  The debugging statements in the
>  Keith> unwind code were awkward to use and inconsistent in what was
>  Keith> being dumped and when, I ended up changing almost all the
>  Keith> unwind debugging code while tracking down this problem.
>
>The patch basically looks fine to me, except that I'd really like to
>prefer to have it split up into one patch that does the pt_regs fixes
>and one that does the debug enhancements.  And while you're at it,
>please use something a bit more concise than UNW_DEBUG_PRINT
>(something like DPRINT or UNW_DPRINT should be sufficient).

Two patches follow.  The first updates include/asm-ia64/unwind.h,
arch/ia64/kernel/unwind_i.h, arch/ia64/kernel/unwind.c to handle
multiple pt_regs on stack.  The second only updates unwind.c, it goes
over the first patch to clean up the debug code, using UNW_DPRINT().

diff include/asm-ia64/unwind.h
--- include/asm-ia64/unwind.h
+++ include/asm-ia64/unwind.h
@@ -60,6 +60,7 @@ struct unw_frame_info {
 	unsigned long ip;		/* instruction pointer value */
 	unsigned long pr;		/* current predicate values */
 	unsigned long *cfm_loc;		/* cfm save location (or NULL) */
+	unsigned long pt;		/* struct pt_regs location */
 
 	struct task_struct *task;
 	struct switch_stack *sw;
diff arch/ia64/kernel/unwind_i.h
--- arch/ia64/kernel/unwind_i.h
+++ arch/ia64/kernel/unwind_i.h
@@ -137,7 +137,8 @@ enum unw_insn_opcode {
 	UNW_INSN_SETNAT_MEMSTK,		/* s[dst+1].nat.type = MEMSTK;
 					   s[dst+1].nat.off = *s.pri_unat - s[dst] */
 	UNW_INSN_SETNAT_TYPE,		/* s[dst+1].nat.type = val */
-	UNW_INSN_LOAD			/* s[dst] = *s[val] */
+	UNW_INSN_LOAD,			/* s[dst] = *s[val] */
+	UNW_INSN_MOVE_SCRATCH,		/* s[dst] = scratch reg "val" */
 };
 
 struct unw_insn {
diff arch/ia64/kernel/unwind.c
--- arch/ia64/kernel/unwind.c
+++ arch/ia64/kernel/unwind.c
@@ -227,12 +227,21 @@ pt_regs_off (unsigned long reg)
 	return off;
 }
 
+static void
+dump_info_pt(struct unw_frame_info *info, const char *func)
+{
+	/* WAR for no struct pt_regs, may be caused by bad unwind data.  KAO */
+	if (!info->pt) {
+		dprintk("unwind.%s: sp 0x%lx pt 0x%lx, set to 0x%lx\n", func, info->sp, info->pt, info->sp - 16);
+		info->pt = info->sp - 16;
+	}
+}
+
 int
 unw_access_gr (struct unw_frame_info *info, int regnum, unsigned long *val, char *nat, int write)
 {
 	unsigned long *addr, *nat_addr, nat_mask = 0, dummy_nat;
 	struct unw_ireg *ireg;
-	struct pt_regs *pt;
 
 	if ((unsigned) regnum - 1 >= 127) {
 		dprintk("unwind: trying to access non-existent r%u\n", regnum);
@@ -298,11 +307,8 @@ unw_access_gr (struct unw_frame_info *in
 			}
 		} else {
 			/* access a scratch register */
-			if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
-				pt = (struct pt_regs *) info->psp - 1;
-			else
-				pt = (struct pt_regs *) info->sp - 1;
-			addr = (unsigned long *) ((long) pt + pt_regs_off(regnum));
+			dump_info_pt(info,  __FUNCTION__);
+			addr = (unsigned long *) (info->pt + pt_regs_off(regnum));
 			if (info->pri_unat_loc)
 				nat_addr = info->pri_unat_loc;
 			else
@@ -348,10 +354,8 @@ unw_access_br (struct unw_frame_info *in
 	unsigned long *addr;
 	struct pt_regs *pt;
 
-	if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
-		pt = (struct pt_regs *) info->psp - 1;
-	else
-		pt = (struct pt_regs *) info->sp - 1;
+	dump_info_pt(info,  __FUNCTION__);
+	pt = (struct pt_regs *)info->pt;
 	switch (regnum) {
 		/* scratch: */
 	      case 0: addr = &pt->b0; break;
@@ -387,10 +391,8 @@ unw_access_fr (struct unw_frame_info *in
 		return -1;
 	}
 
-	if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
-		pt = (struct pt_regs *) info->psp - 1;
-	else
-		pt = (struct pt_regs *) info->sp - 1;
+	dump_info_pt(info,  __FUNCTION__);
+	pt = (struct pt_regs *)info->pt;
 
 	if (regnum <= 5) {
 		addr = *(&info->f2_loc + (regnum - 2));
@@ -428,10 +430,8 @@ unw_access_ar (struct unw_frame_info *in
 	unsigned long *addr;
 	struct pt_regs *pt;
 
-	if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
-		pt = (struct pt_regs *) info->psp - 1;
-	else
-		pt = (struct pt_regs *) info->sp - 1;
+	dump_info_pt(info,  __FUNCTION__);
+	pt = (struct pt_regs *)info->pt;
 
 	switch (regnum) {
 	      case UNW_AR_BSP:
@@ -1338,8 +1338,9 @@ compile_reg (struct unw_state_record *sr
 			}
 			val = unw.preg_index[UNW_REG_R4 + (rval - 4)];
 		} else {
-			opc = UNW_INSN_ADD_SP;
-			val = -sizeof(struct pt_regs) + pt_regs_off(rval);
+			/* register got spilled to a scratch register */
+			opc = UNW_INSN_MOVE_SCRATCH;
+			val = pt_regs_off(rval);
 		}
 		break;
 
@@ -1349,10 +1350,9 @@ compile_reg (struct unw_state_record *sr
 		else if (rval >= 16 && rval <= 31)
 			val = unw.preg_index[UNW_REG_F16 + (rval - 16)];
 		else {
-			opc = UNW_INSN_ADD_SP;
-			val = -sizeof(struct pt_regs);
+			opc = UNW_INSN_MOVE_SCRATCH;
 			if (rval <= 9)
-				val += struct_offset(struct pt_regs, f6) + 16*(rval - 6);
+				val = struct_offset(struct pt_regs, f6) + 16*(rval - 6);
 			else
 				dprintk("unwind: kernel may not touch f%lu\n", rval);
 		}
@@ -1362,14 +1362,13 @@ compile_reg (struct unw_state_record *sr
 		if (rval >= 1 && rval <= 5)
 			val = unw.preg_index[UNW_REG_B1 + (rval - 1)];
 		else {
-			opc = UNW_INSN_ADD_SP;
-			val = -sizeof(struct pt_regs);
+			opc = UNW_INSN_MOVE_SCRATCH;
 			if (rval = 0)
-				val += struct_offset(struct pt_regs, b0);
+				val = struct_offset(struct pt_regs, b0);
 			else if (rval = 6)
-				val += struct_offset(struct pt_regs, b6);
+				val = struct_offset(struct pt_regs, b6);
 			else
-				val += struct_offset(struct pt_regs, b7);
+				val = struct_offset(struct pt_regs, b7);
 		}
 		break;
 
@@ -1641,6 +1640,17 @@ run_script (struct unw_script *script, s
 			s[dst] = s[val];
 			break;
 
+		      case UNW_INSN_MOVE_SCRATCH:
+			if (state->pt) {
+				dump_info_pt(state,  __FUNCTION__);
+				s[dst] = state->pt+val;
+			}
+			else {
+				s[dst] = 0;
+				dprintk("unwind.%s: no state->pt, dst=%ld, val=%ld\n", __FUNCTION__, dst, val);
+			}
+			break;
+
 		      case UNW_INSN_MOVE_STACKED:
 			s[dst] = (unsigned long) ia64_rse_skip_regs((unsigned long *)state->bsp,
 								    val);
@@ -1773,10 +1783,11 @@ unw_unwind (struct unw_frame_info *info)
 	pr = info->pr;
 	num_regs = 0;
 	if ((info->flags & UNW_FLAG_INTERRUPT_FRAME)) {
+		info->pt = info->sp + 16;
 		if ((pr & (1UL << pNonSys)) != 0)
 			num_regs = *info->cfm_loc & 0x7f;		/* size of frame */
 		info->pfs_loc -			(unsigned long *) (info->sp + 16 + struct_offset(struct pt_regs, ar_pfs));
+			(unsigned long *) (info->pt + struct_offset(struct pt_regs, ar_pfs));
 	} else
 		num_regs = (*info->cfm_loc >> 7) & 0x7f;	/* size of locals */
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->bsp, -num_regs);
@@ -1873,6 +1884,7 @@ unw_init_frame_info (struct unw_frame_in
 	info->task = t;
 	info->sw  = sw;
 	info->sp = info->psp = (unsigned long) (sw + 1) - 16;
+	info->pt = 0;
 	info->cfm_loc = &sw->ar_pfs;
 	sol = (*info->cfm_loc >> 7) & 0x7f;
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->regstk.top, -sol);




diff arch/ia64/kernel/unwind.c
--- arch/ia64/kernel/unwind.c
+++ arch/ia64/kernel/unwind.c
@@ -51,18 +51,24 @@
 #define UNW_LOG_HASH_SIZE	(UNW_LOG_CACHE_SIZE + 1)
 #define UNW_HASH_SIZE		(1 << UNW_LOG_HASH_SIZE)
 
-#define UNW_DEBUG	0
 #define UNW_STATS	0	/* WARNING: this disabled interrupts for long time-spans!! */
 
-#if UNW_DEBUG
-  static long unw_debug_level = 255;
-# define debug(level,format...)	if (unw_debug_level > level) printk(format)
-# define dprintk(format...)	printk(format)
-# define inline
-#else
-# define debug(level,format...)
-# define dprintk(format...)
-#endif
+#ifdef UNW_DEBUG
+  static unsigned int unw_debug_level = UNW_DEBUG;
+  #ifdef CONFIG_KDB
+    #include <linux/kdb.h>
+    #define UNW_DEBUG_ON(n)  (unw_debug_level >= n && !KDB_IS_RUNNING())
+    #define UNW_DPRINT(n, ...)  if (UNW_DEBUG_ON(n)) kdb_printf(__VA_ARGS__)
+  #else	/* !CONFIG_KDB */
+    #define UNW_DEBUG_ON(n)  unw_debug_level >= n
+    /* Do not code a printk level, not all debug lines end in newline */
+    #define UNW_DPRINT(n, ...)  if (UNW_DEBUG_ON(n)) printk(__VA_ARGS__)
+  #endif	/* CONFIG_KDB */
+  #define inline
+#else	/* !UNW_DEBUG */
+  #define UNW_DEBUG_ON(n)  0
+  #define UNW_DPRINT(n, ...)
+#endif	/* UNW_DEBUG */
 
 #if UNW_STATS
 # define STAT(x...)	x
@@ -111,7 +117,7 @@ static struct {
 	/* script cache: */
 	struct unw_script cache[UNW_CACHE_SIZE];
 
-# if UNW_DEBUG
+# ifdef UNW_DEBUG
 	const char *preg_name[UNW_NUM_REGS];
 # endif
 # if UNW_STATS
@@ -190,7 +196,7 @@ static struct {
 		struct_offset(struct unw_frame_info, fr_loc[31 - 16])/8,
 	},
 	hash : { [0 ... UNW_HASH_SIZE - 1] = -1 },
-#if UNW_DEBUG
+#ifdef UNW_DEBUG
 	preg_name: {
 		"pri_unat_gr", "pri_unat_mem", "bsp", "bspstore", "ar.pfs", "ar.rnat", "psp", "rp",
 		"r4", "r5", "r6", "r7",
@@ -223,7 +229,7 @@ pt_regs_off (unsigned long reg)
 	else if (reg <= 31)
 		off = struct_offset(struct pt_regs, r16) + 8*(reg - 16);
 	else
-		dprintk("unwind: bad scratch reg r%lu\n", reg);
+		UNW_DPRINT(0, "unwind.%s: bad scratch reg r%lu\n", __FUNCTION__, reg);
 	return off;
 }
 
@@ -232,9 +238,12 @@ dump_info_pt(struct unw_frame_info *info
 {
 	/* WAR for no struct pt_regs, may be caused by bad unwind data.  KAO */
 	if (!info->pt) {
-		dprintk("unwind.%s: sp 0x%lx pt 0x%lx, set to 0x%lx\n", func, info->sp, info->pt, info->sp - 16);
+		UNW_DPRINT(0, "unwind.%s: sp 0x%lx pt 0x%lx, set to 0x%lx\n", func, info->sp, info->pt, info->sp - 16);
 		info->pt = info->sp - 16;
 	}
+	else {
+		UNW_DPRINT(3, "unwind.%s: sp 0x%lx pt 0x%lx\n", func, info->sp, info->pt);
+	}
 }
 
 int
@@ -244,7 +253,7 @@ unw_access_gr (struct unw_frame_info *in
 	struct unw_ireg *ireg;
 
 	if ((unsigned) regnum - 1 >= 127) {
-		dprintk("unwind: trying to access non-existent r%u\n", regnum);
+		UNW_DPRINT(0, "unwind.%s: trying to access non-existent r%u\n", __FUNCTION__, regnum);
 		return -1;
 	}
 
@@ -289,8 +298,9 @@ unw_access_gr (struct unw_frame_info *in
 					if ((unsigned long) addr < info->regstk.limit
 					    || (unsigned long) addr >= info->regstk.top)
 					{
-						dprintk("unwind: %p outside of regstk "
-							"[0x%lx-0x%lx)\n", (void *) addr,
+						UNW_DPRINT(0, "unwind.%s: %p outside of regstk "
+							"[0x%lx-0x%lx)\n",
+							__FUNCTION__, (void *) addr,
 							info->regstk.limit,
 							info->regstk.top);
 						return -1;
@@ -322,7 +332,7 @@ unw_access_gr (struct unw_frame_info *in
 		if ((unsigned long) addr < info->regstk.limit
 		    || (unsigned long) addr >= info->regstk.top)
 		{
-			dprintk("unwind: ignoring attempt to access register outside of rbs\n");
+			UNW_DPRINT(0, "unwind.%s: ignoring attempt to access register outside of rbs\n",  __FUNCTION__);
 			return -1;
 		}
 		if ((unsigned long) nat_addr >= info->regstk.top)
@@ -370,7 +380,7 @@ unw_access_br (struct unw_frame_info *in
 		break;
 
 	      default:
-		dprintk("unwind: trying to access non-existent b%u\n", regnum);
+		UNW_DPRINT(0, "unwind.%s: trying to access non-existent b%u\n", __FUNCTION__, regnum);
 		return -1;
 	}
 	if (write)
@@ -387,7 +397,7 @@ unw_access_fr (struct unw_frame_info *in
 	struct pt_regs *pt;
 
 	if ((unsigned) (regnum - 2) >= 126) {
-		dprintk("unwind: trying to access non-existent f%u\n", regnum);
+		UNW_DPRINT(0, "unwind.%s: trying to access non-existent f%u\n", __FUNCTION__, regnum);
 		return -1;
 	}
 
@@ -495,7 +505,7 @@ unw_access_ar (struct unw_frame_info *in
 		break;
 
 	      default:
-		dprintk("unwind: trying to access non-existent ar%u\n", regnum);
+		UNW_DPRINT(0, "unwind.%s: trying to access non-existent ar%u\n", __FUNCTION__, regnum);
 		return -1;
 	}
 
@@ -532,7 +542,7 @@ push (struct unw_state_record *sr)
 
 	rs = alloc_reg_state();
 	if (!rs) {
-		printk("unwind: cannot stack reg state!\n");
+		UNW_DPRINT(0, "unwind.%s: cannot stack reg state!\n", __FUNCTION__);
 		return;
 	}
 	memcpy(rs, &sr->curr, sizeof(*rs));
@@ -545,7 +555,7 @@ pop (struct unw_state_record *sr)
 	struct unw_reg_state *rs = sr->curr.next;
 
 	if (!rs) {
-		printk("unwind: stack underflow!\n");
+		UNW_DPRINT(0, "unwind.%s: stack underflow!\n",  __FUNCTION__);
 		return;
 	}
 	memcpy(&sr->curr, rs, sizeof(*rs));
@@ -561,7 +571,7 @@ dup_state_stack (struct unw_reg_state *r
 	while (rs) {
 		copy = alloc_reg_state();
 		if (!copy) {
-			printk ("unwind.dup_state_stack: out of memory\n");
+			UNW_DPRINT(0, "unwind.%s: out of memory\n",  __FUNCTION__);
 			return NULL;
 		}
 		memcpy(copy, rs, sizeof(*copy));
@@ -612,7 +622,7 @@ decode_abreg (unsigned char abreg, int m
 	      default:
 		break;
 	}
-	dprintk("unwind: bad abreg=0x%x\n", abreg);
+	UNW_DPRINT(0, "unwind.%s: bad abreg=0x%x\n", __FUNCTION__, abreg);
 	return UNW_REG_LC;
 }
 
@@ -652,7 +662,7 @@ spill_next_when (struct unw_reg_info **r
 			return;
 		}
 	}
-	dprintk("unwind: excess spill!\n");
+	UNW_DPRINT(0, "unwind.%s: excess spill!\n",  __FUNCTION__);
 }
 
 static inline void
@@ -765,10 +775,13 @@ desc_prologue (int body, unw_word rlen, 
 static inline void
 desc_abi (unsigned char abi, unsigned char context, struct unw_state_record *sr)
 {
-	if (abi = 0 && context = 'i')
+	if (abi = 0 && context = 'i') {
 		sr->flags |= UNW_FLAG_INTERRUPT_FRAME;
+		UNW_DPRINT(3, "unwind.%s: interrupt frame\n",  __FUNCTION__);
+	}
 	else
-		dprintk("unwind: ignoring unwabi(abi=0x%x,context=0x%x)\n", abi, context);
+		UNW_DPRINT(0, "unwind%s: ignoring unwabi(abi=0x%x,context=0x%x)\n",
+				__FUNCTION__, abi, context);
 }
 
 static inline void
@@ -951,7 +964,7 @@ desc_copy_state (unw_word label, struct 
 			return;
 		}
 	}
-	printk("unwind: failed to find state labeled 0x%lx\n", label);
+	UNW_DPRINT(0, "unwind.%s: failed to find state labeled 0x%lx\n", __FUNCTION__, label);
 }
 
 static inline void
@@ -961,7 +974,7 @@ desc_label_state (unw_word label, struct
 
 	ls = alloc_labeled_state();
 	if (!ls) {
-		printk("unwind.desc_label_state(): out of memory\n");
+		UNW_DPRINT(0, "unwind.%s: out of memory\n",  __FUNCTION__);
 		return;
 	}
 	ls->label = label;
@@ -1055,7 +1068,7 @@ desc_spill_sprel_p (unsigned char qp, un
 	r->val = 4*spoff;
 }
 
-#define UNW_DEC_BAD_CODE(code)			printk("unwind: unknown code 0x%02x\n", code);
+#define UNW_DEC_BAD_CODE(code)			UNW_DPRINT(0, "unwind.%s: unknown code 0x%02x\n", __FUNCTION__, code);
 
 /*
  * region headers:
@@ -1134,6 +1147,8 @@ script_lookup (struct unw_frame_info *in
 	struct unw_script *script = unw.cache + info->hint;
 	unsigned short index;
 	unsigned long ip, pr;
+	if (UNW_DEBUG_ON(0))
+		return 0;	/* Always regenerate scripts in debug mode */
 
 	STAT(++unw.stat.cache.lookups);
 
@@ -1259,8 +1274,8 @@ static inline void
 script_emit (struct unw_script *script, struct unw_insn insn)
 {
 	if (script->count >= UNW_MAX_SCRIPT_LEN) {
-		dprintk("unwind: script exceeds maximum size of %u instructions!\n",
-			UNW_MAX_SCRIPT_LEN);
+		UNW_DPRINT(0, "unwind.%s: script exceeds maximum size of %u instructions!\n",
+			__FUNCTION__, UNW_MAX_SCRIPT_LEN);
 		return;
 	}
 	script->insn[script->count++] = insn;
@@ -1301,7 +1316,7 @@ emit_nat_info (struct unw_state_record *
 		break;
 
 	      default:
-		dprintk("unwind: don't know how to emit nat info for where = %u\n", r->where);
+		UNW_DPRINT(0, "unwind.%s: don't know how to emit nat info for where = %u\n", __FUNCTION__, r->where);
 		return;
 	}
 	insn.opc = opc;
@@ -1354,7 +1369,7 @@ compile_reg (struct unw_state_record *sr
 			if (rval <= 9)
 				val = struct_offset(struct pt_regs, f6) + 16*(rval - 6);
 			else
-				dprintk("unwind: kernel may not touch f%lu\n", rval);
+				UNW_DPRINT(0, "unwind.%s: kernel may not touch f%lu\n", __FUNCTION__, rval);
 		}
 		break;
 
@@ -1381,7 +1396,7 @@ compile_reg (struct unw_state_record *sr
 		break;
 
 	      default:
-		dprintk("unwind: register %u has unexpected `where' value of %u\n", i, r->where);
+		UNW_DPRINT(0, "unwind%s: register %u has unexpected `where' value of %u\n", __FUNCTION__, i, r->where);
 		break;
 	}
 	insn.opc = opc;
@@ -1454,9 +1469,10 @@ build_script (struct unw_frame_info *inf
 		r->when = UNW_WHEN_NEVER;
 	sr.pr_val = info->pr;
 
+	UNW_DPRINT(3, "unwind.%s: ip 0x%lx\n", __FUNCTION__, ip);
 	script = script_new(ip);
 	if (!script) {
-		dprintk("unwind: failed to create unwind script\n");
+		UNW_DPRINT(0, "unwind.%s: failed to create unwind script\n",  __FUNCTION__);
 		STAT(unw.stat.script.build_time += ia64_get_itc() - start);
 		return 0;
 	}
@@ -1474,8 +1490,8 @@ build_script (struct unw_frame_info *inf
 	}
 	if (!e) {
 		/* no info, return default unwinder (leaf proc, no mem stack, no saved regs)  */
-		dprintk("unwind: no unwind info for ip=0x%lx (prev ip=0x%lx)\n", ip,
-			unw.cache[info->prev_script].ip);
+		UNW_DPRINT(1, "unwind.%s: no unwind info for ip=0x%lx (prev ip=0x%lx)\n",
+			__FUNCTION__, ip, unw.cache[info->prev_script].ip);
 		sr.curr.reg[UNW_REG_RP].where = UNW_WHERE_BR;
 		sr.curr.reg[UNW_REG_RP].when = -1;
 		sr.curr.reg[UNW_REG_RP].val = 0;
@@ -1523,26 +1539,28 @@ build_script (struct unw_frame_info *inf
 		sr.curr.reg[UNW_REG_RP].where = UNW_WHERE_BR;
 		sr.curr.reg[UNW_REG_RP].when = -1;
 		sr.curr.reg[UNW_REG_RP].val = sr.return_link_reg;
+		UNW_DPRINT(1, "unwind.%s: using default for rp at ip=0x%lx where=%d val=0x%lx\n",
+			__FUNCTION__, ip, sr.curr.reg[UNW_REG_RP].where, sr.curr.reg[UNW_REG_RP].val);
 	}
 
-#if UNW_DEBUG
-	printk("unwind: state record for func 0x%lx, t=%u:\n",
-	       table->segment_base + e->start_offset, sr.when_target);
+#ifdef UNW_DEBUG
+	UNW_DPRINT(1, "unwind.%s: state record for func 0x%lx, t=%u:\n",
+		__FUNCTION__, table->segment_base + e->start_offset, sr.when_target);
 	for (r = sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r) {
 		if (r->where != UNW_WHERE_NONE || r->when != UNW_WHEN_NEVER) {
-			printk("  %s <- ", unw.preg_name[r - sr.curr.reg]);
+			UNW_DPRINT(1, "  %s <- ", unw.preg_name[r - sr.curr.reg]);
 			switch (r->where) {
-			      case UNW_WHERE_GR:     printk("r%lu", r->val); break;
-			      case UNW_WHERE_FR:     printk("f%lu", r->val); break;
-			      case UNW_WHERE_BR:     printk("b%lu", r->val); break;
-			      case UNW_WHERE_SPREL:  printk("[sp+0x%lx]", r->val); break;
-			      case UNW_WHERE_PSPREL: printk("[psp+0x%lx]", r->val); break;
+			      case UNW_WHERE_GR:     UNW_DPRINT(1, "r%lu", r->val); break;
+			      case UNW_WHERE_FR:     UNW_DPRINT(1, "f%lu", r->val); break;
+			      case UNW_WHERE_BR:     UNW_DPRINT(1, "b%lu", r->val); break;
+			      case UNW_WHERE_SPREL:  UNW_DPRINT(1, "[sp+0x%lx]", r->val); break;
+			      case UNW_WHERE_PSPREL: UNW_DPRINT(1, "[psp+0x%lx]", r->val); break;
 			      case UNW_WHERE_NONE:
-				printk("%s+0x%lx", unw.preg_name[r - sr.curr.reg], r->val);
+				UNW_DPRINT(1, "%s+0x%lx", unw.preg_name[r - sr.curr.reg], r->val);
 				break;
-			      default:		     printk("BADWHERE(%d)", r->where); break;
+			      default:		     UNW_DPRINT(1, "BADWHERE(%d)", r->where); break;
 			}
-			printk("\t\t%d\n", r->when);
+			UNW_DPRINT(1, "\t\t%d\n", r->when);
 		}
 	}
 #endif
@@ -1647,7 +1665,7 @@ run_script (struct unw_script *script, s
 			}
 			else {
 				s[dst] = 0;
-				dprintk("unwind.%s: no state->pt, dst=%ld, val=%ld\n", __FUNCTION__, dst, val);
+				UNW_DPRINT(0, "unwind.%s: no state->pt, dst=%ld, val=%ld\n", __FUNCTION__, dst, val);
 			}
 			break;
 
@@ -1676,11 +1694,11 @@ run_script (struct unw_script *script, s
 			break;
 
 		      case UNW_INSN_LOAD:
-#if UNW_DEBUG
+#ifdef UNW_DEBUG
 			if ((s[val] & (local_cpu_data->unimpl_va_mask | 0x7)) != 0
 			    || s[val] < TASK_SIZE)
 			{
-				debug(1, "unwind: rejecting bad psp=0x%lx\n", s[val]);
+				UNW_DPRINT(0, "unwind.%s: rejecting bad psp=0x%lx\n", __FUNCTION__, s[val]);
 				break;
 			}
 #endif
@@ -1713,7 +1731,8 @@ find_save_locs (struct unw_frame_info *i
 
 	if ((info->ip & (local_cpu_data->unimpl_va_mask | 0xf)) || info->ip < TASK_SIZE) {
 		/* don't let obviously bad addresses pollute the cache */
-		debug(1, "unwind: rejecting bad ip=0x%lx\n", info->ip);
+		/* FIXME: should really be level 0 but it occurs too often. KAO */
+		UNW_DPRINT(1, "unwind.%s: rejecting bad ip=0x%lx\n", __FUNCTION__, info->ip);
 		info->rp_loc = 0;
 		return -1;
 	}
@@ -1722,8 +1741,8 @@ find_save_locs (struct unw_frame_info *i
 	if (!scr) {
 		scr = build_script(info);
 		if (!scr) {
-			dprintk("unwind: failed to locate/build unwind script for ip %lx\n",
-				info->ip);
+			UNW_DPRINT(0, "unwind.%s: failed to locate/build unwind script for ip %lx\n",
+				__FUNCTION__, info->ip);
 			return -1;
 		}
 		have_write_lock = 1;
@@ -1756,7 +1775,8 @@ unw_unwind (struct unw_frame_info *info)
 
 	/* restore the ip */
 	if (!info->rp_loc) {
-		debug(1, "unwind: failed to locate return link (ip=0x%lx)!\n", info->ip);
+		/* FIXME: should really be level 0 but it occurs too often. KAO */
+		UNW_DPRINT(1, "unwind.%s: failed to locate return link (ip=0x%lx)!\n",  __FUNCTION__, info->ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1766,14 +1786,14 @@ unw_unwind (struct unw_frame_info *info)
 		 * We don't have unwind info for the gate page, so we consider that part
 		 * of user-space for the purpose of unwinding.
 		 */
-		debug(1, "unwind: reached user-space (ip=0x%lx)\n", ip);
+		UNW_DPRINT(2, "unwind.%s: reached user-space (ip=0x%lx)\n", __FUNCTION__, ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
 
 	/* restore the cfm: */
 	if (!info->pfs_loc) {
-		dprintk("unwind: failed to locate ar.pfs!\n");
+		UNW_DPRINT(0, "unwind.%s: failed to locate ar.pfs!\n", __FUNCTION__);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1788,12 +1808,13 @@ unw_unwind (struct unw_frame_info *info)
 			num_regs = *info->cfm_loc & 0x7f;		/* size of frame */
 		info->pfs_loc  			(unsigned long *) (info->pt + struct_offset(struct pt_regs, ar_pfs));
+		UNW_DPRINT(3, "unwind.%s: interrupt_frame pt 0x%lx\n", __FUNCTION__, info->pt);
 	} else
 		num_regs = (*info->cfm_loc >> 7) & 0x7f;	/* size of locals */
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->bsp, -num_regs);
 	if (info->bsp < info->regstk.limit || info->bsp > info->regstk.top) {
-		dprintk("unwind: bsp (0x%lx) out of range [0x%lx-0x%lx]\n",
-			info->bsp, info->regstk.limit, info->regstk.top);
+		UNW_DPRINT(0, "unwind.%s: bsp (0x%lx) out of range [0x%lx-0x%lx]\n",
+			__FUNCTION__, info->bsp, info->regstk.limit, info->regstk.top);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1801,14 +1822,14 @@ unw_unwind (struct unw_frame_info *info)
 	/* restore the sp: */
 	info->sp = info->psp;
 	if (info->sp < info->memstk.top || info->sp > info->memstk.limit) {
-		dprintk("unwind: sp (0x%lx) out of range [0x%lx-0x%lx]\n",
-			info->sp, info->memstk.top, info->memstk.limit);
+		UNW_DPRINT(0, "unwind.%s: sp (0x%lx) out of range [0x%lx-0x%lx]\n",
+			__FUNCTION__, info->sp, info->memstk.top, info->memstk.limit);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
 
 	if (info->ip = prev_ip && info->sp = prev_sp && info->bsp = prev_bsp) {
-		dprintk("unwind: ip, sp, bsp remain unchanged; stopping here (ip=0x%lx)\n", ip);
+		UNW_DPRINT(0, "unwind.%s: ip, sp, bsp remain unchanged; stopping here (ip=0x%lx)\n", __FUNCTION__, ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1832,7 +1853,7 @@ unw_unwind_to_user (struct unw_frame_inf
 	while (unw_unwind(info) >= 0) {
 		if (unw_get_rp(info, &ip) < 0) {
 			unw_get_ip(info, &ip);
-			dprintk("unwind: failed to read return pointer (ip=0x%lx)\n", ip);
+			UNW_DPRINT(0, "unwind.%s: failed to read return pointer (ip=0x%lx)\n", __FUNCTION__, ip);
 			return -1;
 		}
 		/*
@@ -1843,7 +1864,7 @@ unw_unwind_to_user (struct unw_frame_inf
 			return 0;
 	}
 	unw_get_ip(info, &ip);
-	dprintk("unwind: failed to unwind to user-level (ip=0x%lx)\n", ip);
+	UNW_DPRINT(0, "unwind.%s: failed to unwind to user-level (ip=0x%lx)\n", __FUNCTION__, ip);
 	return -1;
 }
 
@@ -1890,6 +1911,24 @@ unw_init_frame_info (struct unw_frame_in
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->regstk.top, -sol);
 	info->ip = sw->b0;
 	info->pr = sw->pr;
+	UNW_DPRINT(3,
+			"unwind.%s\n"
+			"  rbslimit 0x%lx\n"
+			"  rbstop   0x%lx\n"
+			"  stklimit 0x%lx\n"
+			"  stktop   0x%lx\n"
+			"  task     0x%lx\n"
+			"  sw       0x%lx\n",
+			__FUNCTION__, rbslimit, rbstop, stklimit, stktop,
+			(unsigned long)(info->task),
+			(unsigned long)(info->sw));
+	UNW_DPRINT(3,
+			"  sp/psp   0x%lx\n"
+			"  sol      0x%lx\n"
+			"  bsp      0x%lx\n"
+			"  ip       0x%lx\n"
+			"  pr       0x%lx\n",
+			info->sp, sol, info->bsp, info->ip, info->pr);
 
 	find_save_locs(info);
 	STAT(unw.stat.api.init_time += ia64_get_itc() - start; local_irq_restore(flags));
@@ -1900,6 +1939,7 @@ unw_init_from_blocked_task (struct unw_f
 {
 	struct switch_stack *sw = (struct switch_stack *) (t->thread.ksp + 16);
 
+	UNW_DPRINT(1, "unwind.%s\n", __FUNCTION__);
 	unw_init_frame_info(info, t, sw);
 }
 
@@ -1927,7 +1967,7 @@ unw_add_unwind_table (const char *name, 
 	unsigned long flags;
 
 	if (end - start <= 0) {
-		dprintk("unwind: ignoring attempt to insert empty unwind table\n");
+		UNW_DPRINT(0, "unwind.%s: ignoring attempt to insert empty unwind table\n", __FUNCTION__);
 		return 0;
 	}
 
@@ -1957,13 +1997,13 @@ unw_remove_unwind_table (void *handle)
 	long index;
 
 	if (!handle) {
-		dprintk("unwind: ignoring attempt to remove non-existent unwind table\n");
+		UNW_DPRINT(0, "unwind.%s: ignoring attempt to remove non-existent unwind table\n", __FUNCTION__);
 		return;
 	}
 
 	table = handle;
 	if (table = &unw.kernel_table) {
-		dprintk("unwind: sorry, freeing the kernel's unwind table is a no-can-do!\n");
+		UNW_DPRINT(0, "unwind.%s: sorry, freeing the kernel's unwind table is a no-can-do!\n", __FUNCTION__);
 		return;
 	}
 
@@ -1975,7 +2015,7 @@ unw_remove_unwind_table (void *handle)
 			if (prev->next = table)
 				break;
 		if (!prev) {
-			dprintk("unwind: failed to find unwind table %p\n", (void *) table);
+			UNW_DPRINT(0, "unwind.%s: failed to find unwind table %p\n", __FUNCTION__, (void *) table);
 			spin_unlock_irqrestore(&unw.lock, flags);
 			return;
 		}
@@ -2025,7 +2065,7 @@ unw_create_gate_table (void)
 	unw.gate_table = alloc_bootmem(size);
 	if (!unw.gate_table) {
 		unw.gate_table_size = 0;
-		printk("unwind: unable to create unwind data for gate page!\n");
+		UNW_DPRINT(0, "unwind.%s: unable to create unwind data for gate page!\n", __FUNCTION__);
 		return;
 	}
 	unw.gate_table_size = size;


