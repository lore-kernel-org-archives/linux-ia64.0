From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Thu, 02 Feb 2012 19:37:47 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <20120202193747.GG2518@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb>
 <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
 <1328128874.15992.6430.camel@triegel.csb>
 <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
 <20120201224554.GK2382@linux.vnet.ibm.com>
 <CA+55aFyzYO0CMZOgdrVV0PdG2DkbwTQG7eE7N3bp=0tQmruFEQ@mail.gmail.com>
 <20120202184209.GD2518@linux.vnet.ibm.com>
 <CA+55aFyYxzED4OoYvb3nbET7_zyP5mGhEa2w_QCvQOx55bVjHg@mail.gmail.com>
In-Reply-To: <CA+55aFyYxzED4OoYvb3nbET7_zyP5mGhEa2w_QCvQOx55bVjHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Thu, Feb 02, 2012 at 11:08:25AM -0800, Linus Torvalds wrote:
> On Thu, Feb 2, 2012 at 10:42 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >>
> >> SMP-atomic or percpu atomic? Or both?
> >
> > Only SMP-atomic.
> 
> And I assume that since the compiler does them, that would now make it
> impossible for us to gather a list of all the 'lock' prefixes so that
> we can undo them if it turns out that we are running on a UP machine.
> 
> When we do SMP operations, we don't just add a "lock" prefix to it. We do this:
> 
>   #define LOCK_PREFIX_HERE \
>                 ".section .smp_locks,\"a\"\n"   \
>                 ".balign 4\n"                   \
>                 ".long 671f - .\n" /* offset */ \
>                 ".previous\n"                   \
>                 "671:"
> 
>   #define LOCK_PREFIX LOCK_PREFIX_HERE "\n\tlock; "
> 
> and I'm sure you know that, but I'm not sure the gcc people realize
> the kinds of games we play to make things work better.
> 
> Sure, "everything will be SMP" some day, but running UP kernels is
> likely still going to remain a good idea in virtualized environments,
> for example. And having to make it a compile-time option is *not* a
> good idea.
> 
> So compiler intrisics are often *worse* than doing it by hand for us
> for all these kinds of reasons. They aren't generally geared towards
> the very specialized needs that a kernel has.
> 
> Of course, maybe even user space would want some kind of way to
> automatically strip 'lock' prefixes from a binary, so maybe the
> compiler would have some kind of support like this too.
> 
> (And no, disassembling the binary in order to find lock prefixes is
> *not* the answer, at least not for the kernel)

So if the gcc guys want the Linux kernel to use their atomics, they
must give it some useful way of finding all the lock prefixes on x86.
Should be a fun conversation.  ;-)

> >> We need both variants in the kernel. If the compiler generates one of
> >> them for us, that doesn't really much help.
> >
> > I must admit that the non-x86 per-CPU atomics are, ummm, "interesting".
> 
> Most non-x86 cpu's would probably be better off treating them the same
> as smp-atomics (load-locked + store-conditional), but right now we
> have this insane generic infrastructure for having versions that are
> irq-safe by disabling interrupts etc. Ugh. Mainly because nobody
> really is willing to work on and fix up the 25 architectures that
> really don't matter.

Again, fair point!

							Thanx, Paul

