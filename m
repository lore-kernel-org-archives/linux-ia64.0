From: Keith Owens <kaos@sgi.com>
Date: Mon, 17 Feb 2003 06:16:53 +0000
Subject: [Linux-ia64] [patch] 2.4.20 unwind.c to handle multiple struct pt_regs
Message-Id: <marc-linux-ia64-105590709805864@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch has been running inside SGI for 2 months.  It handles kernel
stacks with multiple struct pt_regs, as found while debugging the
kernel.  The debugging statements in the unwind code were awkward to
use and inconsistent in what was being dumped and when, I ended up
changing almost all the unwind debugging code while tracking down this
problem.

Patch is against 2.4.20-ia64-021210, it fits 2.4.19 as well.

--- include/asm-ia64/unwind.h	Sun Aug  5 13:29:36 2001
+++ include/asm-ia64/unwind.h	Tue Feb  4 12:24:01 2003
@@ -60,6 +60,7 @@
 	unsigned long ip;		/* instruction pointer value */
 	unsigned long pr;		/* current predicate values */
 	unsigned long *cfm_loc;		/* cfm save location (or NULL) */
+	unsigned long pt;		/* struct pt_regs location */
 
 	struct task_struct *task;
 	struct switch_stack *sw;
--- arch/ia64/kernel/unwind_i.h	Fri Nov 29 11:39:02 2002
+++ arch/ia64/kernel/unwind_i.h	Tue Feb  4 12:13:47 2003
@@ -137,7 +137,8 @@
 	UNW_INSN_SETNAT_MEMSTK,		/* s[dst+1].nat.type = MEMSTK;
 					   s[dst+1].nat.off = *s.pri_unat - s[dst] */
 	UNW_INSN_SETNAT_TYPE,		/* s[dst+1].nat.type = val */
-	UNW_INSN_LOAD			/* s[dst] = *s[val] */
+	UNW_INSN_LOAD,			/* s[dst] = *s[val] */
+	UNW_INSN_MOVE_SCRATCH,		/* s[dst] = scratch reg "val" */
 };
 
 struct unw_insn {
--- arch/ia64/kernel/unwind.c	Fri Nov 29 11:39:02 2002
+++ arch/ia64/kernel/unwind.c	Tue Feb  4 12:13:47 2003
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
+    #define UNW_DEBUG_PRINT(n, ...)  if (UNW_DEBUG_ON(n)) kdb_printf(__VA_ARGS__)
+  #else	/* !CONFIG_KDB */
+    #define UNW_DEBUG_ON(n)  unw_debug_level >= n
+    /* Do not code a printk level, not all debug lines end in newline */
+    #define UNW_DEBUG_PRINT(n, ...)  if (UNW_DEBUG_ON(n)) printk(__VA_ARGS__)
+  #endif	/* CONFIG_KDB */
+  #define inline
+#else	/* !UNW_DEBUG */
+  #define UNW_DEBUG_ON(n)  0
+  #define UNW_DEBUG_PRINT(n, ...)
+#endif	/* UNW_DEBUG */
 
 #if UNW_STATS
 # define STAT(x...)	x
@@ -111,7 +117,7 @@
 	/* script cache: */
 	struct unw_script cache[UNW_CACHE_SIZE];
 
-# if UNW_DEBUG
+# ifdef UNW_DEBUG
 	const char *preg_name[UNW_NUM_REGS];
 # endif
 # if UNW_STATS
@@ -190,7 +196,7 @@
 		struct_offset(struct unw_frame_info, fr_loc[31 - 16])/8,
 	},
 	hash : { [0 ... UNW_HASH_SIZE - 1] = -1 },
-#if UNW_DEBUG
+#ifdef UNW_DEBUG
 	preg_name: {
 		"pri_unat_gr", "pri_unat_mem", "bsp", "bspstore", "ar.pfs", "ar.rnat", "psp", "rp",
 		"r4", "r5", "r6", "r7",
@@ -223,19 +229,31 @@
 	else if (reg <= 31)
 		off = struct_offset(struct pt_regs, r16) + 8*(reg - 16);
 	else
-		dprintk("unwind: bad scratch reg r%lu\n", reg);
+		UNW_DEBUG_PRINT(0, "unwind.%s: bad scratch reg r%lu\n", __FUNCTION__, reg);
 	return off;
 }
 
+static void
+dump_info_pt(struct unw_frame_info *info, const char *func)
+{
+	/* WAR for no struct pt_regs, may be caused by bad unwind data.  KAO */
+	if (!info->pt) {
+		UNW_DEBUG_PRINT(0, "unwind.%s: sp 0x%lx pt 0x%lx, set to 0x%lx\n", func, info->sp, info->pt, info->sp - 16);
+		info->pt = info->sp - 16;
+	}
+	else {
+		UNW_DEBUG_PRINT(3, "unwind.%s: sp 0x%lx pt 0x%lx\n", func, info->sp, info->pt);
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
-		dprintk("unwind: trying to access non-existent r%u\n", regnum);
+		UNW_DEBUG_PRINT(0, "unwind.%s: trying to access non-existent r%u\n", __FUNCTION__, regnum);
 		return -1;
 	}
 
@@ -280,8 +298,9 @@
 					if ((unsigned long) addr < info->regstk.limit
 					    || (unsigned long) addr >= info->regstk.top)
 					{
-						dprintk("unwind: %p outside of regstk "
-							"[0x%lx-0x%lx)\n", (void *) addr,
+						UNW_DEBUG_PRINT(0, "unwind.%s: %p outside of regstk "
+							"[0x%lx-0x%lx)\n",
+							__FUNCTION__, (void *) addr,
 							info->regstk.limit,
 							info->regstk.top);
 						return -1;
@@ -298,11 +317,8 @@
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
@@ -316,7 +332,7 @@
 		if ((unsigned long) addr < info->regstk.limit
 		    || (unsigned long) addr >= info->regstk.top)
 		{
-			dprintk("unwind: ignoring attempt to access register outside of rbs\n");
+			UNW_DEBUG_PRINT(0, "unwind.%s: ignoring attempt to access register outside of rbs\n",  __FUNCTION__);
 			return -1;
 		}
 		if ((unsigned long) nat_addr >= info->regstk.top)
@@ -348,10 +364,8 @@
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
@@ -366,7 +380,7 @@
 		break;
 
 	      default:
-		dprintk("unwind: trying to access non-existent b%u\n", regnum);
+		UNW_DEBUG_PRINT(0, "unwind.%s: trying to access non-existent b%u\n", __FUNCTION__, regnum);
 		return -1;
 	}
 	if (write)
@@ -383,14 +397,12 @@
 	struct pt_regs *pt;
 
 	if ((unsigned) (regnum - 2) >= 126) {
-		dprintk("unwind: trying to access non-existent f%u\n", regnum);
+		UNW_DEBUG_PRINT(0, "unwind.%s: trying to access non-existent f%u\n", __FUNCTION__, regnum);
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
@@ -428,10 +440,8 @@
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
@@ -495,7 +505,7 @@
 		break;
 
 	      default:
-		dprintk("unwind: trying to access non-existent ar%u\n", regnum);
+		UNW_DEBUG_PRINT(0, "unwind.%s: trying to access non-existent ar%u\n", __FUNCTION__, regnum);
 		return -1;
 	}
 
@@ -532,7 +542,7 @@
 
 	rs = alloc_reg_state();
 	if (!rs) {
-		printk("unwind: cannot stack reg state!\n");
+		UNW_DEBUG_PRINT(0, "unwind.%s: cannot stack reg state!\n", __FUNCTION__);
 		return;
 	}
 	memcpy(rs, &sr->curr, sizeof(*rs));
@@ -545,7 +555,7 @@
 	struct unw_reg_state *rs = sr->curr.next;
 
 	if (!rs) {
-		printk("unwind: stack underflow!\n");
+		UNW_DEBUG_PRINT(0, "unwind.%s: stack underflow!\n",  __FUNCTION__);
 		return;
 	}
 	memcpy(&sr->curr, rs, sizeof(*rs));
@@ -561,7 +571,7 @@
 	while (rs) {
 		copy = alloc_reg_state();
 		if (!copy) {
-			printk ("unwind.dup_state_stack: out of memory\n");
+			UNW_DEBUG_PRINT(0, "unwind.%s: out of memory\n",  __FUNCTION__);
 			return NULL;
 		}
 		memcpy(copy, rs, sizeof(*copy));
@@ -612,7 +622,7 @@
 	      default:
 		break;
 	}
-	dprintk("unwind: bad abreg=0x%x\n", abreg);
+	UNW_DEBUG_PRINT(0, "unwind.%s: bad abreg=0x%x\n", __FUNCTION__, abreg);
 	return UNW_REG_LC;
 }
 
@@ -652,7 +662,7 @@
 			return;
 		}
 	}
-	dprintk("unwind: excess spill!\n");
+	UNW_DEBUG_PRINT(0, "unwind.%s: excess spill!\n",  __FUNCTION__);
 }
 
 static inline void
@@ -765,10 +775,13 @@
 static inline void
 desc_abi (unsigned char abi, unsigned char context, struct unw_state_record *sr)
 {
-	if (abi = 0 && context = 'i')
+	if (abi = 0 && context = 'i') {
 		sr->flags |= UNW_FLAG_INTERRUPT_FRAME;
+		UNW_DEBUG_PRINT(3, "unwind.%s: interrupt frame\n",  __FUNCTION__);
+	}
 	else
-		dprintk("unwind: ignoring unwabi(abi=0x%x,context=0x%x)\n", abi, context);
+		UNW_DEBUG_PRINT(0, "unwind%s: ignoring unwabi(abi=0x%x,context=0x%x)\n",
+				__FUNCTION__, abi, context);
 }
 
 static inline void
@@ -951,7 +964,7 @@
 			return;
 		}
 	}
-	printk("unwind: failed to find state labeled 0x%lx\n", label);
+	UNW_DEBUG_PRINT(0, "unwind.%s: failed to find state labeled 0x%lx\n", __FUNCTION__, label);
 }
 
 static inline void
@@ -961,7 +974,7 @@
 
 	ls = alloc_labeled_state();
 	if (!ls) {
-		printk("unwind.desc_label_state(): out of memory\n");
+		UNW_DEBUG_PRINT(0, "unwind.%s: out of memory\n",  __FUNCTION__);
 		return;
 	}
 	ls->label = label;
@@ -1055,7 +1068,7 @@
 	r->val = 4*spoff;
 }
 
-#define UNW_DEC_BAD_CODE(code)			printk("unwind: unknown code 0x%02x\n", code);
+#define UNW_DEC_BAD_CODE(code)			UNW_DEBUG_PRINT(0, "unwind.%s: unknown code 0x%02x\n", __FUNCTION__, code);
 
 /*
  * region headers:
@@ -1134,6 +1147,8 @@
 	struct unw_script *script = unw.cache + info->hint;
 	unsigned short index;
 	unsigned long ip, pr;
+	if (UNW_DEBUG_ON(0))
+		return 0;	/* Always regenerate scripts in debug mode */
 
 	STAT(++unw.stat.cache.lookups);
 
@@ -1259,8 +1274,8 @@
 script_emit (struct unw_script *script, struct unw_insn insn)
 {
 	if (script->count >= UNW_MAX_SCRIPT_LEN) {
-		dprintk("unwind: script exceeds maximum size of %u instructions!\n",
-			UNW_MAX_SCRIPT_LEN);
+		UNW_DEBUG_PRINT(0, "unwind.%s: script exceeds maximum size of %u instructions!\n",
+			__FUNCTION__, UNW_MAX_SCRIPT_LEN);
 		return;
 	}
 	script->insn[script->count++] = insn;
@@ -1301,7 +1316,7 @@
 		break;
 
 	      default:
-		dprintk("unwind: don't know how to emit nat info for where = %u\n", r->where);
+		UNW_DEBUG_PRINT(0, "unwind.%s: don't know how to emit nat info for where = %u\n", __FUNCTION__, r->where);
 		return;
 	}
 	insn.opc = opc;
@@ -1338,8 +1353,9 @@
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
 
@@ -1349,12 +1365,11 @@
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
-				dprintk("unwind: kernel may not touch f%lu\n", rval);
+				UNW_DEBUG_PRINT(0, "unwind.%s: kernel may not touch f%lu\n", __FUNCTION__, rval);
 		}
 		break;
 
@@ -1362,14 +1377,13 @@
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
 
@@ -1382,7 +1396,7 @@
 		break;
 
 	      default:
-		dprintk("unwind: register %u has unexpected `where' value of %u\n", i, r->where);
+		UNW_DEBUG_PRINT(0, "unwind%s: register %u has unexpected `where' value of %u\n", __FUNCTION__, i, r->where);
 		break;
 	}
 	insn.opc = opc;
@@ -1455,9 +1469,10 @@
 		r->when = UNW_WHEN_NEVER;
 	sr.pr_val = info->pr;
 
+	UNW_DEBUG_PRINT(3, "unwind.%s: ip 0x%lx\n", __FUNCTION__, ip);
 	script = script_new(ip);
 	if (!script) {
-		dprintk("unwind: failed to create unwind script\n");
+		UNW_DEBUG_PRINT(0, "unwind.%s: failed to create unwind script\n",  __FUNCTION__);
 		STAT(unw.stat.script.build_time += ia64_get_itc() - start);
 		return 0;
 	}
@@ -1475,8 +1490,8 @@
 	}
 	if (!e) {
 		/* no info, return default unwinder (leaf proc, no mem stack, no saved regs)  */
-		dprintk("unwind: no unwind info for ip=0x%lx (prev ip=0x%lx)\n", ip,
-			unw.cache[info->prev_script].ip);
+		UNW_DEBUG_PRINT(1, "unwind.%s: no unwind info for ip=0x%lx (prev ip=0x%lx)\n",
+			__FUNCTION__, ip, unw.cache[info->prev_script].ip);
 		sr.curr.reg[UNW_REG_RP].where = UNW_WHERE_BR;
 		sr.curr.reg[UNW_REG_RP].when = -1;
 		sr.curr.reg[UNW_REG_RP].val = 0;
@@ -1524,26 +1539,28 @@
 		sr.curr.reg[UNW_REG_RP].where = UNW_WHERE_BR;
 		sr.curr.reg[UNW_REG_RP].when = -1;
 		sr.curr.reg[UNW_REG_RP].val = sr.return_link_reg;
+		UNW_DEBUG_PRINT(1, "unwind.%s: using default for rp at ip=0x%lx where=%d val=0x%lx\n",
+			__FUNCTION__, ip, sr.curr.reg[UNW_REG_RP].where, sr.curr.reg[UNW_REG_RP].val);
 	}
 
-#if UNW_DEBUG
-	printk("unwind: state record for func 0x%lx, t=%u:\n",
-	       table->segment_base + e->start_offset, sr.when_target);
+#ifdef UNW_DEBUG
+	UNW_DEBUG_PRINT(1, "unwind.%s: state record for func 0x%lx, t=%u:\n",
+		__FUNCTION__, table->segment_base + e->start_offset, sr.when_target);
 	for (r = sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r) {
 		if (r->where != UNW_WHERE_NONE || r->when != UNW_WHEN_NEVER) {
-			printk("  %s <- ", unw.preg_name[r - sr.curr.reg]);
+			UNW_DEBUG_PRINT(1, "  %s <- ", unw.preg_name[r - sr.curr.reg]);
 			switch (r->where) {
-			      case UNW_WHERE_GR:     printk("r%lu", r->val); break;
-			      case UNW_WHERE_FR:     printk("f%lu", r->val); break;
-			      case UNW_WHERE_BR:     printk("b%lu", r->val); break;
-			      case UNW_WHERE_SPREL:  printk("[sp+0x%lx]", r->val); break;
-			      case UNW_WHERE_PSPREL: printk("[psp+0x%lx]", r->val); break;
+			      case UNW_WHERE_GR:     UNW_DEBUG_PRINT(1, "r%lu", r->val); break;
+			      case UNW_WHERE_FR:     UNW_DEBUG_PRINT(1, "f%lu", r->val); break;
+			      case UNW_WHERE_BR:     UNW_DEBUG_PRINT(1, "b%lu", r->val); break;
+			      case UNW_WHERE_SPREL:  UNW_DEBUG_PRINT(1, "[sp+0x%lx]", r->val); break;
+			      case UNW_WHERE_PSPREL: UNW_DEBUG_PRINT(1, "[psp+0x%lx]", r->val); break;
 			      case UNW_WHERE_NONE:
-				printk("%s+0x%lx", unw.preg_name[r - sr.curr.reg], r->val);
+				UNW_DEBUG_PRINT(1, "%s+0x%lx", unw.preg_name[r - sr.curr.reg], r->val);
 				break;
-			      default:		     printk("BADWHERE(%d)", r->where); break;
+			      default:		     UNW_DEBUG_PRINT(1, "BADWHERE(%d)", r->where); break;
 			}
-			printk("\t\t%d\n", r->when);
+			UNW_DEBUG_PRINT(1, "\t\t%d\n", r->when);
 		}
 	}
 #endif
@@ -1641,6 +1658,18 @@
 			s[dst] = s[val];
 			break;
 
+		      case UNW_INSN_MOVE_SCRATCH:
+			if (state->pt) {
+				dump_info_pt(state,  __FUNCTION__);
+				UNW_DEBUG_PRINT(6, "unwind.%s: dst %ld val %ld\n", __FUNCTION__, dst, val);
+				s[dst] = state->pt+val;
+			}
+			else {
+				s[dst] = 0;
+				UNW_DEBUG_PRINT(0, "unwind.%s: no state->pt, dst=%ld, val=%ld\n", __FUNCTION__, dst, val);
+			}
+			break;
+
 		      case UNW_INSN_MOVE_STACKED:
 			s[dst] = (unsigned long) ia64_rse_skip_regs((unsigned long *)state->bsp,
 								    val);
@@ -1666,11 +1695,11 @@
 			break;
 
 		      case UNW_INSN_LOAD:
-#if UNW_DEBUG
+#ifdef UNW_DEBUG
 			if ((s[val] & (local_cpu_data->unimpl_va_mask | 0x7)) != 0
 			    || s[val] < TASK_SIZE)
 			{
-				debug(1, "unwind: rejecting bad psp=0x%lx\n", s[val]);
+				UNW_DEBUG_PRINT(0, "unwind.%s: rejecting bad psp=0x%lx\n", __FUNCTION__, s[val]);
 				break;
 			}
 #endif
@@ -1703,7 +1732,8 @@
 
 	if ((info->ip & (local_cpu_data->unimpl_va_mask | 0xf)) || info->ip < TASK_SIZE) {
 		/* don't let obviously bad addresses pollute the cache */
-		debug(1, "unwind: rejecting bad ip=0x%lx\n", info->ip);
+		/* FIXME: should really be level 0 but it occurs too often. KAO */
+		UNW_DEBUG_PRINT(1, "unwind.%s: rejecting bad ip=0x%lx\n", __FUNCTION__, info->ip);
 		info->rp_loc = 0;
 		return -1;
 	}
@@ -1712,8 +1742,8 @@
 	if (!scr) {
 		scr = build_script(info);
 		if (!scr) {
-			dprintk("unwind: failed to locate/build unwind script for ip %lx\n",
-				info->ip);
+			UNW_DEBUG_PRINT(0, "unwind.%s: failed to locate/build unwind script for ip %lx\n",
+				__FUNCTION__, info->ip);
 			return -1;
 		}
 		have_write_lock = 1;
@@ -1746,7 +1776,8 @@
 
 	/* restore the ip */
 	if (!info->rp_loc) {
-		debug(1, "unwind: failed to locate return link (ip=0x%lx)!\n", info->ip);
+		/* FIXME: should really be level 0 but it occurs too often. KAO */
+		UNW_DEBUG_PRINT(1, "unwind.%s: failed to locate return link (ip=0x%lx)!\n",  __FUNCTION__, info->ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1756,14 +1787,14 @@
 		 * We don't have unwind info for the gate page, so we consider that part
 		 * of user-space for the purpose of unwinding.
 		 */
-		debug(1, "unwind: reached user-space (ip=0x%lx)\n", ip);
+		UNW_DEBUG_PRINT(2, "unwind.%s: reached user-space (ip=0x%lx)\n", __FUNCTION__, ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
 
 	/* restore the cfm: */
 	if (!info->pfs_loc) {
-		dprintk("unwind: failed to locate ar.pfs!\n");
+		UNW_DEBUG_PRINT(0, "unwind.%s: failed to locate ar.pfs!\n", __FUNCTION__);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1773,16 +1804,18 @@
 	pr = info->pr;
 	num_regs = 0;
 	if ((info->flags & UNW_FLAG_INTERRUPT_FRAME)) {
+		info->pt = info->sp + 16;
 		if ((pr & (1UL << pNonSys)) != 0)
 			num_regs = *info->cfm_loc & 0x7f;		/* size of frame */
 		info->pfs_loc -			(unsigned long *) (info->sp + 16 + struct_offset(struct pt_regs, ar_pfs));
+			(unsigned long *) (info->pt + struct_offset(struct pt_regs, ar_pfs));
+		UNW_DEBUG_PRINT(3, "unwind.%s: interrupt_frame pt 0x%lx\n", __FUNCTION__, info->pt);
 	} else
 		num_regs = (*info->cfm_loc >> 7) & 0x7f;	/* size of locals */
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->bsp, -num_regs);
 	if (info->bsp < info->regstk.limit || info->bsp > info->regstk.top) {
-		dprintk("unwind: bsp (0x%lx) out of range [0x%lx-0x%lx]\n",
-			info->bsp, info->regstk.limit, info->regstk.top);
+		UNW_DEBUG_PRINT(0, "unwind.%s: bsp (0x%lx) out of range [0x%lx-0x%lx]\n",
+			__FUNCTION__, info->bsp, info->regstk.limit, info->regstk.top);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1790,14 +1823,14 @@
 	/* restore the sp: */
 	info->sp = info->psp;
 	if (info->sp < info->memstk.top || info->sp > info->memstk.limit) {
-		dprintk("unwind: sp (0x%lx) out of range [0x%lx-0x%lx]\n",
-			info->sp, info->memstk.top, info->memstk.limit);
+		UNW_DEBUG_PRINT(0, "unwind.%s: sp (0x%lx) out of range [0x%lx-0x%lx]\n",
+			__FUNCTION__, info->sp, info->memstk.top, info->memstk.limit);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
 
 	if (info->ip = prev_ip && info->sp = prev_sp && info->bsp = prev_bsp) {
-		dprintk("unwind: ip, sp, bsp remain unchanged; stopping here (ip=0x%lx)\n", ip);
+		UNW_DEBUG_PRINT(0, "unwind.%s: ip, sp, bsp remain unchanged; stopping here (ip=0x%lx)\n", __FUNCTION__, ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1821,7 +1854,7 @@
 	while (unw_unwind(info) >= 0) {
 		if (unw_get_rp(info, &ip) < 0) {
 			unw_get_ip(info, &ip);
-			dprintk("unwind: failed to read return pointer (ip=0x%lx)\n", ip);
+			UNW_DEBUG_PRINT(0, "unwind.%s: failed to read return pointer (ip=0x%lx)\n", __FUNCTION__, ip);
 			return -1;
 		}
 		/*
@@ -1832,7 +1865,7 @@
 			return 0;
 	}
 	unw_get_ip(info, &ip);
-	dprintk("unwind: failed to unwind to user-level (ip=0x%lx)\n", ip);
+	UNW_DEBUG_PRINT(0, "unwind.%s: failed to unwind to user-level (ip=0x%lx)\n", __FUNCTION__, ip);
 	return -1;
 }
 
@@ -1873,11 +1906,30 @@
 	info->task = t;
 	info->sw  = sw;
 	info->sp = info->psp = (unsigned long) (sw + 1) - 16;
+	info->pt = 0;
 	info->cfm_loc = &sw->ar_pfs;
 	sol = (*info->cfm_loc >> 7) & 0x7f;
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->regstk.top, -sol);
 	info->ip = sw->b0;
 	info->pr = sw->pr;
+	UNW_DEBUG_PRINT(3,
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
+	UNW_DEBUG_PRINT(3,
+			"  sp/psp   0x%lx\n"
+			"  sol      0x%lx\n"
+			"  bsp      0x%lx\n"
+			"  ip       0x%lx\n"
+			"  pr       0x%lx\n",
+			info->sp, sol, info->bsp, info->ip, info->pr);
 
 	find_save_locs(info);
 	STAT(unw.stat.api.init_time += ia64_get_itc() - start; local_irq_restore(flags));
@@ -1888,6 +1940,7 @@
 {
 	struct switch_stack *sw = (struct switch_stack *) (t->thread.ksp + 16);
 
+	UNW_DEBUG_PRINT(1, "unwind.%s\n", __FUNCTION__);
 	unw_init_frame_info(info, t, sw);
 }
 
@@ -1915,7 +1968,7 @@
 	unsigned long flags;
 
 	if (end - start <= 0) {
-		dprintk("unwind: ignoring attempt to insert empty unwind table\n");
+		UNW_DEBUG_PRINT(0, "unwind.%s: ignoring attempt to insert empty unwind table\n", __FUNCTION__);
 		return 0;
 	}
 
@@ -1945,13 +1998,13 @@
 	long index;
 
 	if (!handle) {
-		dprintk("unwind: ignoring attempt to remove non-existent unwind table\n");
+		UNW_DEBUG_PRINT(0, "unwind.%s: ignoring attempt to remove non-existent unwind table\n", __FUNCTION__);
 		return;
 	}
 
 	table = handle;
 	if (table = &unw.kernel_table) {
-		dprintk("unwind: sorry, freeing the kernel's unwind table is a no-can-do!\n");
+		UNW_DEBUG_PRINT(0, "unwind.%s: sorry, freeing the kernel's unwind table is a no-can-do!\n", __FUNCTION__);
 		return;
 	}
 
@@ -1963,7 +2016,7 @@
 			if (prev->next = table)
 				break;
 		if (!prev) {
-			dprintk("unwind: failed to find unwind table %p\n", (void *) table);
+			UNW_DEBUG_PRINT(0, "unwind.%s: failed to find unwind table %p\n", __FUNCTION__, (void *) table);
 			spin_unlock_irqrestore(&unw.lock, flags);
 			return;
 		}
@@ -2013,7 +2066,7 @@
 	unw.gate_table = alloc_bootmem(size);
 	if (!unw.gate_table) {
 		unw.gate_table_size = 0;
-		printk("unwind: unable to create unwind data for gate page!\n");
+		UNW_DEBUG_PRINT(0, "unwind.%s: unable to create unwind data for gate page!\n", __FUNCTION__);
 		return;
 	}
 	unw.gate_table_size = size;


