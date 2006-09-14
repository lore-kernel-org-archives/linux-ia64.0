From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 14 Sep 2006 00:25:15 +0000
Subject: Re: [PATCH]Make gp value point to Region 5 in mca handler
Message-Id: <1158193514.2591.90.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1158123325.2591.46.camel@linux-znh>
In-Reply-To: <1158123325.2591.46.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-09-13 at 17:54, Keith Owens wrote:
> Zou Nan hai (on 13 Sep 2006 12:55:25 +0800) wrote:
> >MCA dispatch code take physical address of GP passed from SAL, 
> >then call DATA_PA_TO_VA twice on GP before call into C code.
> >The first time is in ia64_set_kernel_register, the second time is in
> >VIRTUAL_MODE_ENTER.
> >The gp is changed to a virtual address in region 7 because DATA_PA_TO_VA
> >is implemented 
> >by dep instruction. 
> >
> >However when notify blocks were called from MCA handler code, 
> >because notify blocks are supported by callback function pointers, 
> >gp value value was switched to region 5 again. 
> >
> >
> >The patch set gp register to kernel gp of region 5 at entry of MCA
> >dispatch.
> >
> >Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> 
> The idea is right, but there is no need to pass __gp to
> VIRTUAL_MODE_ENTER.  There will never be a case of VIRTUAL_MODE_ENTER
> followed by entry to a module, so just hard code 'movl r1 = __gp' into
> VIRTUAL_MODE_ENTER and drop it from the parameter list.

 OK, I felt a little weird to put hard code in a macro.., but I think it
does not matter much since the macro is only used 2 times.

 the updated patch 

 Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

 diff -Nraup linux-2.6.18-rc6/arch/ia64/kernel/mca_asm.S linux-2.6.18-rc6-fix/arch/ia64/kernel/mca_asm.S
--- linux-2.6.18-rc6/arch/ia64/kernel/mca_asm.S	2006-09-14 10:33:08.000000000 +0800
+++ linux-2.6.18-rc6-fix/arch/ia64/kernel/mca_asm.S	2006-09-14 10:35:49.000000000 +0800
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
+++ linux-2.6.18-rc6-fix/include/asm-ia64/mca_asm.h	2006-09-14 10:36:33.000000000 +0800
@@ -197,9 +197,9 @@
 	movl	temp2 = start_addr;				\
 	;;							\
 	mov	cr.iip = temp2;					\
+	movl	gp = __gp					\
 	;;							\
 	DATA_PA_TO_VA(sp, temp1);				\
-	DATA_PA_TO_VA(gp, temp2);				\
 	srlz.i;							\
 	;;							\
 	nop	1;						\




