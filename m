From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 20:59:24 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb> <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
 <1328128874.15992.6430.camel@triegel.csb>
In-Reply-To: <1328128874.15992.6430.camel@triegel.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Torvald Riegel <triegel@redhat.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 12:41 PM, Torvald Riegel <triegel@redhat.com> wrote:
>
> You do rely on the compiler to do common transformations I suppose:
> hoist loads out of loops, CSE, etc. =A0How do you expect the compiler to
> know whether they are allowed for a particular piece of code or not?

We have barriers.

Compiler barriers are cheap. They look like this:

    include/linux/compiler-gcc.h:
       #define barrier() __asm__ __volatile__("": : :"memory")

and if we don't allow hoisting, we'll often use something like that.

It's not the only thing we do. We have cases where it's not that you
can't hoist things outside of loops, it's that you have to read things
exactly *once*, and then use that particular value (ie the compiler
can't be allowed to reload the value because it may change). So any
*particular* value we read is valid, but we can't allow the compiler
to do anything but a single access.

So we have this beauty:

    include/linux/compiler.h:
        #define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))

which does that for us (quite often, it's not used as-is: a more
common case is using the "rcu_access_pointer()" inline function that
not only does that ACCESS_ONCE() but also has the capability to enable
run-time dynamic verification that you are in a proper RCU read locked
section etc)

We also have tons of (very subtle) code that actually creates locks
and memory ordering etc. They usually just use the big "barrier()"
approach to telling the compiler not to combine or move memory
accesses around it.

And I realize that compiler people tend to think that loop hoisting
etc is absolutely critical for performance, and some big hammer like
"barrier()" makes a compiler person wince. You think it results in
horrible code generation problems.

It really doesn't. Loops are fairly unusual in the kernel to begin
with, and the compiler barriers are a total non-issue. We have much
more problems with the actual CPU barriers that can be *very*
expensive on some architectures, and we work a lot at avoiding those
and avoiding cacheline ping-pong issues etc.

>> > No vague assumptions with lots of hand-waving.
>>
>> So here's basically what the kernel needs:
>>
>> =A0- if we don't touch a field, the compiler doesn't touch it.
>
> "we don't touch a field": what does that mean precisely? =A0Never touch it
> in the same thread? =A0Same function? =A0Same basic block? =A0Between two
> sequence points? =A0When crossing synchronizing code? =A0For example, in =
the
> above code, can we touch it earlier/later?

Why are you trying to make it more complex than it is?

If the source code doesn't write to it, the assembly the compiler
generates doesn't write to it.

Don't try to make it anything more complicated. This has *nothing* to
do with threads or functions or anything else.

If you do massive inlining, and you don't see any barriers or
conditionals or other reasons not to write to it, just write to it.

Don't try to appear smart and make this into something it isn't.

Look at the damn five-line example of the bug. FIX THE BUG. Don't try
to make it anything bigger than a stupid compiler bug. Don't try to
make this into a problem it simply isn't.

                 Linus
