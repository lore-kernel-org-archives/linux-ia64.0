From: Keith Owens <kaos@sgi.com>
Date: Wed, 21 Sep 2005 01:12:07 +0000
Subject: MCA/INIT: need to wire CURRENT_STACK?
Message-Id: <16451.1127265127@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I put this comment in arch/ia64/kernel/mca_asm.S, where we switch to
the MCA/INIT stack.  The code runs fine without wiring
IA64_KR_CURRENT_STACK and IA64_TR_CURRENT_STACK.  Is that coincidence
or do the extra registers really need to be updated?  The MCA/INIT
stacks are initialized early in boot, they are in region 7.

Remember that the MCA/INIT handlers run with interrupts disabled.

ia64_set_kernel_registers:
        add temp3=MCA_SP_OFFSET, r3
        add temp4=MCA_SOS_OFFSET+IA64_SAL_OS_STATE_OS_GP_OFFSET, r3
        mov b0=r2               // save return address
        GET_IA64_MCA_DATA(temp1)
        ;;
        add temp4=temp4, temp1  // &struct ia64_sal_os_state.os_gp
        add r12=temp1, temp3    // kernel stack pointer on MCA/INIT stack
        add r13=temp1, r3       // set current to start of MCA/INIT stack
        ;;
        ld8 r1=[temp4]          // OS GP from SAL OS state
        ;;
        DATA_PA_TO_VA(r1,temp1)
        DATA_PA_TO_VA(r12,temp2)
        DATA_PA_TO_VA(r13,temp3)
        ;;
        mov IA64_KR(CURRENT)=r13

        // FIXME: do I need to wire IA64_KR_CURRENT_STACK and IA64_TR_CURRENT_STACK?

        br.sptk b0


