From: Christoph Rohland <cr@sap.com>
Date: Wed, 24 May 2000 09:52:38 +0000
Subject: Re: [Linux-ia64] ld failure
Message-Id: <marc-linux-ia64-105590678205106@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205047@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205047@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Christoph Rohland <cr@sap.com> writes:

> Uros Prestor <uros@turbolinux.com> writes:
>=20
> > Christoph Rohland wrote:
> >=20
> > > This problem is solved with the new gnupro toolkit included on TL
> > > 0505. (Of course I get now an =EDllegal instruction'when running the
> > > executable due to the missing brl emulation in the kernel.)
> >=20
> > Try the new kernel RPM available on our update site:
> >=20
> >      ftp://ftp.turbolinux.com/pub/ia64/0505/updates/RPMS/ia64/kernel-2.=
3.99-19.ia64.rpm
>=20
> This now does not generate an ill instruction, but a seg fault in:

We now have the latest glibc, gnupro and kernel from tl-updates and it
works!

Thanks
		Christoph

--=20


