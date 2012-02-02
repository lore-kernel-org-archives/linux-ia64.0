From: Richard Guenther <rguenther@suse.de>
Date: Thu, 02 Feb 2012 09:35:34 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <alpine.LNX.2.00.1202021028360.4999@zhemvz.fhfr.qr>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="8323584-292295540-1328175335=:4999"
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <1328114266.5355.44.camel@lenny> <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com> <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz> <Pine.LNX.4.64.1202011818570.25409@wotan.suse.de>
 <CA+55aFxt3rG8_HyoRqiMOKVDqaGTkRk=Kh+bAJTAxxdHAGzuVw@mail.gmail.com>
In-Reply-To: <CA+55aFxt3rG8_HyoRqiMOKVDqaGTkRk=Kh+bAJTAxxdHAGzuVw@mail.gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michael Matz <matz@suse.de>, Jiri Kosina <jkosina@suse.cz>, Colin Walters <walters@verbum.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, gcc@gcc.gnu.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-292295540-1328175335=:4999
Content-Type: TEXT/PLAIN; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable

On Wed, 1 Feb 2012, Linus Torvalds wrote:

> On Wed, Feb 1, 2012 at 9:41 AM, Michael Matz <matz@suse.de> wrote:
> >
> > One problem is that it's not a new problem, GCC emitted similar code si=
nce
> > about forever, and still they turned up only now (well, probably because
> > ia64 is dead, but sparc64 should have similar problems). =A0The bitfield
> > handling code is _terribly_ complex and fixing it is quite involved. =
=A0So
> > don't expect any quick fixes.
>=20
> I agree that bitfields are nasty, I've had to handle them myself in
> sparse. And we have actually had problems with bitfields before, to
> the point where we've replaced use of bitfields with masking and
> setting bits by hand.
>=20
> But I also think that gcc is simply *buggy*, and has made them much
> nastier than they should be. What gcc *should* have done is to turn
> bitfield accesses into shift-and-masking of the underlying field as
> early as possible, and then do all optimizations at that level.
>=20
> In fact, there is another gcc bug outstanding (48696) where I complain
> about absolutely horrible code generation, and that one was actually
> the exact same issue except in reverse: gcc wouldn't take the
> underlying size of the bitfield into account, and use the wrong
> (smaller) size for the access, causing absolutely horrendous code
> generation that mixes byte and word accesses, and causes slowdowns by
> orders of magnitude.

Yeah, sorry for dropping the ball on this one (and missing my original
GCC 4.7 target ...)

> And it really is the same issue: gcc has forgotten what the base type
> is, and tries to "compute" some type using the actual bits. Which is
> simply *wrong*. Always has been.
>=20
> It's stupid, it generates bad code (both from performance *and* from a
> correctness angle), and it has actually resulted in gcc having *extra*
> complexity because it keeps the bitfield data around much too late.
>=20
> > The other problem is specification. =A0While you think that the code you
> > wrote is totally obvious it might not actually be so. =A0For instance, =
what
> > about this struct:
> >
> > {long l:32; int i1:16; short s; int i2:1; char c:7; short s2:8; short s=
3;}
> >
> > What are the obviously correct accesses for various writes into this
> > struct?
>=20
> I really don't think that example matters. You should instead turn the
> question around, and look at the real code examples, make *those*
> generate good and obviously correct code, and then *after* you've done
> that, you start looking at the mixed case where people do odd things.

Well, it matters because it shows that simply using the declared type
isn't going to work in the end.  What we instead need to do is
remember the underlying objects the bitfield packing algorithm uses.
It then simply becomes obvious how to implement the bitfield accesses.
I hope to get back to this for GCC 4.8.

> Quite frankly, the layout that makes *sense* for something like the
> above is not to pack them. You'd just do

Heh, but of course the ABI specifies they are supposed to be packed ...

In the end we all agree GCC does something nasty (and I would call
it a bug even), but any solution we find in GCC won't be backportable
to earlier releases so you have to deal with the GCC bug for quite
some time and devise workarounds in the kernel.  You'll hit the
bug for all structure fields that share the largest aligned
machine word with a bitfield (thus the size depends on the alignment
of the full object, not that of the struct containing the bitfield
in case that struct is nested inside another more aligned one).
This situation should be easily(?) detectable with sparse.

Thanks,
Richard.
--8323584-292295540-1328175335=:4999--
