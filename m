From: Michael Matz <matz@suse.de>
Date: Thu, 02 Feb 2012 13:43:10 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <Pine.LNX.4.64.1202021320470.25409@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <1328114266.5355.44.camel@lenny>
 <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com>
 <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz>
 <Pine.LNX.4.64.1202011818570.25409@wotan.suse.de>
 <CA+55aFxt3rG8_HyoRqiMOKVDqaGTkRk=Kh+bAJTAxxdHAGzuVw@mail.gmail.com>
In-Reply-To: <CA+55aFxt3rG8_HyoRqiMOKVDqaGTkRk=Kh+bAJTAxxdHAGzuVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jiri Kosina <jkosina@suse.cz>, Colin Walters <walters@verbum.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

Hi,

On Wed, 1 Feb 2012, Linus Torvalds wrote:

> But I also think that gcc is simply *buggy*, and has made them much 
> nastier than they should be. What gcc *should* have done is to turn 
> bitfield accesses into shift-and-masking of the underlying field as 
> early as possible, and then do all optimizations at that level.

Indeed.  And there's even work going on towards that (stalled in the 
moment), but you know how it is, should, could, would.

> In fact, there is another gcc bug outstanding (48696) where I complain
> about absolutely horrible code generation, and that one was actually
> the exact same issue except in reverse: gcc wouldn't take the
> underlying size of the bitfield into account, and use the wrong
> (smaller) size for the access,

That's actually one example why not everything is so totally obvious.  We 
really don't want to store into more bytes than "allowed" (and as we are 
at it, extend this even to reading for volatile members).  For some 
definition for "allowed".

For the ia64 problem at hand it has to surely exclude non-adjacent 
bitfield members.  For PR48124 (writing beyond end of decl) it has to be 
constrained to the size of a decl of such struct type (seems obvious, but 
it's surprising how long you get away with some less strict rule, namely 
only excluding everything after the next alignment border). Well, that's 
all sensible restrictions.  But for your optimization problem you have to 
extend the allowed range a bit again (to at least contain all adjacent 
bitfields), but not too much to break the next guy screaming "but here you 
obviously do a wild write".

For instance, given these three structs:

struct s1 {short a; short b; unsigned c:1;};
struct s2 {short a:16; short b:16; unsigned c:1;};
struct s3 {unsigned a:16; unsigned b:16; unsigned c:1;};

Are the writes to x.b allowed to touch x.a?  And writing x.c?  I think I 
know what you will claim (no crossing writes, except for s3.a and s3.b can 
be combined), but let's say I claim that there's no difference between all 
three structures, and therefore there should be no difference in what's 
allowed to be touched and what not.  In particular the declared type is 
not what matters in allowing certain accesses.  So, if you want to combine 
s3.a and s3.b (which is implied by your PR48696), you'll have to give me 
also combining s2.a and s2.b.  (I'm not so nasty to also want combining 
s1.a and s1.b, because there are other deeper reasons why s1 and the rest 
differ).

The point is, there are simply different opinions and point of views.  
Using exclamation marks, bold typography and hyperbole doesn't make anyone 
more correct nor does it make the problem simpler than it is.

>   struct {long l:32; int i1:16; short s; int i2:1; char c:7; short
> s2:8; short s3;} dummy;
> 
>   int main(int argc, char **argv)
>   {
> 	dummy.l = 1;
> 	dummy.i1 = 2;
> 
> and then do a test-linearize (with "-m64" to show the difference
> between "long" and "int") I get
> 
>   t.c:2:48: error: dubious one-bit signed bitfield
>   main:
>   .L0x7f928e378010:
> 	<entry-point>
> 	load.64     %r1 <- 0[dummy]
> 	and.64      %r2 <- %r1, $0xffffffff00000000
> 	or.64       %r3 <- %r2, $1
> 	store.64    %r3 -> 0[dummy]

Here you store 8 bytes, touching ...

> 	load.32     %r4 <- 4[dummy]

... this int.  Both corresponds to members "long l:32; int i1:16;".  They 
don't have the same base type, hence per your own rule they shouldn't be 
allowed to touch each other (later on you also talk about the definedness 
for bit-fields only with int, which also hints that you think one better 
should always use int containers).  Dang, still thinking this is easy?

> And yes, look at how you can see how sparse mixes different access sizes 
> for different fields. But that is damn well what the programmer asked 
> for.
> 
> If programmers write stupid code, the compiler might as well generate 
> odd code.

But what exactly constitutes "stupid" code?  Are you really unable to see 
that we're exactly struggling to find rules to differ between "stupid" and 
supposedly "non-stupid" code?  What if I'm saying that anyone using 
bitfields writes "stupid" code, and hence the compiler can as well 
generate odd code?

> Actually, "int:96" isn't ok last I saw. Not in original C, at least.

GCC supports multiple languages.  For C++ it's valid (well, you get a 
warning, and you can't do much with that member, but there we are).

> Just out of morbid curiosity, what happens if you have totally
> *separate* variables that just happen to link together? IOW, something
> like
> 
>    static struct { unsigned bit:1; } onebit;
>    static volatile int var;
> 
> and they just *happen* to link next to each other (because they were
> declared next to each other) in the same 8-byte aligned block?

non-struct decls always work.  It's only the bit-field expander that 
willy-nilly invents access modes (for some targets), and sometimes block 
moves have problems.  Until about 2008 we could do out-of-range writes  
with struct copies (which usually works fine when they are naturally 
aligned), fixed with PR31309.  A related problem which I think is still 
there is PR36043 (also out-of-range struct read, when passing stuff in 
registers).

And as said, PR48124 is an out-of-range write, but again involving 
bit-fields.

You see, we actually have much more serious problems than just clobbering 
memory in under-specified situations ;-)


Ciao,
Michael.
