From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 28 May 2008 08:34:43 +0000
Subject: Re: [PATCH 00/17] ia64/pv_ops take 6
Message-Id: <20080528083443.GE29174%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12112028241775-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12112028241775-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 27, 2008 at 04:26:45PM -0700, Luck, Tony wrote:

> I had to spend time on a bugfix.  The bugfix is posted
> in my 'release' branch. The pv_ops series (including the
> documentation) is now in the 'test' branch.  Take a close
> look at arch/is64/kernel/minstate.h as I had to re-merge
> your changes because of collisions with the bugfix.

Thank you for commiting them.
I checked the RSE work around patch of
4dcc29e1574d88f4465ba865ed82800032f76418.
It bloated SAVE_MIN_WITH_COVER and SAVE_MIN_WITH_COVER_R19
so that on paravirtualized case not only dispatch_illegal_op_fault
but also other functions which those macros need to be moved.
Since the effort to reduce code size had already been made, so 
it is difficult to go further. By moving all of them, it would
be consistent and we don't have to worry about code size anymore.

From 8a280936ca40bf824250f22c77228412b17ef74a Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 28 May 2008 16:28:41 +0900
Subject: ia64/pv_ops: preparation: move some functions in ivt.S to avoid lack of space.

move interrupt, page_fault, non_syscall, dispatch_unaligned_handler and
dispatch_to_fault_handler to avoid lack of instructin space.
The change set 4dcc29e1574d88f4465ba865ed82800032f76418 bloated
SAVE_MIN_WITH_COVER, SAVE_MIN_WITH_COVER_R19 so that it bloated the
functions which uses those macros.
In the native case, only dispatch_illegal_op_fault had to be moved.
When paravirtualized case the all functions which use the macros need
to be moved to avoid the lack of space.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/ivt.S |  261 ++++++++++++++++++++++++-----------------------
 1 files changed, 133 insertions(+), 128 deletions(-)

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 23749ed..c39627d 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -515,27 +515,6 @@ ENTRY(ikey_miss)
 	FAULT(6)
 END(ikey_miss)
 
-	//-----------------------------------------------------------------------------------
-	// call do_page_fault (predicates are in r31, psr.dt may be off, r16 is faulting address)
-ENTRY(page_fault)
-	SSM_PSR_DT_AND_SRLZ_I
-	;;
-	SAVE_MIN_WITH_COVER
-	alloc r15=ar.pfs,0,0,3,0
-	MOV_FROM_IFA(out0)
-	MOV_FROM_ISR(out1)
-	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r14, r3)
-	adds r3=8,r2				// set up second base pointer
-	SSM_PSR_I(p15, p15, r14)		// restore psr.i
-	movl r14=ia64_leave_kernel
-	;;
-	SAVE_REST
-	mov rp=r14
-	;;
-	adds out2,r12			// out2 = pointer to pt_regs
-	br.call.sptk.many b6=ia64_do_page_fault	// ignore return address
-END(page_fault)
-
 	.org ia64_ivt+0x1c00
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
@@ -896,26 +875,8 @@ END(break_fault)
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
 ENTRY(interrupt)
-	DBG_FAULT(12)
-	mov r31=pr		// prepare to save predicates
-	;;
-	SAVE_MIN_WITH_COVER	// uses r31; defines r2 and r3
-	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r14)
-				// ensure everybody knows psr.ic is back on
-	adds r3=8,r2		// set up second base pointer for SAVE_REST
-	;;
-	SAVE_REST
-	;;
-	MCA_RECOVER_RANGE(interrupt)
-	alloc r14=ar.pfs,0,0,2,0 // must be first in an insn group
-	MOV_FROM_IVR(out0, r8)	// pass cr.ivr as first arg
-	add out1,sp		// pass pointer to pt_regs as second arg
-	;;
-	srlz.d			// make sure we see the effect of cr.ivr
-	movl r14=ia64_leave_kernel
-	;;
-	mov rp=r14
-	br.call.sptk.many b6=ia64_handle_irq
+	/* interrupt handler has become too big to fit this area. */
+	br.sptk.many __interrupt
 END(interrupt)
 
 	.org ia64_ivt+0x3400
@@ -1125,105 +1086,18 @@ END(account_sys_enter)
 	DBG_FAULT(17)
 	FAULT(17)
 
-ENTRY(non_syscall)
-	mov ar.rsc=r27			// restore ar.rsc before SAVE_MIN_WITH_COVER
-	;;
-	SAVE_MIN_WITH_COVER
-
-	// There is no particular reason for this code to be here, other than that
-	// there happens to be space here that would go unused otherwise.  If this
-	// fault ever gets "unreserved", simply moved the following code to a more
-	// suitable spot...
-
-	alloc r14=ar.pfs,0,0,2,0
-	MOV_FROM_IIM(out0)
-	add out1,sp
-	adds r3=8,r2			// set up second base pointer for SAVE_REST
-
-	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r15, r24)
-					// guarantee that interruption collection is on
-	SSM_PSR_I(p15, p15, r15)	// restore psr.i
-	movl r15=ia64_leave_kernel
-	;;
-	SAVE_REST
-	mov rp=r15
-	;;
-	br.call.sptk.many b6=ia64_bad_break	// avoid WAW on CFM and ignore return addr
-END(non_syscall)
-
 	.org ia64_ivt+0x4800
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x4800 Entry 18 (size 64 bundles) Reserved
 	DBG_FAULT(18)
 	FAULT(18)
 
-	/*
-	 * There is no particular reason for this code to be here, other than that
-	 * there happens to be space here that would go unused otherwise.  If this
-	 * fault ever gets "unreserved", simply moved the following code to a more
-	 * suitable spot...
-	 */
-
-ENTRY(dispatch_unaligned_handler)
-	SAVE_MIN_WITH_COVER
-	;;
-	alloc r14=ar.pfs,0,0,2,0		// now it's safe (must be first in insn group!)
-	MOV_FROM_IFA(out0)
-	adds out1,sp
-
-	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r24)
-						// guarantee that interruption collection is on
-	SSM_PSR_I(p15, p15, r3)			// restore psr.i
-	adds r3=8,r2				// set up second base pointer
-	;;
-	SAVE_REST
-	movl r14=ia64_leave_kernel
-	;;
-	mov rp=r14
-	br.sptk.many ia64_prepare_handle_unaligned
-END(dispatch_unaligned_handler)
-
 	.org ia64_ivt+0x4c00
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x4c00 Entry 19 (size 64 bundles) Reserved
 	DBG_FAULT(19)
 	FAULT(19)
 
-	/*
-	 * There is no particular reason for this code to be here, other than that
-	 * there happens to be space here that would go unused otherwise.  If this
-	 * fault ever gets "unreserved", simply moved the following code to a more
-	 * suitable spot...
-	 */
-
-ENTRY(dispatch_to_fault_handler)
-	/*
-	 * Input:
-	 *	psr.ic:	off
-	 *	r19:	fault vector number (e.g., 24 for General Exception)
-	 *	r31:	contains saved predicates (pr)
-	 */
-	SAVE_MIN_WITH_COVER_R19
-	alloc r14=ar.pfs,0,0,5,0
-	MOV_FROM_ISR(out1)
-	MOV_FROM_IFA(out2)
-	MOV_FROM_IIM(out3)
-	MOV_FROM_ITIR(out4)
-	;;
-	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, out0)
-						// guarantee that interruption collection is on
-	mov out0=r15
-	;;
-	SSM_PSR_I(p15, p15, r3)			// restore psr.i
-	adds r3=8,r2				// set up second base pointer for SAVE_REST
-	;;
-	SAVE_REST
-	movl r14=ia64_leave_kernel
-	;;
-	mov rp=r14
-	br.call.sptk.many b6=ia64_fault
-END(dispatch_to_fault_handler)
-
 //
 // --- End of long entries, Beginning of short entries
 //
@@ -1670,6 +1544,137 @@ END(ia32_interrupt)
 	DBG_FAULT(67)
 	FAULT(67)
 
+	//-----------------------------------------------------------------------------------
+	// call do_page_fault (predicates are in r31, psr.dt may be off, r16 is faulting address)
+ENTRY(page_fault)
+	SSM_PSR_DT_AND_SRLZ_I
+	;;
+	SAVE_MIN_WITH_COVER
+	alloc r15=ar.pfs,0,0,3,0
+	MOV_FROM_IFA(out0)
+	MOV_FROM_ISR(out1)
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r14, r3)
+	adds r3=8,r2				// set up second base pointer
+	SSM_PSR_I(p15, p15, r14)		// restore psr.i
+	movl r14=ia64_leave_kernel
+	;;
+	SAVE_REST
+	mov rp=r14
+	;;
+	adds out2,r12			// out2 = pointer to pt_regs
+	br.call.sptk.many b6=ia64_do_page_fault	// ignore return address
+END(page_fault)
+
+ENTRY(non_syscall)
+	mov ar.rsc=r27			// restore ar.rsc before SAVE_MIN_WITH_COVER
+	;;
+	SAVE_MIN_WITH_COVER
+
+	// There is no particular reason for this code to be here, other than that
+	// there happens to be space here that would go unused otherwise.  If this
+	// fault ever gets "unreserved", simply moved the following code to a more
+	// suitable spot...
+
+	alloc r14=ar.pfs,0,0,2,0
+	MOV_FROM_IIM(out0)
+	add out1,sp
+	adds r3=8,r2			// set up second base pointer for SAVE_REST
+
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r15, r24)
+					// guarantee that interruption collection is on
+	SSM_PSR_I(p15, p15, r15)	// restore psr.i
+	movl r15=ia64_leave_kernel
+	;;
+	SAVE_REST
+	mov rp=r15
+	;;
+	br.call.sptk.many b6=ia64_bad_break	// avoid WAW on CFM and ignore return addr
+END(non_syscall)
+
+ENTRY(__interrupt)
+	DBG_FAULT(12)
+	mov r31=pr		// prepare to save predicates
+	;;
+	SAVE_MIN_WITH_COVER	// uses r31; defines r2 and r3
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r14)
+				// ensure everybody knows psr.ic is back on
+	adds r3=8,r2		// set up second base pointer for SAVE_REST
+	;;
+	SAVE_REST
+	;;
+	MCA_RECOVER_RANGE(interrupt)
+	alloc r14=ar.pfs,0,0,2,0 // must be first in an insn group
+	MOV_FROM_IVR(out0, r8)	// pass cr.ivr as first arg
+	add out1,sp		// pass pointer to pt_regs as second arg
+	;;
+	srlz.d			// make sure we see the effect of cr.ivr
+	movl r14=ia64_leave_kernel
+	;;
+	mov rp=r14
+	br.call.sptk.many b6=ia64_handle_irq
+END(__interrupt)
+
+	/*
+	 * There is no particular reason for this code to be here, other than that
+	 * there happens to be space here that would go unused otherwise.  If this
+	 * fault ever gets "unreserved", simply moved the following code to a more
+	 * suitable spot...
+	 */
+
+ENTRY(dispatch_unaligned_handler)
+	SAVE_MIN_WITH_COVER
+	;;
+	alloc r14=ar.pfs,0,0,2,0		// now it's safe (must be first in insn group!)
+	MOV_FROM_IFA(out0)
+	adds out1,sp
+
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r24)
+						// guarantee that interruption collection is on
+	SSM_PSR_I(p15, p15, r3)			// restore psr.i
+	adds r3=8,r2				// set up second base pointer
+	;;
+	SAVE_REST
+	movl r14=ia64_leave_kernel
+	;;
+	mov rp=r14
+	br.sptk.many ia64_prepare_handle_unaligned
+END(dispatch_unaligned_handler)
+
+	/*
+	 * There is no particular reason for this code to be here, other than that
+	 * there happens to be space here that would go unused otherwise.  If this
+	 * fault ever gets "unreserved", simply moved the following code to a more
+	 * suitable spot...
+	 */
+
+ENTRY(dispatch_to_fault_handler)
+	/*
+	 * Input:
+	 *	psr.ic:	off
+	 *	r19:	fault vector number (e.g., 24 for General Exception)
+	 *	r31:	contains saved predicates (pr)
+	 */
+	SAVE_MIN_WITH_COVER_R19
+	alloc r14=ar.pfs,0,0,5,0
+	MOV_FROM_ISR(out1)
+	MOV_FROM_IFA(out2)
+	MOV_FROM_IIM(out3)
+	MOV_FROM_ITIR(out4)
+	;;
+	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, out0)
+						// guarantee that interruption collection is on
+	mov out0=r15
+	;;
+	SSM_PSR_I(p15, p15, r3)			// restore psr.i
+	adds r3=8,r2				// set up second base pointer for SAVE_REST
+	;;
+	SAVE_REST
+	movl r14=ia64_leave_kernel
+	;;
+	mov rp=r14
+	br.call.sptk.many b6=ia64_fault
+END(dispatch_to_fault_handler)
+
 	/*
 	 * Squatting in this space ...
 	 *
-- 
1.5.3


-- 
yamahata
