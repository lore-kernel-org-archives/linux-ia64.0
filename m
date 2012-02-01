From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 21:55:49 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFzq_5ORDUrjptUgXhdSg=jih8=CQPTPb=as9TEB2y+DdQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb> <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
 <1328128874.15992.6430.camel@triegel.csb> <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
 <1328131498.15992.6503.camel@triegel.csb>
In-Reply-To: <1328131498.15992.6503.camel@triegel.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Torvald Riegel <triegel@redhat.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 1:24 PM, Torvald Riegel <triegel@redhat.com> wrote:
>> It's not the only thing we do. We have cases where it's not that you
>> can't hoist things outside of loops, it's that you have to read things
>> exactly *once*, and then use that particular value (ie the compiler
>> can't be allowed to reload the value because it may change). So any
>> *particular* value we read is valid, but we can't allow the compiler
>> to do anything but a single access.
>
> That's what an access to an atomics-typed var would give you as well.

Right. The concept of "atomic" access is required.

The problem I have with treating this as a C11 issue is that people
aren't using C11 compilers, and won't for a long while.

So quite frankly, it won't be reasonable for the kernel people to say
"use a C11 version" for years to come.

And the thing is, "atomic" doesn't actually seem to buy us anything in
the kernel afaik. We're perfectly happy to use "volatile". We don't
want the data structure annotated, we want the code annotated, so the
semantic differences between 'volatile' and 'atomic' seem to be pretty
irrelevant.

Sure, there is probably some subtle difference, but on the whole, it
all boils down to "we can't depend on new rules for several years, and
even when we can, it doesn't look like they'd buy us a lot, because we
have to play so many games around them *anyway*".

And don't get me wrong. I don't think that means that C11 is *bad*.
It's just that the kernel is very different from most other projects.
We have to have those crazy architecture-specific header files and
random synchronization macros etc anyway.

C11 is not - I think - even meant to be geared towards the Linux
kernel kind of crazy use. We really do some odd things, adding
compiler features for them is mostly a mistake. asm() takes care of a
lot of the oddities for us, it's not like all of them are about memory
accesses or concurrency either.

I do think that the threading issues in C11 are going to help us
kernel people, because the more people think about issues with
concurrency, they really *will* be hitting some of the issues we've
been having. So it clearly forces clarification of just what the word
"access" implies, for example, which is certainly not going to be bad
for the kernel.

>> It really doesn't. Loops are fairly unusual in the kernel to begin
>> with, and the compiler barriers are a total non-issue.
>
> This is interesting, because GCC is currently not optimizing across
> atomics but we we're considering working on this later.
> Do you have real data about this, or is this based on analysis of
> samples of compiled code?

So the kernel literally doesn't tend to *have* loops.

Sure, there are exceptions: there are the obvious loops implied in
"memcpy()" and friends, but almost all kernel activity tends to be
about individual events. A really hot loop under normal loads would be
the loop that calculates a hash value over a pathname component. Or
the loop that loops over those components.

Loop count? Think about it. Most pathnames have one or two components.
And while "8.3" is clearly too short for a filename, it's still true
that a lot of filenames (especially directories, which is what you end
up traversing many times) are in a kind of awkward 5-8 character
range.

So the kernel loads tend to have loop counts in the single digits -
*maybe* double digits. We use hash-tables a lot, so looping to find
something is usually just an entry or two, and the cost is almost
never the loop, it's the cache miss from the pointer chasing.

Most "looping" behavior in the kernel is actually user space calling
the kernel in a loop. So the kernel may see "loops" in that sense, but
it's not loopy kernel code itself.

Even really hot kernel-only code is often not about loops. You might
get a million network packets a second, and with interrupt mitigation
you would not necessarily treat them each as individual events with
its own individual interrupt (which does happen too!), but you'd still
not see it as a loop over a million packets. You'd see them come in as
a few packets at a time, and looping until you've handled them.

And the loops we have tend to not be very amenable to nice compiler
optimizations either.

The kernel almost never works with arrays, for example. The string in
a pathname component is an array, yes, but *most* kernel data
structures loop over our doubly linked lists or over a hash-chain.

And it tends to be really hard to do much loop optimization over list
traversal like that.

>> If the source code doesn't write to it, the assembly the compiler
>> generates doesn't write to it.
>
> If it would be so easy, then answering my questions would have been easy
> too, right? =A0Which piece of source code? =A0The whole kernel?

So make the rule be: "in one single function, with all you can see
there", and I'll be happy. Do as much inlining as you want (although
the kernel does have "noinline" too).

With all the normal sequence point and memory invalidation event rules
etc. If you have two non-pure function calls (or barriers, or whatever
like that) that may change memory, and in between them nothing in the
source code writes to a structure member, then there had damn well not
be any stores to that member in the resulting asm either!

IOW, it's all the normal memory access rules. You can't do random
read-write events to variables that aren't mentioned by the source
code, because other threads may be doing it without your knowledge.

None of this is subtle or even complicated.

The thing that brought it up was an obvious compiler bug. Well, it's
obviously a bug, but it was equally obviously very hard to find.

Fix the test-case. It's a small and simple test-case.

And fix it for the "sig_atomic_t" case, which doesn't even imply
"volatile". So you can't use volatile as some kind of magic marker for
"now we can't do it".

Anything else is irrelevant. You have a non-kernel test-case that
shows a bug. Don't worry about the kernel.

                   Linus
