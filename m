From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 20:44:05 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFwcLpD2Cw5VxZ3ym66QBDAeDam3-hprivrC+keUMXJOtw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb> <20120201194025.GG6148@sunsite.ms.mff.cuni.cz>
 <CA+55aFzVWjqcs1zRF-93_9yHRDS-YgmpgFTzACw6HQ-059U06Q@mail.gmail.com> <20120201201631.GW18768@tyan-ft48-01.lab.bos.redhat.com>
In-Reply-To: <20120201201631.GW18768@tyan-ft48-01.lab.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jakub Jelinek <jakub@redhat.com>
Cc: Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 12:16 PM, Jakub Jelinek <jakub@redhat.com> wrote:
>>
>> So the kernel really doesn't care what you do to things *within* the bit=
field.
>
> But what is *within* the bitfield? =A0Do you consider s4 or t2 fields
> (non-bitfield fields that just the ABI wants to pack together with
> the bitfield) above as *within* or is already modifying of those a proble=
m?

I seriously think you should just do the obvious thing, and LOOK AT
THE BASE TYPE. That solves everything.

If the definition of the data is (assume "long" to be 64 bits)

   long mybits:32;
   int nonbitfield;

and you end up doing a 64-bit access when you read/write the "mybits"
bitfield, and it overlaps "nonbitfield", then I would also just say
"hey, whatever, the user asked for it". He really did. The
"allocation" for the bitfield comes from the base type, and so you
basically have a "long" to play with.

Let's take an even more extreme example:

   int bits1:8
   char c;
   int bits2:16;

where the "char c" is actually *embedded* in the "bitfield
allocation". But again, it's completely and totally unambiguous what
accesses you would at least start out with: sure, you *could* do a
8-bit access (and you probably should, if the ISA allows it), but
dangit, the base type is "int", so I don't think it's wrong to do a
32-bit load, mask, and a 32-bit write.

But if the user wrote

    char bits1:8;
    char c;
    short bits2:16;

then I really think it would be a *bug* if modifying "bits1" would
possible write to 'c'. Of course, this is again a possible ISA
problem: if the architecture doesn't have byte writes, you can't do
anything about it, but that is obviously true regardless of bitfields,
so that's really a totally irrelevant argument for this case. That
non-atomicity doesn't come from bitfields, it comes from the fact that
the BASE TYPE is again non-atomic.

Notice how it always ends up being about the base type. Simple,
straightforward, and unambiguous.

And similarly, to go to the kernel example, if you have

    int mybits:2;
    int nonbitfield;

then I think it's an obvious *BUG* to access the nonbitfield things
when you access "mybits". It clearly is not at all "within" the
bitfield allocation, and "int" isn't non-atomic on any sane
architecture, so you don't even have the "byte accesses aren't atomic"
issue)

So I really do think that the sane approach is to look at the base
type of the bitfield, like I suggested from the very beginning.

If the base type is an "int", you do an int access. It really solves
so many problems, and it is even entirely sane semantics that you can
*explain* to people. It makes sense, it avoids the clear bugs gcc has
now, and it also solves the performance bug I reported a long time
ago.

Seriously - is there any real argument *against* just using the base
type as a hint for access size?

I realize that it may not be simple, and may not fit the current mess
of gcc bitfields, but I really do think it's the RightThing(tm) to do.
It has sensible semantics, and avoids problems.

In contrast, the *current* gcc semantics are clearly not sensible, and
have both performance and correctness issues.

                     Linus
