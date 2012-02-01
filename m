From: Torvald Riegel <triegel@redhat.com>
Date: Wed, 01 Feb 2012 21:24:58 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <1328131498.15992.6503.camel@triegel.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
	 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
	 <1328118174.15992.6206.camel@triegel.csb>
	 <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
	 <1328128874.15992.6430.camel@triegel.csb>
	 <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
In-Reply-To: <CA+55aFx4SdtZcYaWZ-=JG3yVFJxsBa-Yqn0m+h4Y=QHdRjx6_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, 2012-02-01 at 12:59 -0800, Linus Torvalds wrote:
> On Wed, Feb 1, 2012 at 12:41 PM, Torvald Riegel <triegel@redhat.com> wrote:
> >
> > You do rely on the compiler to do common transformations I suppose:
> > hoist loads out of loops, CSE, etc.  How do you expect the compiler to
> > know whether they are allowed for a particular piece of code or not?
> 
> We have barriers.
> 
> Compiler barriers are cheap. They look like this:
[snip]

I know, and I've programmed my chunk of concurrent code with those and
architecture-specific code too (or libatomic-ops for a bit more
ready-to-use portability).

> It's not the only thing we do. We have cases where it's not that you
> can't hoist things outside of loops, it's that you have to read things
> exactly *once*, and then use that particular value (ie the compiler
> can't be allowed to reload the value because it may change). So any
> *particular* value we read is valid, but we can't allow the compiler
> to do anything but a single access.

That's what an access to an atomics-typed var would give you as well.

> And I realize that compiler people tend to think that loop hoisting
> etc is absolutely critical for performance, and some big hammer like
> "barrier()" makes a compiler person wince. You think it results in
> horrible code generation problems.
> 
> It really doesn't. Loops are fairly unusual in the kernel to begin
> with, and the compiler barriers are a total non-issue.

This is interesting, because GCC is currently not optimizing across
atomics but we we're considering working on this later.
Do you have real data about this, or is this based on analysis of
samples of compiled code?

> We have much
> more problems with the actual CPU barriers that can be *very*
> expensive on some architectures, and we work a lot at avoiding those
> and avoiding cacheline ping-pong issues etc.

Well, obviously...

> 
> >> > No vague assumptions with lots of hand-waving.
> >>
> >> So here's basically what the kernel needs:
> >>
> >>  - if we don't touch a field, the compiler doesn't touch it.
> >
> > "we don't touch a field": what does that mean precisely?  Never touch it
> > in the same thread?  Same function?  Same basic block?  Between two
> > sequence points?  When crossing synchronizing code?  For example, in the
> > above code, can we touch it earlier/later?
> 
> Why are you trying to make it more complex than it is?
> 
> If the source code doesn't write to it, the assembly the compiler
> generates doesn't write to it.

If it would be so easy, then answering my questions would have been easy
too, right?  Which piece of source code?  The whole kernel?

> 
> Don't try to make it anything more complicated. This has *nothing* to
> do with threads or functions or anything else.
> 
> If you do massive inlining, and you don't see any barriers or
> conditionals or other reasons not to write to it, just write to it.

And a precise definition of these reasons is what we need to agree on.

> Don't try to appear smart and make this into something it isn't.

Even if I would have done it, it wouldn't be as rude as trying to imply
that other people aren't smart.

