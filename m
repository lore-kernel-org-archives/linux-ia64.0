From: Cary Coutant <cary@cup.hp.com>
Date: Wed, 17 Jan 2001 18:54:26 +0000
Subject: Re: [Linux-ia64] Incorrect unwind data in entry.S
Message-Id: <marc-linux-ia64-105590693005063@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>There is, it just has a strange name: ".restore sp" actually generates
>an epilogue directive and the (optional) second argument specifies the
>epilogue count.

Yes, it looks like Intel added it to their assembler, and I was unaware 
of it until now.

>The kernel unwinder does _not_ assume that the stack size is fixed
>throughout the entire procedure.  I didn't think the unwind specs
>forces that either, but if I'm missing something please let me know.

On reflection, I agree. I didn't anticipate nested prologues modifying a 
fixed frame size, but I did not rule that out in the specs.

There still seems to be a problem with the unwind data not matching the 
actual frame state:

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

Perhaps there's something in the first set of "assorted .spillsp 
directives," but I don't see where the outer 416-byte stack frame is 
being allocated or deallocated. The code then allocates an additional 576 
bytes, but prologue 2 describes the *total* frame size as 576. It then 
pops prologue 2, but doesn't deallocate the 576 bytes until the beginning 
of body region 3, leaving a narrow window where the unwinder will think 
the frame size is 416 bytes.

There must be something I'm missing here.

-cary

