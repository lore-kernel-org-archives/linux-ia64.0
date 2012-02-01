From: Torvald Riegel <triegel@redhat.com>
Date: Wed, 01 Feb 2012 21:37:46 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <1328132266.15992.6528.camel@triegel.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
	 <1328116137.15992.6146.camel@triegel.csb>
	 <CA+55aFyG3EifFPapU6SFYXCjrP+wQOF65hJGs3yyMxCgde5vdg@mail.gmail.com>
	 <1328129620.15992.6453.camel@triegel.csb>
	 <CA+55aFx=4AhdFEgjY3b=85__mGYX8BKcaXpFC=1XZzoFFjeTrw@mail.gmail.com>
In-Reply-To: <CA+55aFx=4AhdFEgjY3b=85__mGYX8BKcaXpFC=1XZzoFFjeTrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, 2012-02-01 at 13:20 -0800, Linus Torvalds wrote:
> On Wed, Feb 1, 2012 at 12:53 PM, Torvald Riegel <triegel@redhat.com> wrote:
> >
> > For volatile, I agree.
> >
> > However, the original btrfs example was *without* a volatile, and that's
> > why I raised the memory model point.  This triggered an error in a
> > concurrent execution, so that's memory model land, at least in C
> > language standard.
> 
> Sure. The thing is, if you fix the volatile problem, you'll almost
> certainly fix our problem too.
> 
> The whole "compilers actually do reasonable things" approach really
> does work in reality. It in fact works a lot better than reading some
> spec and trying to figure out if something is "valid" or not, and
> having fifteen different compiler writers and users disagree about
> what the meaning of the word "is" is in some part of it.

That's why researchers have formalized the model in order to verify
whether it's sane.  And they found bugs / ambiguities in it:
http://www.cl.cam.ac.uk/~pes20/cpp/

The standards text might still be a typical standards text for various
reasons. But it enables having a formal version of it too, and
discussions about this formal version.  Personally, I find this more
formal model easier to work with, exactly because it is more precise
than prose.

> 
> >> We do end up doing
> >> much more aggressive threading, with models that C11 simply doesn't
> >> cover.
> >
> > Any specific examples for that would be interesting.
> 
> Oh, one of my favorite (NOT!) pieces of code in the kernel is the
> implementation of the
> 
>    smp_read_barrier_depends()
> 
> macro, which on every single architecture except for one (alpha) is a no-op.
> 
> We have basically 30 or so empty definitions for it, and I think we
> have something like five uses of it. One of them, I think, is
> performance crticial, and the reason for that macro existing.
> 
> What does it do? The semantics is that it's a read barrier between two
> different reads that we want to happen in order wrt two writes on the
> writing side (the writing side also has to have a "smp_wmb()" to order
> those writes). But the reason it isn't a simple read barrier is that
> the reads are actually causally *dependent*, ie we have code like
> 
>    first_read = read_pointer;
>    smp_read_barrier_depends();
>    second_read = *first_read;
> 
> and it turns out that on pretty much all architectures (except for
> alpha), the *data*dependency* will already guarantee that the CPU
> reads the thing in order. And because a read barrier can actually be
> quite expensive, we don't want to have a read barrier for this case.

I don't have time to look at this in detail right now, but it looks
roughly close to C++11's memory_order_consume to me, which is somehwat
like an acquire, but just for subsequent data-dependent loads.  Added
for performance reasons on some architecture AFAIR.

> You really want to try to describe issues like this in your memory
> consistency model? No you don't. Nobody will ever really care, except
> for crazy kernel people. And quite frankly, not even kernel people
> care: we have a fairly big kernel developer community, and the people
> who actually talk about memory ordering issues can be counted on one
> hand. There's the "RCU guy" who writes the RCU helper functions, and
> hides the proper serializing code into those helpers, so that normal
> mortal kernel people don't have to care, and don't even have to *know*
> how ignorant they are about the things.

I'm not a kernel person, and I do care about it.  Userspace is
synchronizing too, and not just with pthread mutexes.

> And that's also why the compiler shouldn't have to care. It's a really
> small esoteric detail, and it can be hidden in a header file and a set
> of library routines. Teaching the compiler about crazy memory ordering
> would just not be worth it. 99.99% of all programmers will never need
> to understand any of it, they'll use the locking primitives and follow
> the rules, and the code that makes it all work is basically invisible
> to them.

I disagree (though it would be nice if it were that esoteric), but
that's off-topic...

