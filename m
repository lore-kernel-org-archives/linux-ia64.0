From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 19:47:12 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb>
In-Reply-To: <1328118174.15992.6206.camel@triegel.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Torvald Riegel <triegel@redhat.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 9:42 AM, Torvald Riegel <triegel@redhat.com> wrote:
>
> We need a proper memory model.

Not really.

The fact is, the kernel will happily take the memory model of the
underlying hardware. Trying to impose some compiler description of the
memory model is actually horribly bad, because it automatically also
involves compiler synchronization points - which will try to be
portable and easy to understand, and quite frankly, that will
automatically result in what is technically known as a "shitload of
crap".

Now, a strict memory model is fine for portability, and to make it
simple for programmers. I actually largely approve of the Java memory
model approach, even if it has been horribly problematic and has some
serious problems. But it's not something that is acceptable for the
kernel - we absolutely do *not* want the compiler to introduce some
memory model, because we are very much working together with whatever
the hardware memory model is, and we do our own serialization
primitives.

>=A0No vague assumptions with lots of hand-waving.

So here's basically what the kernel needs:

 - if we don't touch a field, the compiler doesn't touch it.

   This is the rule that gcc now violates with bitfields.

   This is a gcc bug. End of story. The "volatile" example proves it -
anybody who argues otherwise is simply wrong, and is just trying to
make excuses.

 - if we need to touch something only once, or care about something
that is touched only conditionally, and we actually need to make sure
that it is touched *only* under that condition, we already go to quite
extreme lengths to tell the compiler so.

   We usually use an access with a "volatile" cast on it or tricks
like that. Or we do the whole "magic asm that says it modified memory
to let the compiler know not to try anything clever"

 - The kernel IS NOT GOING TO MARK DATA STRUCTURES.

Marking data structures is seriously stupid and wrong. It's not the
*data* that has access rules, it's the *code* that has rules of
access.

The traditional C "volatile" is misdesigned and wrong. We don't
generally mark data volatile, we really mark *code* volatile - which
is why our "volatiles" are in the casts, not on the data structures.

Stuff that is "volatile" in one context is not volatile in another. If
you hold a RCU write lock, it may well be entirely stable, and marking
it volatile is *wrong*, and generating code as if it was volatile is
pure and utter shit.

On the other hand, if you are touching *the*very*same* field while you
are only read-locked for RCU, it may well be one of those "this has to
be read by accessing it exactly once".

And we do all this correctly in the kernel.  Modulo bugs, of course,
but the fundamental rule really is: "atomicity or volatility is about
CODE, not DATA".

And no, C11 does *not* do it correctly. The whole "_Atomic" crap is
exactly the same mistake as "volatile" was. It's wrong. Marking data
_Atomic is a sure sign that whoever designed it didn't understand
things.

> The only candidate that I see is the C++11/C11 model. =A0Any other
> suggestions?

The C11 model addresses the wrong thing, and addresses it badly.

You might as well ignore it as far as the kernel is concerned. I'm
sure it helps some *other* problem, but it's not the kernel problem.

The rules really are very simple, and the kernel already does
everything to make it easy for the compiler.

When we do something that the compiler cannot re-order around, we do
an asm() and mark it as modifying memory so that the compiler won't
screw things up. In addition, we will do whatever that the CPU
requires for memory ordering, and quite frankly, the compiler will
never have sufficient locking primitives to satisfy us, and there is
no real point in even trying. If you try to do locking in the
compiler, you *will* do it wrong.

If you add random flags on data structures ("_Atomic" or "volatile" or
whatever), you *will* do it wrong. It's simply a fundamentally broken
model.

So the *only* memory model we want from the compiler really is: "don't
write to fields that the source code didn't write to".

It's really is that simple.

> So, would it be okay to tell the compiler which part of the state is
> accessed concurrently (ie, locks, atomics, ...)?

Seriously, no.

See above: it's not the "state" that is accessed concurrently. It's
the code. If you ever try to mark state, you've already lost. The same
"state" can be atomic or not depending on context. It's not about the
state or the data structures, and it never will be.

                        Linus
