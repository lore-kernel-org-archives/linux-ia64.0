From: Francis Galiegue <fg@mandrakesoft.com>
Date: Thu, 01 Mar 2001 18:15:26 +0000
Subject: Re: [Linux-ia64] more problems with 2001-02-28 kit (can't build
Message-Id: <marc-linux-ia64-105590693005232@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005227@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005227@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, 1 Mar 2001, John Kohl wrote:

>=20
> I ran into more build problems with the 2001-02-28 patch kit.  I can't
> build a non-SMP kernel.
>=20
> One bug I can fix, the other I'm not sure what the right thing to do is.
>=20
Uh, I've submitted a patch which solves both of these problems (in fact, the
first part is exactly the same as yours, indeed) but it hasn't reached the =
list
for some reason...

>=20
> This, I'm not sure what to do--should IPI-related stuff even be compiled =
when
> CONFIG_SMP is not set?
>=20

Normally no, IPI is not needed on UP.

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


