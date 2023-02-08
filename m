From: Mark Brown <broonie@kernel.org>
Date: Wed, 08 Feb 2023 16:39:44 +0000
Subject: Re: [PATCH mm-unstable v1 04/26] arm/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE
Message-Id: <Y+PQUMwH4AZSVpjb@sirena.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="W0tQR/5xWRekS1hu"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230113171026.582290-1-david@redhat.com>
 <20230113171026.582290-5-david@redhat.com>
 <Y+GcDFMNHw2cdDN1@sirena.org.uk>
 <39fd91e3-c93b-23c6-afc6-cbe473bb0ca9@redhat.com>
In-Reply-To: <39fd91e3-c93b-23c6-afc6-cbe473bb0ca9@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Russell King <linux@armlinux.org.uk>


--W0tQR/5xWRekS1hu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 08, 2023 at 03:12:06PM +0100, David Hildenbrand wrote:
> On 07.02.23 01:32, Mark Brown wrote:

> > Today's -next (and at least back to Friday, older logs are unclear - I
> > only noticed -next issues today) fails to NFS boot on an AT91SAM9G20-EK
> > (an old ARMv5 platform) with multi_v5_defconfig, a bisect appears to
> > point to this patch (20aae9eff5acd8f5 in today's -next) as the culprit.

> It's been in -next for quite a while, thanks for the report!

Yeah, there's been some other things obscuring the issue.

> Could you give the following a test?
>=20
>=20
> From 8c4bdbd9862f85782d5919d044c172b584063e83 Mon Sep 17 00:00:00 2001
> From: David Hildenbrand <david@redhat.com>
> Date: Wed, 8 Feb 2023 15:08:01 +0100
> Subject: [PATCH] arm/mm: Fix swp type masking in __swp_entry()
>=20
> We're masking with the number of type bits instead of the type mask, which
> is obviously wrong.

Tested-by: Mark Brown <broonie@kernel.org>

but note that I had to manually apply it, though it's pretty trivial so
I probably applied the right thing.

--W0tQR/5xWRekS1hu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAmPj0FAACgkQJNaLcl1U
h9C7hQf/VKRwP16M1jInUqUdUtyzPdvalnHTpasxKVZ8Sy0U3jwXMqNUqmnpEOSO
UB3Q8audVEzRc8pj92dk3jilZBDPHyP58UUKRsjkrZVz22Q2/R16FcjaLrdlwNlj
GWMfEWv5OKYPHaxP4W/VX0sXzS0XMTuulvAF1BOQRlOAS3L3jYsYUtzI2pkzJm1G
64ICND0ZQRerzQmdQd6oO2tVhymhv8Y1LPY4TT0HikINGVpwwCJoOiocmstgqqGW
uE+M+XJ9Lp/p78SIjfccjF1rdCWlc5MJJLS/qZzYnm6OnkKMOlBAUX9bwqvyrvE9
quDK6fshhrFo/uJ5YVAQnAEuDKLv9g==
=rC9E
-----END PGP SIGNATURE-----

--W0tQR/5xWRekS1hu--
