From: Keith Owens <kaos@sgi.com>
Date: Thu, 06 May 2004 02:04:13 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <3786.1083809053@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 5 May 2004 17:19:37 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>I'd have preferred if there had been a simple and clean fix to the
>existing unwinder that supports .save rp,r0, but I haven't seen/found
>something acceptable yet.

The clean patch is a bit bigger than the kludge.

Index: 2.6.6-rc3-unwind-r0-fix/arch/ia64/kernel/unwind_i.h
=================================--- 2.6.6-rc3-unwind-r0-fix.orig/arch/ia64/kernel/unwind_i.h	Thu May  6 11:37:18 2004
+++ 2.6.6-rc3-unwind-r0-fix/arch/ia64/kernel/unwind_i.h	Thu May  6 11:37:23 2004
@@ -133,6 +133,7 @@
 	UNW_INSN_SETNAT_TYPE,		/* s[dst+1].nat.type = val */
 	UNW_INSN_LOAD,			/* s[dst] = *s[val] */
 	UNW_INSN_MOVE_SCRATCH,		/* s[dst] = scratch reg "val" */
+	UNW_INSN_MOVE_CONST,		/* s[dst] = constant reg "val" */
 };
 
 struct unw_insn {
Index: 2.6.6-rc3-unwind-r0-fix/arch/ia64/kernel/unwind.c
=================================--- 2.6.6-rc3-unwind-r0-fix.orig/arch/ia64/kernel/unwind.c	Thu May  6 11:37:18 2004
+++ 2.6.6-rc3-unwind-r0-fix/arch/ia64/kernel/unwind.c	Thu May  6 11:57:29 2004
@@ -1407,6 +1407,9 @@
 				need_nat_info = 0;
 			}
 			val = unw.preg_index[UNW_REG_R4 + (rval - 4)];
+		} else if (rval = 0) {
+			opc = UNW_INSN_MOVE_CONST;
+			val = 0;
 		} else {
 			/* register got spilled to a scratch register */
 			opc = UNW_INSN_MOVE_SCRATCH;
@@ -1729,6 +1732,17 @@
 			}
 			break;
 
+		      case UNW_INSN_MOVE_CONST:
+			if (val = 0) {
+				static const unsigned long unw_r0;
+				s[dst] = (unsigned long)&unw_r0;
+			} else {
+				s[dst] = 0;
+				UNW_DPRINT(0, "unwind.%s: UNW_INSN_MOVE_CONST bad val=%ld\n",
+					   __FUNCTION__, val);
+			}
+			break;
+
 		      case UNW_INSN_MOVE_STACKED:
 			s[dst] = (unsigned long) ia64_rse_skip_regs((unsigned long *)state->bsp,
 								    val);

