From: Keith Owens <kaos@sgi.com>
Date: Fri, 07 May 2004 08:12:49 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <11822.1083917569@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 5 May 2004 20:42:24 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>I considered that approach but rejected it because it runs the
>"FORTRAN constant" risk.  That is, someone might write to a saved
>register (e.g., via unw_set_br()) and end up inadvertently redefining
>the 0 "constant" (unw_r0) to a non-zero value.
>
>Perhaps what we could do is change unw_access_{gr,br,fr,ar,pr} to
>reject attempts to write to the special save-address &unw_r0.  I think
>that would make it safe.

Unlikely, but if that is what it takes ....

Index: 2.6.6-rc3-unwind-r0-fix/arch/ia64/kernel/unwind.c
=================================--- 2.6.6-rc3-unwind-r0-fix.orig/arch/ia64/kernel/unwind.c	Thu May  6 11:37:18 2004
+++ 2.6.6-rc3-unwind-r0-fix/arch/ia64/kernel/unwind.c	Fri May  7 18:00:49 2004
@@ -239,6 +239,18 @@ static struct {
 #endif
 };
 
+static const unsigned long unw_r0;
+
+static inline int
+unw_write_valid(unsigned long *addr)
+{
+	if (addr = &unw_r0) {
+		UNW_DPRINT(0, "unwind.%s: attempt to write to constant register r0\n", __FUNCTION__);
+		return 0;
+	}
+	return 1;
+}
+
 /* Unwind accessors.  */
 
 /*
@@ -377,11 +389,13 @@ unw_access_gr (struct unw_frame_info *in
 	}
 
 	if (write) {
-		*addr = *val;
-		if (*nat)
-			*nat_addr |= nat_mask;
-		else
-			*nat_addr &= ~nat_mask;
+		if (unw_write_valid(addr)) {
+			*addr = *val;
+			if (*nat)
+				*nat_addr |= nat_mask;
+			else
+				*nat_addr &= ~nat_mask;
+		}
 	} else {
 		if ((*nat_addr & nat_mask) = 0) {
 			*val = *addr;
@@ -419,9 +433,10 @@ unw_access_br (struct unw_frame_info *in
 			   __FUNCTION__, regnum);
 		return -1;
 	}
-	if (write)
-		*addr = *val;
-	else
+	if (write) {
+		if (unw_write_valid(addr))
+			*addr = *val;
+	} else
 		*val = *addr;
 	return 0;
 }
@@ -464,9 +479,10 @@ unw_access_fr (struct unw_frame_info *in
 		addr = t->thread.fph + (regnum - 32);
 	}
 
-	if (write)
-		*addr = *val;
-	else
+	if (write) {
+		if (unw_write_valid((unsigned long *)addr))
+			*addr = *val;
+	} else
 		*val = *addr;
 	return 0;
 }
@@ -557,9 +573,10 @@ unw_access_ar (struct unw_frame_info *in
 		return -1;
 	}
 
-	if (write)
-		*addr = *val;
-	else
+	if (write) {
+		if (unw_write_valid(addr))
+			*addr = *val;
+	} else
 		*val = *addr;
 	return 0;
 }
@@ -574,9 +591,10 @@ unw_access_pr (struct unw_frame_info *in
 	if (!addr)
 		addr = &info->sw->pr;
 
-	if (write)
-		*addr = *val;
-	else
+	if (write) {
+		if (unw_write_valid(addr))
+			*addr = *val;
+	} else
 		*val = *addr;
 	return 0;
 }
@@ -1407,6 +1425,9 @@ compile_reg (struct unw_state_record *sr
 				need_nat_info = 0;
 			}
 			val = unw.preg_index[UNW_REG_R4 + (rval - 4)];
+		} else if (rval = 0) {
+			opc = UNW_INSN_MOVE_CONST;
+			val = 0;
 		} else {
 			/* register got spilled to a scratch register */
 			opc = UNW_INSN_MOVE_SCRATCH;
@@ -1729,6 +1750,16 @@ run_script (struct unw_script *script, s
 			}
 			break;
 
+		      case UNW_INSN_MOVE_CONST:
+			if (val = 0)
+				s[dst] = (unsigned long)&unw_r0;
+			else {
+				s[dst] = 0;
+				UNW_DPRINT(0, "unwind.%s: UNW_INSN_MOVE_CONST bad val=%ld\n",
+					   __FUNCTION__, val);
+			}
+			break;
+
 		      case UNW_INSN_MOVE_STACKED:
 			s[dst] = (unsigned long) ia64_rse_skip_regs((unsigned long *)state->bsp,
 								    val);
Index: 2.6.6-rc3-unwind-r0-fix/arch/ia64/kernel/unwind_i.h
=================================--- 2.6.6-rc3-unwind-r0-fix.orig/arch/ia64/kernel/unwind_i.h	Thu May  6 11:37:18 2004
+++ 2.6.6-rc3-unwind-r0-fix/arch/ia64/kernel/unwind_i.h	Thu May  6 11:37:23 2004
@@ -133,6 +133,7 @@ enum unw_insn_opcode {
 	UNW_INSN_SETNAT_TYPE,		/* s[dst+1].nat.type = val */
 	UNW_INSN_LOAD,			/* s[dst] = *s[val] */
 	UNW_INSN_MOVE_SCRATCH,		/* s[dst] = scratch reg "val" */
+	UNW_INSN_MOVE_CONST,		/* s[dst] = constant reg "val" */
 };
 
 struct unw_insn {

