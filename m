From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 20:01:46 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFzVWjqcs1zRF-93_9yHRDS-YgmpgFTzACw6HQ-059U06Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb> <20120201194025.GG6148@sunsite.ms.mff.cuni.cz>
In-Reply-To: <20120201194025.GG6148@sunsite.ms.mff.cuni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jakub Jelinek <jakub@redhat.com>
Cc: Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 11:40 AM, Jakub Jelinek <jakub@redhat.com> wrote:
>
> Well, the C++11/C11 model doesn't allow to use the underlying type
> for accesses, consider e.g.
>
> struct S { long s1; unsigned int s2 : 5; unsigned int s3 : 19; unsigned c=
har s4; unsigned int s5; };
> struct T { long s1 : 16; unsigned int s2; };
>
> on e.g. x86_64-linux, S is 16 byte long, field s4 is packed together into
> the same 32 bits as s2 and s3. =A0While the memory model allows s2 to be
> changed when storing s3 (i.e. use a RMW cycle on it), it doesn't allow s4
> to be changed, as it isn't a bitfield (you'd need s4 : 8 for that).
> T is 8 bytes long, again, s2 is packed into the same 64 bits as s1,
> and the memory model doesn't allow s2 to be modified.
>
> Not sure what the kernel would expect in such a case.

So the kernel really doesn't care what you do to things *within* the bitfie=
ld.

Sure, we do have some expectations of packing, but basically we never
expect bitfields to be 'atomic'. You really don't need to worry about
that.

From a correctness standpoint, I really don't think the kernel cares
if gcc does bitfield reads and writes one bit at a time. Seriously.

The bug is that the bitfield write wrote *outside* the bitfield.
That's *WRONG*. It's completely wrong, even if you write back the same
value you read. It's *always* wrong. It's simply not acceptable.

If gcc does that kind of crap, then gcc needs to align bitfields
sufficiently that the accesses that are outside the bitfields never
touch any other fields.

So what I would suggest:

 - use the *smallest* aligned access you can use to access the
bitfield. This will be 'correct', but it may perform badly.

   This is apparently what x86 does. So on x86, if you have a one-bit
bitfield within a bitfield that is really 32 bits wide, it looks like
gcc will generally generate a byte load/store to set that bit. I don't
know exactly what the rules are, but this is fine from a *correctness*
point.

 - However, while using the *smallest* possible access may generate
correct code, it often generates really *crappy* code. Which is
exactly the bug that I reported in

   http://gcc.gnu.org/bugzilla/show_bug.cgi?idH696

So quite frankly, my suggestion is to just try to use the base type.

But *whatever* you do, using a type *larger* than the whole bitfield
itself is a bug.

And dammit, the people who continue to bring up C11 as if this was a
new issue, and only needs to be worried about if you support C11 (ie
gcc-4.7 and up) are just in denial.

The 'volatile'  example makes it entirely clear that the bug has
nothing what-so-ever to do with C11.

                    Linus
