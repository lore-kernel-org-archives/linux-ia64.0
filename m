From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 18:52:51 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFxt3rG8_HyoRqiMOKVDqaGTkRk=Kh+bAJTAxxdHAGzuVw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <1328114266.5355.44.camel@lenny>
 <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com>
 <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz> <Pine.LNX.4.64.1202011818570.25409@wotan.suse.de>
In-Reply-To: <Pine.LNX.4.64.1202011818570.25409@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Michael Matz <matz@suse.de>
Cc: Jiri Kosina <jkosina@suse.cz>, Colin Walters <walters@verbum.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 9:41 AM, Michael Matz <matz@suse.de> wrote:
>
> One problem is that it's not a new problem, GCC emitted similar code since
> about forever, and still they turned up only now (well, probably because
> ia64 is dead, but sparc64 should have similar problems). =A0The bitfield
> handling code is _terribly_ complex and fixing it is quite involved. =A0So
> don't expect any quick fixes.

I agree that bitfields are nasty, I've had to handle them myself in
sparse. And we have actually had problems with bitfields before, to
the point where we've replaced use of bitfields with masking and
setting bits by hand.

But I also think that gcc is simply *buggy*, and has made them much
nastier than they should be. What gcc *should* have done is to turn
bitfield accesses into shift-and-masking of the underlying field as
early as possible, and then do all optimizations at that level.

In fact, there is another gcc bug outstanding (48696) where I complain
about absolutely horrible code generation, and that one was actually
the exact same issue except in reverse: gcc wouldn't take the
underlying size of the bitfield into account, and use the wrong
(smaller) size for the access, causing absolutely horrendous code
generation that mixes byte and word accesses, and causes slowdowns by
orders of magnitude.

And it really is the same issue: gcc has forgotten what the base type
is, and tries to "compute" some type using the actual bits. Which is
simply *wrong*. Always has been.

It's stupid, it generates bad code (both from performance *and* from a
correctness angle), and it has actually resulted in gcc having *extra*
complexity because it keeps the bitfield data around much too late.

> The other problem is specification. =A0While you think that the code you
> wrote is totally obvious it might not actually be so. =A0For instance, wh=
at
> about this struct:
>
> {long l:32; int i1:16; short s; int i2:1; char c:7; short s2:8; short s3;}
>
> What are the obviously correct accesses for various writes into this
> struct?

I really don't think that example matters. You should instead turn the
question around, and look at the real code examples, make *those*
generate good and obviously correct code, and then *after* you've done
that, you start looking at the mixed case where people do odd things.

Quite frankly, the layout that makes *sense* for something like the
above is not to pack them. You'd just do

If somebody actually wants packing, they'd do the *sane* thing, which is

  unsigned int l:32, i1:16; s:16,i2:1, c:7, s2:8, s3:16;

and now it's obvious what the packing rules and the access rules are.

That said, I just tried, and 'sparse' actually gets your crazy example
right (where "right" is defined as what I *think* you want): optimally
packed. And it turns the accesses into the ones that are based on the
base type.  And I'm pretty sure the sparse bitfield rules are way
simpler than gcc, exactly because it tries to convert bitfields fairly
early into mask-and-set. So if I do

  struct {long l:32; int i1:16; short s; int i2:1; char c:7; short
s2:8; short s3;} dummy;

  int main(int argc, char **argv)
  {
	dummy.l =3D 1;
	dummy.i1 =3D 2;
        dummy.s =3D 3;
        dummy.i2 =3D 4;
        dummy.c =3D 5;
        dummy.s2 =3D 6;
        dummy.s3 =3D 7;
  }

and then do a test-linearize (with "-m64" to show the difference
between "long" and "int") I get

  t.c:2:48: error: dubious one-bit signed bitfield
  main:
  .L0x7f928e378010:
	<entry-point>
	load.64     %r1 <- 0[dummy]
	and.64      %r2 <- %r1, $0xffffffff00000000
	or.64       %r3 <- %r2, $1
	store.64    %r3 -> 0[dummy]
	load.32     %r4 <- 4[dummy]
	and.32      %r5 <- %r4, $0xffffffffffff0000
	or.32       %r6 <- %r5, $2
	store.32    %r6 -> 4[dummy]
	store.16    $3 -> 6[dummy]
	load.32     %r7 <- 8[dummy]
	and.32      %r8 <- %r7, $-2
	store.32    %r8 -> 8[dummy]
	load.8      %r10 <- 8[dummy]
	and.8       %r12 <- %r10, $-255
	or.8        %r13 <- %r12, $10
	store.8     %r13 -> 8[dummy]
	load.16     %r14 <- 8[dummy]
	and.16      %r16 <- %r14, $0xffffffffffff00ff
	or.16       %r17 <- %r16, $0x600
	store.16    %r17 -> 8[dummy]
	store.16    $7 -> 10[dummy]
	ret.32      $7

which I think is what you'd expect. Now, sparse doesn't do the smart
"combine shifts-and-masks to memory", but that's an optimization phase
that should be done long after bitfields *anyway*, so that's kind of
immaterial.

And yes, look at how you can see how sparse mixes different access
sizes for different fields. But that is damn well what the programmer
asked for.

If programmers write stupid code, the compiler might as well generate odd c=
ode.

But if a programmer writes *good* code, and the compiler messes it up
because it *thinks* the code is stupid, then the compiler is just bad.

> One rule may be to never write to a bitfield with accesses larger than
> their underlying declared type. =A0Well, but only if the bitfield fits in=
to
> that type (int:96 is quite okay to have, and what accesses should be
> allowed there?).

Actually, "int:96" isn't ok last I saw. Not in original C, at least.

Yeah, I just checked. You get an error like

   error: width of =91a=92 exceeds its type

so "int:96" is fine, but only if int is bigger than or equal to 96 bits.

>=A0That might be one obvious rule. =A0But it's not how
> traditional bitfield layout works. =A0It works based on underlying object=
s,
> and for that e.g. the three fields i2,c,s are all in the same one, of int
> type.

I think that's actually because bitfields are really only defined for
'int' to begin with afaik. Anything else (well, "unsigned" is fine
too) is not really defined.

The 'long' thing is a later extension, and the shorter fields are just
random. They happen to be pretty portable.

> The rule above would at least work for code that most people do write,
> i.e. sequence of same-typed bitfields mixed with normal members.

Right. Where the same-type should generally be "unsigned int"
(bitfield signs are really debatable and nonportable too, so unsigned
is actually the only really sane type, although others do work).

> And then, there's the last problem: are you sure that if GCC would use 4
> byte accesses for the case at hand, that the hardware wouldn't screw you
> again? =A0What about using atomic instructions for one half of the
> cache-line (the spinlock) but non-atomic instructions on the other half
> (the bitfield). =A0Are you sure the latter won't interfere with the forme=
r?

Yes, I'm sure. Of course, if the architecture isn't cache-coherent,
all bets are off, but nobody cares. That's a hardware issue, not a
compiler problem.

If we told you "unsigned int bitfield:x", then you as the compiler
should just assume that you can access it as an "int" (unless you only
allocate a "char' for it, of course, in which case you need to access
it as a char - you can never access past the field).

Just out of morbid curiosity, what happens if you have totally
*separate* variables that just happen to link together? IOW, something
like

   static struct { unsigned bit:1; } onebit;
   static volatile int var;

and they just *happen* to link next to each other (because they were
declared next to each other) in the same 8-byte aligned block?

                 Linus
