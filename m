From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 21 Dec 2000 03:42:45 +0000
Subject: [Linux-ia64] Incorrect unwind data in entry.S
Message-Id: <marc-linux-ia64-105590678205870@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Either I have completely misunderstood the IA64 unwind data (quite
likely) or this code is wrong.

GLOBAL_ENTRY(ia64_prepare_handle_unaligned)
        //
        // r16 = fake ar.pfs, we simply need to make sure
        // privilege is still 0
        //
        PT_REGS_UNWIND_INFO(0)
        mov r16=r0
        UNW(.prologue)
        DO_SAVE_SWITCH_STACK
        br.call.sptk.few rp=ia64_handle_unaligned // stack frame setup in ivt
.ret21: .body
        DO_LOAD_SWITCH_STACK(PT_REGS_UNWIND_INFO(0))
        br.cond.sptk.many rp                      // goes to ia64_leave_kernel
END(ia64_prepare_handle_unaligned)

That preprocesses into

.global ia64_prepare_handle_unaligned; .align 32; .proc ia64_prepare_handle_unaligned; ia64_prepare_handle_unaligned:
        .prologue;			// prologue 1
        .unwabi @svr4, 'i';
        .fframe 400+16+(0);
        // assorted .spillsp directives
        .body
        mov r16=r0
        .prologue			// prologue 2
        movl r28;
        ;;
        .fframe 576;
        adds sp=-576,sp;
        mov b7=r28;
        // assorted .savesp and .spillsp directives
        br.cond.sptk.many save_switch_stack;
        1:
        br.call.sptk.few rp=ia64_handle_unaligned
.ret21: .body
        movl r28;
        ;;
        mov b7=r28;
        br.cond.sptk.many load_switch_stack;
        1: .restore sp;			// pop prologue 2
        .prologue;			// prologue 3
        .unwabi @svr4, 'i';
        .fframe 400+16+(0);
        .spillsp rp, (8 + 16)+(0);
        .spillsp ar.pfs, (16 + 16)+(0);
        .spillsp ar.unat, (24 + 16)+(0);
        .spillsp ar.fpsr, (312 + 16)+(0);
        .spillsp pr, (64 + 16)+(0);;
        .body;
        adds spW6,sp
        br.cond.sptk.many rp
.endp ia64_prepare_handle_unaligned

The prologue after .ret21 makes no sense.  Unwind claims that we are
increasing the stack by 416 and spilling registers to stack but we are
really removing the struct switch_stack.

The mismatch between unwind and the code does not cause any problems
because we hit .endp almost immediately.  I just want to get
confirmation that this really is an error.  AFAICT, prologue 3 should
be an epilog.


