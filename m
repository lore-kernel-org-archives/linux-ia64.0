From: Cary Coutant <cary@cup.hp.com>
Date: Tue, 16 Jan 2001 23:41:25 +0000
Subject: Re: [Linux-ia64] Incorrect unwind data in entry.S
Message-Id: <marc-linux-ia64-105590693005057@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I apologize for taking so long to respond to this, but I've been trying 
to convince myself that there is a defect in the assembly language 
specification. Specifically, there seems to be no directive to specify 
that a body region has any epilogue code, or what the epilogue count 
should be.

In the example code quoted below, it's clear to me that the first body 
region (following prologue 1) should have no epilogue descriptor, but 
that the second body region (following prologue 2, at label .ret21) 
should. It's not, however, clear, whether the epilogue count should be 0 
(meaning that the epilogue balances only prologue 2) or 1 (meaning that 
it balances both prologues). The intent of this code seems to be that the 
epilogue count should be 0, since the comment says "pop prologue 2", and 
execution continues with a body region that logically matches the state 
of the first body region.

There are a couple of problems here, though.

First, assuming that the epilogue count for body region 2 is 0, as 
intended, the empty prologue 3 region shouldn't be at all necessary, 
since its only purpose is to reconstruct the unwind state that existed 
prior to prologue 2. With the proper epilogue count in body region 2, the 
unwind state for body region 3 should follow naturally.

Second, nested prologues weren't designed to handle a variable frame 
size. The unwinder assumes that a fixed stack frame size applies 
throughout the procedure. If you're going to change the size of your 
frame, you should copy the previous stack pointer (psp) into a local 
register, and declare a variable-size frame with the .vframe directive. 
You can then change the value of sp whenever you like, and the unwinder 
will always know to look in that local register for the value of psp.

If you use .vframe and save psp in a local register, you won't have any 
need for nested prologue regions here.

Nevertheless, I think we need to add a .epilog directive to the assembler 
before someone really needs it.

-cary


>        .prologue;			// prologue 1
>        .unwabi @svr4, 'i';
>        .fframe 400+16+(0);
>        // assorted .spillsp directives
>        .body
>        mov r16=r0
>        .prologue			// prologue 2
>        movl r28;
>        ;;
>        .fframe 576;
>        adds sp=-576,sp;
>        mov b7=r28;
>        // assorted .savesp and .spillsp directives
>        br.cond.sptk.many save_switch_stack;
>        1:
>        br.call.sptk.few rp=ia64_handle_unaligned
>.ret21: .body
>        movl r28;
>        ;;
>        mov b7=r28;
>        br.cond.sptk.many load_switch_stack;
>        1: .restore sp;			// pop prologue 2
>        .prologue;			// prologue 3
>        .unwabi @svr4, 'i';
>        .fframe 400+16+(0);
>        .spillsp rp, (8 + 16)+(0);
>        .spillsp ar.pfs, (16 + 16)+(0);
>        .spillsp ar.unat, (24 + 16)+(0);
>        .spillsp ar.fpsr, (312 + 16)+(0);
>        .spillsp pr, (64 + 16)+(0);;
>        .body;
>        adds spW6,sp
>        br.cond.sptk.many rp
>.endp ia64_prepare_handle_unaligned
>
>The prologue after .ret21 makes no sense.  Unwind claims that we are
>increasing the stack by 416 and spilling registers to stack but we are
>really removing the struct switch_stack.
>
>The mismatch between unwind and the code does not cause any problems
>because we hit .endp almost immediately.  I just want to get
>confirmation that this really is an error.  AFAICT, prologue 3 should
>be an epilog.

