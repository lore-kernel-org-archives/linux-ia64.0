From: Steve Tynor <tynor@atlanta.twr.com>
Date: Wed, 27 Sep 2000 16:07:24 +0000
Subject: re: [Linux-ia64] setjmp/longjmp : flushing register stack
Message-Id: <marc-linux-ia64-105590678205518@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205495@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205495@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A while back, Sunny Chan wrote: 

| We are developing the Linux/IA64 Java VM and we need sigsetjmp/setjmp
| flushing the register stack properly - however currently it only flush on
| the call of longjmp - is there any chance of adding flushrs into
| setjmp/sigsetjmp? We could do it in our code but there will be rather
| inconvenient...

Have you found a workaround?  I presume you are trying to use
setjmp/longjmp to do user-mode thread context switches?  I have a
similar need.  I've tried adding an inline asm("flushrs") before the
setjmp, but the local frame pointer (which seems to vary from function
to function (gcc seems to use one of the general registers in the
r33...r38 range -- and setjmp does not preserve those) is still not
preserved after the longjmp (and local variables accessed in the new
context are accessed off the old context's value of the frame
register.).

E.g.:

             alloc r38=ar.pfs,12,7,0
      ...
             mov.i ar.pfs=r38

I'm essentially trying to do something like:

    asm("flushrs");
    /* save our context */
    if (setjmp(this_thread) = 0) {
        /* switch to other thread */
        longjmp(other_thread, 1);
    }
    /* continue in this thread */

The stack pointer (sp/r12) is being preserved across the longjmp, but
the general register used to pop the frame (in the "mov.i ar.pfs=r38"
instruction) is not.  The address of local variables in the new context
shows up as addresses on the old context's stack despite the fact that
sp is correctly restored to the new stack bounds.

I've tried forcing a "loadrs" at the "continue in this thread" point, to
know avail.  However, I'm not confident I've set the various RSE mode,
etc. properly.

I must admit that I'm not an IA64 asm guru, so I might be missing
something obvious. Can anyone help?  Can I in fact do something like
what I'm trying to do with the IA64 setjmp? (i.e. add some additional
code before or after the setjmp to force a complete register spill and
load).  Or do I need to write my own setjmp variant? If so, can anyone
suggest what I need to do above and beyond what setjmp is already doing?

Thanks!

Steve


