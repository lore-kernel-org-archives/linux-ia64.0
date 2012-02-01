From: Torvald Riegel <triegel@redhat.com>
Date: Wed, 01 Feb 2012 17:42:54 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <1328118174.15992.6206.camel@triegel.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
	 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
In-Reply-To: <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, 2012-02-01 at 08:41 -0800, Linus Torvalds wrote:
> If the gcc people aren't willing to agree that this is actually a flaw
> in the standard (one that is being addressed, no less)

It has been addressed in the standards.

> and try to fix
> it,

Again, this is being worked on, see http://gcc.gnu.org/wiki/Atomic/GCCMM

> we just have to extend our assumptions to something like "a
> compiler would be stupid to ever access anything bigger than the
> aligned register-size area". It's still just an assumption, and
> compiler people could be crazy, but we could just extend the current
> alpha rules to cover not just "int", but "long" too.

So, let's ignore everyone's craziness (the kernel is not the only GCC
client...) and think about how we can improve the situation.

We need a proper memory model.  No vague assumptions with lots of
hand-waving.  If you think that this is simple stuff and can
sufficiently described by "don't do anything stupid", then please have a
look at the issues that the Java memory model faced, and all the
iterations of the C++11/C11 model and discussions about it.

The only candidate that I see is the C++11/C11 model.  Any other
suggestions?

Now, if we assume this model, what does the kernel community think about
it?  It might be good to split this discussion into the following two
points, to avoid syntax flame wars:
1) The model itself (ie, the memory orders, ordering guarantees, (lack
of) progress guarantees, etc.).
2) The syntax/APIs to specify atomics.

If something else or more is needed, the compiler needs to have a formal
specification for that.  This will help users too, because it avoids all
the ambiguities.

> Sure, the compiler people could use "load/store multiple" or something
> like that, but it would be obviously crazy code, so if it happens past
> a register size, at least you could argue that it's a performance
> issue and maybe the gcc people would care.
> 
> HOWEVER. The problem with the alpha rules (which, btw, were huge, and
> led to the CPU designers literally changing the CPU instruction set
> because they admitted they made a huge mistake) was never so much the
> occasional memory corruption, as the fact that the places where it
> could happen were basically almost impossible to find.
> 
> So we probably have tons of random places in the kernel that violate
> even the alpha rules - because the corruption is so rare, and the
> architecture was so rare as to making the corruption even harder to
> find.

I assume you still would want a weak memory model, or not?  (That is,
rely on data-race-freedom, only atomics do not contribute to data races,
and you need to mark data used for synchronization (or which is just
accessed concurrently) as atomics).

If so, you need to tell the compiler which variables etc. are atomics.

> I assume this code generation idiocy only happens with bitfields? The
> problem is, we really don't want to make all bitfields take up 64 bits
> just because we might have a lock or something else next to them. But
> we could probably re-order things (and then *occasionally* wasting
> memory) if we could just find the ones that are problematic.

If the compiler is aware what is a lock (or atomics, or similar), then a
correct implementation should leave the lock alone.  But in a weak
memory model, it needs to know what is a lock.
(Same goes for volatile obviously, like in the other example posted in
the thread where the bitfields interfered with the volatile.)

> 
> It's finding the problematic ones that is the issue. Which is why the
> compiler should just generate code that matches what we told it to do,

So, would it be okay to tell the compiler which part of the state is
accessed concurrently (ie, locks, atomics, ...)?


Torvald

