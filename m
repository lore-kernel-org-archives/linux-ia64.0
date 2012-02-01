From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 21:20:51 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFx=4AhdFEgjY3b=85__mGYX8BKcaXpFC=1XZzoFFjeTrw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <1328116137.15992.6146.camel@triegel.csb>
 <CA+55aFyG3EifFPapU6SFYXCjrP+wQOF65hJGs3yyMxCgde5vdg@mail.gmail.com> <1328129620.15992.6453.camel@triegel.csb>
In-Reply-To: <1328129620.15992.6453.camel@triegel.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Torvald Riegel <triegel@redhat.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 12:53 PM, Torvald Riegel <triegel@redhat.com> wrote:
>
> For volatile, I agree.
>
> However, the original btrfs example was *without* a volatile, and that's
> why I raised the memory model point. =A0This triggered an error in a
> concurrent execution, so that's memory model land, at least in C
> language standard.

Sure. The thing is, if you fix the volatile problem, you'll almost
certainly fix our problem too.

The whole "compilers actually do reasonable things" approach really
does work in reality. It in fact works a lot better than reading some
spec and trying to figure out if something is "valid" or not, and
having fifteen different compiler writers and users disagree about
what the meaning of the word "is" is in some part of it.

I'm not kidding. With specs, there really *are* people who spend years
discussing what the meaning of the word "access" is or similar.
Combine that with a big spec that is 500+ pages in size and then try
to apply that all to a project that is 15 million lines of code and
sometimes *knowingly* has to do things that it simply knows are
outside the spec, and the discussion about these kinds of details is
just mental masturbation.


>> We do end up doing
>> much more aggressive threading, with models that C11 simply doesn't
>> cover.
>
> Any specific examples for that would be interesting.

Oh, one of my favorite (NOT!) pieces of code in the kernel is the
implementation of the

   smp_read_barrier_depends()

macro, which on every single architecture except for one (alpha) is a no-op.

We have basically 30 or so empty definitions for it, and I think we
have something like five uses of it. One of them, I think, is
performance crticial, and the reason for that macro existing.

What does it do? The semantics is that it's a read barrier between two
different reads that we want to happen in order wrt two writes on the
writing side (the writing side also has to have a "smp_wmb()" to order
those writes). But the reason it isn't a simple read barrier is that
the reads are actually causally *dependent*, ie we have code like

   first_read =3D read_pointer;
   smp_read_barrier_depends();
   second_read =3D *first_read;

and it turns out that on pretty much all architectures (except for
alpha), the *data*dependency* will already guarantee that the CPU
reads the thing in order. And because a read barrier can actually be
quite expensive, we don't want to have a read barrier for this case.

But alpha? Its memory consistency is so broken that even the data
dependency doesn't actually guarantee cache access order. It's
strange, yes. No, it's not that alpha does some magic value prediction
and can do the second read without having even done the first read
first to get the address. What's actually going on is that the cache
itself is unordered, and without the read barrier, you may get a stale
version from the cache even if the writes were forced (by the write
barrier in the writer) to happen in the right order.

You really want to try to describe issues like this in your memory
consistency model? No you don't. Nobody will ever really care, except
for crazy kernel people. And quite frankly, not even kernel people
care: we have a fairly big kernel developer community, and the people
who actually talk about memory ordering issues can be counted on one
hand. There's the "RCU guy" who writes the RCU helper functions, and
hides the proper serializing code into those helpers, so that normal
mortal kernel people don't have to care, and don't even have to *know*
how ignorant they are about the things.

And that's also why the compiler shouldn't have to care. It's a really
small esoteric detail, and it can be hidden in a header file and a set
of library routines. Teaching the compiler about crazy memory ordering
would just not be worth it. 99.99% of all programmers will never need
to understand any of it, they'll use the locking primitives and follow
the rules, and the code that makes it all work is basically invisible
to them.

                        Linus
