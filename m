From: Zou Nan hai <nanhai.zou@intel.com>
Date: Wed, 13 Sep 2006 04:55:25 +0000
Subject: [PATCH]Make gp value point to Region 5 in mca handler
Message-Id: <1158123325.2591.46.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

MCA dispatch code take physical address of GP passed from SAL, 
then call DATA_PA_TO_VA twice on GP before call into C code.
The first time is in ia64_set_kernel_register, the second time is in
VIRTUAL_MODE_ENTER.
The gp is changed to a virtual address in region 7 because DATA_PA_TO_VA
is implemented 
by dep instruction. 

However when notify blocks were called from MCA handler code, 
because notify blocks are supported by callback function pointers, 
gp value value was switched to region 5 again. 


The patch set gp register to kernel gp of region 5 at entry of MCA
dispatch.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup linux-2.6.18-rc6/arch/ia64/kernel/mca_asm.S linux-2.6.18-rc6-fix/arch/ia64/kernel/mca_asm.S
--- linux-2.6.18-rc6/arch/ia64/kernel/mca_asm.S	2006-09-13 10:21:06.000000000 +0800
+++ linux-2.6.18-rc6-fix/arch/ia64/kernel/mca_asm.S	2006-09-13 10:29:11.000000000 +0800
@@ -270,7 +270,7 @@ done_tlb_purge_and_reload:
 	mov r7=r2
 
         // Enter virtual mode from physical mode
-	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
+	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4, __gp)
 
 	// This code returns to SAL via SOS r2, in general SAL has no unwind
 	// data.  To get a clean termination when backtracing the C MCA/INIT
@@ -364,7 +364,7 @@ ia64_os_init_dispatch:
 	mov r7=r2
 
         // Enter virtual mode from physical mode
-	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_init_virtual_begin, r4)
+	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_init_virtual_begin, r4, __gp)
 
 	// This code returns to SAL via SOS r2, in general SAL has no unwind
 	// data.  To get a clean termination when backtracing the C MCA/INIT
@@ -1025,18 +1025,13 @@ ia64_old_stack:
 
 ia64_set_kernel_registers:
 	add temp3=MCA_SP_OFFSET, r3
-	add temp4=MCA_SOS_OFFSET+SOS(OS_GP), r3
 	mov b0=r2		// save return address
 	GET_IA64_MCA_DATA(temp1)
 	;;
-	add temp4=temp4, temp1	// &struct ia64_sal_os_state.os_gp
 	add r12=temp1, temp3	// kernel stack pointer on MCA/INIT stack
 	add r13=temp1, r3	// set current to start of MCA/INIT stack
 	add r20=temp1, r3	// physical start of MCA/INIT stack
 	;;
-	ld8 r1=[temp4]		// OS GP from SAL OS state
-	;;
-	DATA_PA_TO_VA(r1,temp1)
 	DATA_PA_TO_VA(r12,temp2)
 	DATA_PA_TO_VA(r13,temp3)
 	;;
diff -Nraup linux-2.6.18-rc6/include/asm-ia64/mca_asm.h linux-2.6.18-rc6-fix/include/asm-ia64/mca_asm.h
--- linux-2.6.18-rc6/include/asm-ia64/mca_asm.h	2006-06-18 09:49:35.000000000 +0800
+++ linux-2.6.18-rc6-fix/include/asm-ia64/mca_asm.h	2006-09-13 10:34:11.000000000 +0800
@@ -156,7 +156,7 @@
  *	7.	Do an rfi to move ipsr to psr and iip to ip.
  */
 
-#define VIRTUAL_MODE_ENTER(temp1, temp2, start_addr, old_psr)	\
+#define VIRTUAL_MODE_ENTER(temp1, temp2, start_addr, old_psr, gp_addr)	\
 	mov	temp2 = psr;					\
 	;;							\
 	mov	old_psr = temp2;				\
@@ -197,9 +197,9 @@
 	movl	temp2 = start_addr;				\
 	;;							\
 	mov	cr.iip = temp2;					\
+	movl	gp = gp_addr					\
 	;;							\
 	DATA_PA_TO_VA(sp, temp1);				\
-	DATA_PA_TO_VA(gp, temp2);				\
 	srlz.i;							\
 	;;							\
 	nop	1;						\


