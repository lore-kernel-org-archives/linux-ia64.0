From: Torvald Riegel <triegel@redhat.com>
Date: Wed, 01 Feb 2012 20:41:14 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <1328128874.15992.6430.camel@triegel.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
	 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
	 <1328118174.15992.6206.camel@triegel.csb>
	 <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
In-Reply-To: <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, 2012-02-01 at 11:47 -0800, Linus Torvalds wrote:
> On Wed, Feb 1, 2012 at 9:42 AM, Torvald Riegel <triegel@redhat.com> wrote:
> >
> > We need a proper memory model.
> 
> Not really.
> 
> The fact is, the kernel will happily take the memory model of the
> underlying hardware.

You do rely on the compiler to do common transformations I suppose:
hoist loads out of loops, CSE, etc.  How do you expect the compiler to
know whether they are allowed for a particular piece of code or not?

An example, C++11 pseudo code:
atomic<int> shared_flags[123];
x = 0;
for(...)
  if (shared_flags[i].load(memory_order_acquire))
    x += shared_data;

Now, can we hoist the load of shared_data to out of the loop?  The
acquire tells the compiler that this is not allowed.
Now assume x86, and it's memory model.  The acquire in there isn't
visible because you don't need a barrier for that.  So, what's the
compiler gonna do?  Never hoist any loops because an acquire might be
intended?
So, you could add a compiler barrier in there (volatile asm...).  But
those work in both directions, and the acquire only works in one
direction, allowing the first store to x to be moved later.

> Trying to impose some compiler description of the
> memory model is actually horribly bad, because it automatically also
> involves compiler synchronization points - which will try to be
> portable and easy to understand, and quite frankly, that will
> automatically result in what is technically known as a "shitload of
> crap".

What is a "compiler synchronization point"?
Have you actually read the C++11/C11 memory model?

> Now, a strict memory model is fine for portability, and to make it
> simple for programmers. I actually largely approve of the Java memory
> model approach, even if it has been horribly problematic and has some
> serious problems. But it's not something that is acceptable for the
> kernel - we absolutely do *not* want the compiler to introduce some
> memory model, because we are very much working together with whatever
> the hardware memory model is, and we do our own serialization
> primitives.

I think you underestimate the issues here.  The memory model that's the
kernel is programmed against is what tells the compiler which
transformations are allowed, and which aren't.  You seem to claim that
this is just the hardware's memory model that counts, but it's clear
that you have an implicit language memory model in mind, because
otherwise the compiler could never hoist any loads, for example (to be
safe, conservatively).

> > No vague assumptions with lots of hand-waving.
> 
> So here's basically what the kernel needs:
> 
>  - if we don't touch a field, the compiler doesn't touch it.

"we don't touch a field": what does that mean precisely?  Never touch it
in the same thread?  Same function?  Same basic block?  Between two
sequence points?  When crossing synchronizing code?  For example, in the
above code, can we touch it earlier/later?

I understand where this rule is heading (granularity races...), but
really, this isn't precise, and this all affects what optimizations are
allowed.  In this context, "show me the code" means having something
more formal, unfortunately, to prevent ambiguities.

For this reason, I suggested to have a look at the C11 model, and then
complain about limitations in this model.

> 
>    This is the rule that gcc now violates with bitfields.

For the volatile case, that's a bug, yes.  For the non-volatile, I'd
need to check.

>    This is a gcc bug. End of story. The "volatile" example proves it -
> anybody who argues otherwise is simply wrong, and is just trying to
> make excuses.

I'm trying to explain here why language memory models are a good thing,
and not the enemy.


>  - if we need to touch something only once, or care about something
> that is touched only conditionally, and we actually need to make sure
> that it is touched *only* under that condition, we already go to quite
> extreme lengths to tell the compiler so.
> 
>    We usually use an access with a "volatile" cast on it or tricks
> like that. Or we do the whole "magic asm that says it modified memory
> to let the compiler know not to try anything clever"
> 
>  - The kernel IS NOT GOING TO MARK DATA STRUCTURES.
> 
> Marking data structures is seriously stupid and wrong. It's not the
> *data* that has access rules, it's the *code* that has rules of
> access.

And types are usually a good way to enforce code that accesses a piece
of state to behave similarly.  Which is what atomic<foo> does, and what
I meant.  From the overall C++/C perspective, it makes sense to require
types for atomics.  For the kernel, I don't care.

> Stuff that is "volatile" in one context is not volatile in another. If
> you hold a RCU write lock, it may well be entirely stable, and marking
> it volatile is *wrong*, and generating code as if it was volatile is
> pure and utter shit.

Agreed.  There is no full and portable way to do the weaker accesses
with atomicsc, but memory_order_relaxed is very close and essentially
just guarantees atomic access, which isn't too hard on most
architectures (ie, not the same overhead as volatile).
You could as well cast the atomic to an nonatomic, but this assumes that
atomics have the same bit representation as the same but nonatomic type.
Might be a reasonable assumption, but not good for general C.

> And no, C11 does *not* do it correctly. The whole "_Atomic" crap is
> exactly the same mistake as "volatile" was. It's wrong. Marking data
> _Atomic is a sure sign that whoever designed it didn't understand
> things.

Like types are a bad idea too?  I think you're exaggerating here.  And
as a general language standard, this cannot be tailored towards just the
kernel hacker.

> 
> > The only candidate that I see is the C++11/C11 model.  Any other
> > suggestions?
> 
> The C11 model addresses the wrong thing

What's the wrong thing?

> , and addresses it badly.

You mean to enforce an atomic type?

> You might as well ignore it as far as the kernel is concerned. I'm
> sure it helps some *other* problem, but it's not the kernel problem.
> 
> The rules really are very simple, and the kernel already does
> everything to make it easy for the compiler.

What would be helpful if you could look at the data-race / access
granularity in the C11 model and tell us whether that is equal with (or
not) the rules you summarized above (no, they were not precise enough,
sorry).

> When we do something that the compiler cannot re-order around, we do
> an asm() and mark it as modifying memory so that the compiler won't
> screw things up. In addition, we will do whatever that the CPU
> requires for memory ordering, and quite frankly, the compiler will
> never have sufficient locking primitives to satisfy us, and there is
> no real point in even trying. If you try to do locking in the
> compiler, you *will* do it wrong.

You don't need to use the stdlib locks.  That's not the memory model.
This is standard library threading support.  The compiler is also not
generating any locking primitives (unless as library fallback code), but
atomic instructions.  They do seem okay in terms of coverage to me
though, if you need others, we could provide.

The memory orders that the C11 model provides generalize things
somewhat, depending on the architecture, I agree.  But which further
ones would you need (e.g., some variant of consume?)?


Torvald

