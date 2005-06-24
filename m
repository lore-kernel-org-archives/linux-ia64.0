From: Keith Owens <kaos@sgi.com>
Date: Fri, 24 Jun 2005 05:20:38 +0000
Subject: [patch 2.6.12] unwind.c uses wrong unat from switch_stack
Message-Id: <9996.1119590438@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm not sure if this is an error, or if I have misunderstood the use of
two fields in struct switch_stack, but it looks like unwind.c can read
the wrong unat bits from switch_stack.  sw->caller_unat is the value of
ar.unat when the task was blocked.  sw->ar_unat is the value of ar.unat
after doing st8.spill for r4-7.  IOW, ar_unat is caller_unat with 4
bits changed.

unw_access_gr() uses sw->ar_unat for r4-7 (correct), but it also uses
sw->ar_unat for other scratch registers (incorrect).  sw->ar_unat
should only be used for r4-7, everything else should use
sw->caller_unat, unless modified by unwind info.  Using sw->ar_unat
risks picking up the 4 bits that were overwritten when r4-7 were saved.

Also this line is wrong
	unw.sw_off[unw.preg_index[UNW_REG_PFS]] = SW(AR_UNAT);
and should be
	unw.sw_off[unw.preg_index[UNW_REG_PFS]] = SW(AR_PFS);

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/unwind.c
=================================--- linux.orig/arch/ia64/kernel/unwind.c	2005-06-24 15:19:56.245556835 +1000
+++ linux/arch/ia64/kernel/unwind.c	2005-06-24 15:22:08.194843143 +1000
@@ -362,7 +362,7 @@ unw_access_gr (struct unw_frame_info *in
 			if (info->pri_unat_loc)
 				nat_addr = info->pri_unat_loc;
 			else
-				nat_addr = &info->sw->ar_unat;
+				nat_addr = &info->sw->caller_unat;
 			nat_mask = (1UL << ((long) addr & 0x1f8)/8);
 		}
 	} else {
@@ -524,7 +524,7 @@ unw_access_ar (struct unw_frame_info *in
 	      case UNW_AR_UNAT:
 		addr = info->unat_loc;
 		if (!addr)
-			addr = &info->sw->ar_unat;
+			addr = &info->sw->caller_unat;
 		break;
 
 	      case UNW_AR_LC:
@@ -1775,7 +1775,7 @@ run_script (struct unw_script *script, s
 
 		      case UNW_INSN_SETNAT_MEMSTK:
 			if (!state->pri_unat_loc)
-				state->pri_unat_loc = &state->sw->ar_unat;
+				state->pri_unat_loc = &state->sw->caller_unat;
 			/* register off. is a multiple of 8, so the least 3 bits (type) are 0 */
 			s[dst+1] = ((unsigned long) state->pri_unat_loc - s[dst]) | UNW_NAT_MEMSTK;
 			break;
@@ -2243,11 +2243,11 @@ unw_init (void)
 	if (8*sizeof(unw_hash_index_t) < UNW_LOG_HASH_SIZE)
 		unw_hash_index_t_is_too_narrow();
 
-	unw.sw_off[unw.preg_index[UNW_REG_PRI_UNAT_GR]] = SW(AR_UNAT);
+	unw.sw_off[unw.preg_index[UNW_REG_PRI_UNAT_GR]] = SW(CALLER_UNAT);
 	unw.sw_off[unw.preg_index[UNW_REG_BSPSTORE]] = SW(AR_BSPSTORE);
-	unw.sw_off[unw.preg_index[UNW_REG_PFS]] = SW(AR_UNAT);
+	unw.sw_off[unw.preg_index[UNW_REG_PFS]] = SW(AR_PFS);
 	unw.sw_off[unw.preg_index[UNW_REG_RP]] = SW(B0);
-	unw.sw_off[unw.preg_index[UNW_REG_UNAT]] = SW(AR_UNAT);
+	unw.sw_off[unw.preg_index[UNW_REG_UNAT]] = SW(CALLER_UNAT);
 	unw.sw_off[unw.preg_index[UNW_REG_PR]] = SW(PR);
 	unw.sw_off[unw.preg_index[UNW_REG_LC]] = SW(AR_LC);
 	unw.sw_off[unw.preg_index[UNW_REG_FPSR]] = SW(AR_FPSR);

