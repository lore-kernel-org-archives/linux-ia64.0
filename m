From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Wed, 27 Sep 2000 18:25:42 +0000
Subject: RE: [Linux-ia64] setjmp/longjmp : flushing register stack
Message-Id: <marc-linux-ia64-105590678205520@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205495@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205495@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I would like to again put in a plea to not use setjmp/longjmp for context
switches if it can be avoided, for several reasons:

1) You end up with several incompatible thread systems on the same platform.
If a general purpose (native) library wants to fork a thread because it can
take advantage of a multiprocessor, how does it do it?  This assumes that
there is some generic way to handle mutual exclusion, which there generally
isn't.  In my experience, the result is a mess, with intermittent failures
in large systems.  Linuxthreads is the standard thread library on
Linux/IA64.  I haven't yet seen a convincing argument that it's inadequate.
(Gcj seems to do OK with it.  Kernel scheduling is more expensive, but
that's in large part because it tries to consider processor affinity, etc.
You get what you pay for.)  If linuxthreads does turn out to be inadequate,
let's fix it.

2) It's hard to take advantage of multiprocessors with setjmp/longjmp.

3) The "solutions" often end up not preempting threads or time-slicing
correctly.  Although such thread implementations may have their place in
real-time applications, I find them painful to use in a general-purpose
context.  At a minimum you end up sprinkling yield calls through
compute-intensive code, something that's often impossible for third-party
libraries.  At worst you end up with code that breaks if you insert a
debugging printf when that happens to block, and the caller was expecting
you to not allow another thread to run.

4) Good thread implementations take a long time to debug and stabilize.
Once is enough.

5) Setjmp/longjmp is not intended for context switches, and not guaranteed
to work.

Hans

> -----Original Message-----
> From: Steve Tynor [mailto:tynor@atlanta.twr.com]
> Sent: Wednesday, September 27, 2000 9:07 AM
> To: schan@uk.ibm.com; linux-ia64@linuxia64.org
> Subject: re: [Linux-ia64] setjmp/longjmp : flushing register stack
> 
> 
> A while back, Sunny Chan wrote: 
> 
> | We are developing the Linux/IA64 Java VM and we need 
> sigsetjmp/setjmp
> | flushing the register stack properly - however currently it 
> only flush on
> | the call of longjmp - is there any chance of adding flushrs into
> | setjmp/sigsetjmp? We could do it in our code but there will 
> be rather
> | inconvenient...
> 
> Have you found a workaround?  I presume you are trying to use
> setjmp/longjmp to do user-mode thread context switches?  I have a
> similar need.  I've tried adding an inline asm("flushrs") before the
> setjmp, but the local frame pointer (which seems to vary from function
> to function (gcc seems to use one of the general registers in the
> r33...r38 range -- and setjmp does not preserve those) is still not
> preserved after the longjmp (and local variables accessed in the new
> context are accessed off the old context's value of the frame
> register.).
> 
> E.g.:
> 
>              alloc r38=ar.pfs,12,7,0
>       ...
>              mov.i ar.pfs=r38
> 
> I'm essentially trying to do something like:
> 
>     asm("flushrs");
>     /* save our context */
>     if (setjmp(this_thread) = 0) {
>         /* switch to other thread */
>         longjmp(other_thread, 1);
>     }
>     /* continue in this thread */
> 
> The stack pointer (sp/r12) is being preserved across the longjmp, but
> the general register used to pop the frame (in the "mov.i ar.pfs=r38"
> instruction) is not.  The address of local variables in the 
> new context
> shows up as addresses on the old context's stack despite the fact that
> sp is correctly restored to the new stack bounds.
> 
> I've tried forcing a "loadrs" at the "continue in this 
> thread" point, to
> know avail.  However, I'm not confident I've set the various RSE mode,
> etc. properly.
> 
> I must admit that I'm not an IA64 asm guru, so I might be missing
> something obvious. Can anyone help?  Can I in fact do something like
> what I'm trying to do with the IA64 setjmp? (i.e. add some additional
> code before or after the setjmp to force a complete register spill and
> load).  Or do I need to write my own setjmp variant? If so, can anyone
> suggest what I need to do above and beyond what setjmp is 
> already doing?
> 
> Thanks!
> 
> Steve
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

