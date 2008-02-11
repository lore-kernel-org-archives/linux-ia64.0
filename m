From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 11 Feb 2008 07:37:03 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <1202715423.9594.14.camel@elijah.suse.cz>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-bL7QQ7XNxZ9atY3LS/Qs"
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
To: linux-ia64@vger.kernel.org


--=-bL7QQ7XNxZ9atY3LS/Qs
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Christoph Hellwig p=C3=AD=C5=A1e v So 09. 02. 2008 v 00:04 -0500:
> On Fri, Feb 08, 2008 at 02:46:25PM -0800, Luck, Tony wrote:
> > Petr Tesarik (3):
> >       [IA64] Rename TIF_PERFMON_WORK back to TIF_NOTIFY_RESUME
> >       [IA64] Synchronize kernel RSE to user-space and back
> >       [IA64] Synchronize RBS on PTRACE_ATTACH
>=20
> This is still not killing the now unessecary find_thread_for_addr gunk
> and the conversion to arch_ptrace.    Any reason that got delayed again?
> Currently ia64 is one out of two architectures left still having it's
> own sys_ptrace.

No, it's on my TODO-list. Incidentally, I can continue work here again
this week. :)

Petr Tesarik


--=-bL7QQ7XNxZ9atY3LS/Qs
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Toto je =?iso-8859-2?Q?digit=E1ln=EC?=
	=?ISO-8859-1?Q?_podepsan=E1?= =?iso-8859-2?Q?_=E8=E1st?=
	=?ISO-8859-1?Q?_zpr=E1vy?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBHr/sfjpY2ODFi2ogRAqTSAJ9oLrVY6+M2Bz86R2eubKVq8JVYaQCcCSew
Ogbe6noWwhFIx1tKCMvbeC4=
=IyN9
-----END PGP SIGNATURE-----

--=-bL7QQ7XNxZ9atY3LS/Qs--
