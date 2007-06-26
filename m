From: Michael Ellerman <michael@ellerman.id.au>
Date: Tue, 26 Jun 2007 02:06:46 +0000
Subject: Re: [PATCH 3/3] Make jprobes a little safer for users
Message-Id: <1182823606.6673.1.camel@concordia.ozlabs.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-KyjEHQpPkznzha+9hND4"
List-Id: <linux-ia64.vger.kernel.org>
References: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au>
	 <7a070581b2fe53ea65216e86c86abc4f40464341.1182822366.git.michael@ellerman.id.au>
	 <20070625190057.c8dcb110.akpm@linux-foundation.org>
In-Reply-To: <20070625190057.c8dcb110.akpm@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, Christoph Hellwig <hch@lst.de>, anil.s.keshavamurthy@intel.com, ananth@in.ibm.com


--=-KyjEHQpPkznzha+9hND4
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-06-25 at 19:00 -0700, Andrew Morton wrote:
> On Tue, 26 Jun 2007 11:48:51 +1000 (EST) Michael Ellerman <michael@ellerm=
an.id.au> wrote:
>=20
> > I realise jprobes are a razor-blades-included type of interface, but
> > that doesn't mean we can't try and make them safer to use. This guy I
> > know once wrote code like this:
> >=20
> > struct jprobe jp =3D { .kp.symbol_name =3D "foo", .entry =3D "jprobe_fo=
o" };
> >=20
> > And then his kernel exploded. Oops.
> >=20
> > This patch adds an arch hook, arch_deref_entry_point() (I don't like it=
 either)
> > which takes the void * in a struct jprobe, and gives back the text addr=
ess
> > that it represents.
> >=20
> > We can then use that in register_jprobe() to check that the entry point
> > we're passed is actually in the kernel text, rather than just some rand=
om
> > value.
> >=20
> > Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
> > ---
> >  arch/ia64/kernel/kprobes.c    |    7 ++++++-
> >  arch/powerpc/kernel/kprobes.c |   11 ++++++++---
> >  kernel/kprobes.c              |    9 +++++++++
>=20
> We're missing a declaration of arch_deref_entry_point() in some header fi=
le?

Yeah I guess. It's declared weak in kernel/kprobes.c, but there should
be a definition somewhere to make sure the three versions don't get out
of sync. I'll send a patch.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-KyjEHQpPkznzha+9hND4
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGgHS2dSjSd0sB4dIRAkojAJ4tr2mPuEsr5ZO0m1JfAbm0aS2n0gCgpezg
vpaDZAvWChFhLvbzJ01LVdk=
=doSd
-----END PGP SIGNATURE-----

--=-KyjEHQpPkznzha+9hND4--

