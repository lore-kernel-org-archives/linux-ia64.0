From: Jakub Jelinek <jakub@redhat.com>
Date: Wed, 01 Feb 2012 20:16:32 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <20120201201631.GW18768@tyan-ft48-01.lab.bos.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb>
 <20120201194025.GG6148@sunsite.ms.mff.cuni.cz>
 <CA+55aFzVWjqcs1zRF-93_9yHRDS-YgmpgFTzACw6HQ-059U06Q@mail.gmail.com>
In-Reply-To: <CA+55aFzVWjqcs1zRF-93_9yHRDS-YgmpgFTzACw6HQ-059U06Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 01, 2012 at 12:01:46PM -0800, Linus Torvalds wrote:
> On Wed, Feb 1, 2012 at 11:40 AM, Jakub Jelinek <jakub@redhat.com> wrote:
> > struct S { long s1; unsigned int s2 : 5; unsigned int s3 : 19; unsigned=
 char s4; unsigned int s5; };
> > struct T { long t1 : 16; unsigned int t2; };
> >
> > on e.g. x86_64-linux, S is 16 byte long, field s4 is packed together in=
to
> > the same 32 bits as s2 and s3. =A0While the memory model allows s2 to be
> > changed when storing s3 (i.e. use a RMW cycle on it), it doesn't allow =
s4
> > to be changed, as it isn't a bitfield (you'd need s4 : 8 for that).
> > T is 8 bytes long, again, s2 is packed into the same 64 bits as s1,
> > and the memory model doesn't allow s2 to be modified.
> >
> > Not sure what the kernel would expect in such a case.
>=20
> So the kernel really doesn't care what you do to things *within* the bitf=
ield.

But what is *within* the bitfield?  Do you consider s4 or t2 fields
(non-bitfield fields that just the ABI wants to pack together with
the bitfield) above as *within* or is already modifying of those a problem?

> The 'volatile'  example makes it entirely clear that the bug has
> nothing what-so-ever to do with C11.

The reason we mention C11/C++11 memory model is because we plan to support
that, likely for GCC 4.8, when requested by some options (either by default
when choosing those standards?, or when explicitly requested).  This will
even disable some optimizations that are fine for single-threaded apps,
but aren't fine in those memory models, aren't fine in OpenMP or for many
other threaded programs.  E.g. loop store motion if it isn't guaranteed the
variable is always stored in the loop:
int x;

void
foo (int j)
{
  int i;
  for (i =3D 0; i < 100000; i++)
    if (i > j)
      x =3D i;
}
can't be performed, because otherwise it introduces a tmp =3D x; ... x =3D =
tmp;
into code that wouldn't otherwise touch the variable, so if some other
thread modifies x, it might have unexpected value.

	Jakub
