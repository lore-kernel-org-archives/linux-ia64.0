From: Francis Galiegue <fg@mandrakesoft.com>
Date: Mon, 26 Feb 2001 17:03:33 +0000
Subject: Re: [Linux-ia64] Re: 2.4.1 + 010131 patch: sys_nanosleep sleeps...
Message-Id: <marc-linux-ia64-105590693005206@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005205@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005205@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Mon, 26 Feb 2001, Bill Nottingham wrote:

>=20
> Jack Steiner (steiner@sgi.com) said:=20
> > We have also been seeing hangs running with the latest BIOS. The problem
> > was isolated to a tiny window in arch/ia64/kernel/time.c where
> > itm could get loaded with a value that is in the past.
>=20
> I've certainly seen references to time going in the past recently;
> the error messages are usually from ping.
>=20

Yep, seen those too. Now they don't show up anymore.

First impression about the patch: terrific! Not only does sleep work fine, =
but
it also cures the hangs I had on heavy I/O.

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


