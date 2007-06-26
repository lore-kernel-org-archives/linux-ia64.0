From: Michael Ellerman <michael@ellerman.id.au>
Date: Tue, 26 Jun 2007 04:35:49 +0000
Subject: Re: [PATCH 1/3] Make struct jprobe.entry a void *
Message-Id: <1182832549.6673.12.camel@concordia.ozlabs.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-C/Og7AIUR51gZzP8MZdc"
List-Id: <linux-ia64.vger.kernel.org>
References: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au>
	 <20070626035946.GA20460@in.ibm.com>
In-Reply-To: <20070626035946.GA20460@in.ibm.com>
To: ananth@in.ibm.com
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, anil.s.keshavamurthy@intel.com


--=-C/Og7AIUR51gZzP8MZdc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-06-26 at 09:29 +0530, Ananth N Mavinakayanahalli wrote:
> On Tue, Jun 26, 2007 at 11:48:50AM +1000, Michael Ellerman wrote:
> > ---
> >=20
> > It isn't obvious where kprobes patches should go, is anyone "the" maint=
ainer?
> > Instead I've just sent this to everyone who'd touched the code lately, =
or
> > might be otherwise interested.
>=20
> There isn't a single maintainer for the kprobes infrastructure as it
> contains quite a bit of low level arch specific code. The working model
> currently is that the patches are sent to lkml with a cc to the
> maintainers listed, as you've rightly done.

OK, no worries. I guess that's a bit messy to put into a MAINTAINERS entry.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-C/Og7AIUR51gZzP8MZdc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGgJeldSjSd0sB4dIRAi1JAJ41iajk775QlaOZrIZPSjZAtmQdBgCeM3Do
rWeTXVQ4LoPg+2calMyjoQo=
=w/5W
-----END PGP SIGNATURE-----

--=-C/Og7AIUR51gZzP8MZdc--

