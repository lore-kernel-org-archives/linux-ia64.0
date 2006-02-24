From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 24 Feb 2006 23:40:08 +0000
Subject: stop bit on every instruction on IPF?
Message-Id: <B05667366EE6204181EABE9C1B1C0EB509C83B53@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Who wrote this code? Stop bit on every instruction??
Thought it is so funny ....

I know people is going to say: who cares, it's MCA.  Oh well ...


GLOBAL_ENTRY(mca_handler_bhhook)
        invala                          // clear RSE ?
        ;;
        cover
        ;;
        clrrrb
        ;;
        alloc   r16=ar.pfs,0,2,1,0      // make a new frame
        ;;
        mov     ar.rsc=0
        ;;
        mov     r13=IA64_KR(CURRENT)    // current task pointer
        ;;
        mov     r2=r13
        ;;
        addl    r22=IA64_RBS_OFFSET,r2
        ;;
        mov     ar.bspstore=r22
        ;;
        addl    sp=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2
        ;;
        adds    r2=IA64_TASK_THREAD_ON_USTACK_OFFSET,r13
        ;;
