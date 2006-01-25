From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 25 Jan 2006 22:49:05 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060125153816.F16092@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, 25 Jan 2006, Chen, Kenneth W wrote:

> Brent Casavant wrote on Wednesday, January 25, 2006 9:04 AM
>=20
> > Also, yesterday when I moved the platform_migrate() call after
> > __switch_task() (actually, after ia64_switch_to()) I would receive
> > kernel panics during boot (the migration threads would die from an
> > invalid access, swapper shortly thereafter, and finally a "soft
> lockup"
> > on swapper).  Was I perhaps missing something?
>=20
> I can't immediately see why it won't work on sn2.  It works for me
> on a Intel tiger ia64 machine.

Hmm.  I have only scant evidence to go on from the panic output,
but it looks like "current" (r13) is not equal to the value of "next"
by the time we get into sn_migrate().  One example run apparently
has current=E0000030079d8000, next=E000003015990000.

While this shouldn't cause a problem as long as "next" is valid,
it is unexpected and makes me wonder if my understanding of the
code is correct.  Unfortunately using SGI's simulator sheds no
light on the situation, as the code doesn't fail there.

Also loading cpu and last_cpu from next->thread_info for the migration/1
thread, I see ASCII data in the lower 32 bits.  So either the data in
next->thread_info is invalid, or "next" itself is invalid.  This gets
us into trouble when pdacpu() is called (or maybe when we dereference
the result).

Still staring at it...

Brent

--=20
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
