From: "Luck, Tony" <tony.luck@intel.com>
Date: Sun, 27 Sep 2009 04:54:35 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E2DD4A5B@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hmm. There's a fetchadd4, but it has horrible semantics (very limited 
> constants).

Yes.  The lack of a fetchadd2 and the limited set of constants for
fetchadd4 is what drove me to this 8-byte implementation. More on this
below ...

> BTW, I also think that the memory ordering is not sufficient in the 
> current ia64 ticket locks. It does just a simple
>
>        do {
>                cpu_relax();
>        } while (ACCESS_ONCE(*p) != turn);
>
> to wait to get the spinlock, and even if the 'fetchadd' it did earlier was 
> done with 'acq', the reads in ACCESS_ONCE() are just normal reads, so the 
> code that is protected by that spinlock could easily have other reads or 
> writes that escape to _before_ the ACCESS_ONCE().

Actually the ACCESS_ONCE() macro does end up with a "ld4.acq" here (because
it defined with "volatile" in there, and the people that wrote the Itanium
ABI said that compilers must generate .acq, .rel for volatile access.

However, when I ran the generated code with the .acq in here past one
of the Itanium h/w architects, he said that it actually wasn't needed
because the cmp/branch would also prevent accesses from inside the
protected region from leaking out.  But keeping the .acq seems the safer
course in case gcc gets smarter and uses more predicates instead of the
cmp/branch AND also in case we go back to inlining the spin_lock() path.

>   This allows 32768 different CPU's.

And 640K of memory should be enough for anyone :-)  SGI booted with 4096
over a year ago ... so I'm not sure that 32768 cpus are really out of the
question.


> - spinunlock
>
>	/*
>	 * High bits of the lock - we don't care about atomicity
>	 * here, the 'fetchadd4' can't change the bits we care
>	 * about.
>	 */
>	unsigned short *mem = 1+(unsigned short)lock;

Doh!  Yes, of course!  I got tied up thinking that I needed to be able
to release the lock with an atomic fetchadd ... and couldn't work out
how to do that since fetchadd4 wouldn't take a large enough argument.
But you are right that we can do a non-atomic op.

>	unsigned short value = (*mem + 2) & ~1;
>
>	st2.rel.nta value,[mem]

This does suffer from the problem that you complained about for my
spin_lock() function ... we will first get the cache line in shared
mode and then have to upgrade to exclusive when we do the store ...
so the line may get stolen away from us by someone pulling a new ticket.
We could perhaps make it less of an issue by using "ld.bias" to get
the line exclusive to begin with.

-Tony
