From: Arjan van de Ven <arjanv@redhat.com>
Date: Thu, 06 May 2004 12:18:24 +0000
Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <1083845904.3844.2.camel@laptop.fenrus.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-DWk91SIcPBHtFP7OtNPg"
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
	 <20040506114414.A14543@infradead.org>
	 <20040506115919.GZ2281@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040506115919.GZ2281@parcelfarce.linux.theplanet.co.uk>
To: Matthew Wilcox <willy@debian.org>
Cc: Christoph Hellwig <hch@infradead.org>, Sourav Sen <souravs@india.hp.com>, Matt_Domsch@dell.com, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


--=-DWk91SIcPBHtFP7OtNPg
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-05-06 at 13:59, Matthew Wilcox wrote:
> On Thu, May 06, 2004 at 11:44:14AM +0100, Christoph Hellwig wrote:
> > On Thu, May 06, 2004 at 02:22:46PM +0530, Sourav Sen wrote:
> > > Hi,
> > >=20
> > > The following simple patch creates a read-only file
> > > "memmap" under <mount point>/firmware/efi/ in sysfs
> > > and exposes the efi memory map thru it.
> >=20
> > doesn't exactly fit into the one value per file approach, does it?
>=20
> It's not exactly modifiable.=20

come on, it's the ideal hotplug memory interface ;)
should we try to unify the memory map exports between architectures
instead of matching the firmware-of-the-day for each architecture ??


--=-DWk91SIcPBHtFP7OtNPg
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAmi0PxULwo51rQBIRAqbCAJ9C12H6pTCO+gt2IxF+DJ+LZj3NywCgnLdO
fDAMqM95/kUeLPXyqUYb97Y=
=EC3X
-----END PGP SIGNATURE-----

--=-DWk91SIcPBHtFP7OtNPg--

