From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 21 Jun 2003 06:05:30 +0000
Subject: Re: [Linux-ia64] sigaltstack and ar.bspstore
Message-Id: <marc-linux-ia64-105617581915447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706086@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706086@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 31 May 2003 00:18:39 +1000, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> Currently when using an alternate stack for signal handling,
  Matt> the trampoline code switches to the new register stack without
  Matt> saving bspstore.  When returning to the original register
  Matt> stack, it calculates the bspstore as:

  Matt>   bspstore0 = rse_skip_regs(bsp0, -rse_num_regs(bsp1 - (loadrs
  Matt> >> 19), bsp1)); where bsp0 is sc->sc_ar_bsp and bsp1 is the
  Matt> current bsp

  Matt> Presumably the result should be the same as the original
  Matt> bspstore.  However, it isn't in the case when the original
  Matt> bspstore is pointing to slot 63 (the RNAT word).  The new
  Matt> bspstore comes out pointing to slot 0 of the next group, and
  Matt> the RNAT bits never get written.

Yes, this is a problem.  Can you try the attached patch?  Rather than
storing an additional sc_bspstore member, the backing-store switching
code checks whether bspstore points to an RNaT slot and, if so, stores
the RNaT manually.  This effectively "normalizes" the backing-store
such that ar.bspstore never points to an RNaT slot.

Note that binary compatibility is the main reason for this solution.
Perhaps some day there will be an opportunity to redo the sigcontext
structure and at that point we could store the bspstore/loadrs pair
(as we do on kernel entry) instead of the bsp/loadrs pair that we
currently store in sigcontext.

	--david

=== arch/ia64/kernel/gate.S 1.17 vs edited ==--- 1.17/arch/ia64/kernel/gate.S	Tue Jun 17 23:50:16 2003
+++ edited/arch/ia64/kernel/gate.S	Fri Jun 20 22:26:34 2003
@@ -199,7 +199,7 @@
 	cmp.ne p8,p0=r15,r0		// do we need to switch the rbs?
 	mov.m r9=ar.bsp			// fetch ar.bsp
 	.spillsp.p p8, ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
-(p8)	br.cond.spnt setup_rbs		// yup -> (clobbers r14, r15, and r16)
+(p8)	br.cond.spnt setup_rbs		// yup -> (clobbers p8, r14-r16, and r18-r20)
 back_from_setup_rbs:
 	alloc r8=ar.pfs,0,0,3,0
 	ld8 out0=[base0],16		// load arg0 (signum)
@@ -268,26 +268,30 @@
 setup_rbs:
 	mov ar.rsc=0				// put RSE into enforced lazy mode
 	;;
-	.save ar.rnat, r16
-	mov r16=ar.rnat				// save RNaT before switching backing store area
+	.save ar.rnat, r19
+	mov r19=ar.rnat				// save RNaT before switching backing store area
 	adds r14=(RNAT_OFF+SIGCONTEXT_OFF),sp
 
+	mov r18=ar.bspstore
 	mov ar.bspstore=r15			// switch over to new register backing store area
 	;;
+
 	.spillsp ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
-	st8 [r14]=r16				// save sc_ar_rnat
+	st8 [r14]=r19				// save sc_ar_rnat
 	.body
-	adds r14=(LOADRS_OFF+SIGCONTEXT_OFF),sp
-
 	mov.m r16=ar.bsp			// sc_loadrs <- (new bsp - new bspstore) << 16
+	adds r14=(LOADRS_OFF+SIGCONTEXT_OFF),sp
 	;;
 	invala
 	sub r15=r16,r15
+	extr.u r20=r18,3,6
 	;;
+	mov ar.rsc=0xf				// set RSE into eager mode, pl 3
+	cmp.eq p8,p0c,r20
 	shl r15=r15,16
 	;;
 	st8 [r14]=r15				// save sc_loadrs
-	mov ar.rsc=0xf				// set RSE into eager mode, pl 3
+(p8)	st8 [r18]=r19		// if bspstore points at RNaT slot, store RNaT there now
 	.restore sp				// pop .prologue
 	br.cond.sptk back_from_setup_rbs
 

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
