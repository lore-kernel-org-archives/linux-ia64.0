From: John Levon <levon@movementarian.org>
Date: Mon, 13 Oct 2003 15:21:13 +0000
Subject: Re: [PATCH] select EFI partition support by default
Message-Id: <marc-linux-ia64-106605860230567@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106588409310269@msgid-missing>
In-Reply-To: <marc-linux-ia64-106588409310269@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Mon, Oct 13, 2003 at 10:00:47AM +0100, Christoph Hellwig wrote:

> > > +=A0=A0=A0=A0=A0=A0 bool "EFI GUID Partition support" if PARTITION_AD=
VANCED
> > > +=A0=A0=A0=A0=A0=A0 default y if !PARTITION_ADVANCED && IA64
> >=20
> > Can we make CONFIG_LBD force on CONFIG_EFI_PARTITION too then?
>=20
> I know the LBD backport is used with SGI disklabels in production
> enviroments.  In fact that's the only production use I know of at all...

Besides, unless I'm missing something, current 2.6 doesn't prompt for
LBD for IA64 at all ?

So, anybody want the patch :)

regards
john

--=20
Khendon's Law:
If the same point is made twice by the same person, the thread is over.
