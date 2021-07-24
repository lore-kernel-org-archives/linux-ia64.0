From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Date: Sat, 24 Jul 2021 06:22:28 +0000
Subject: Re: [PATCH v2 21/21] dma-mapping: Disallow .map_sg operations from returning zero on error
Message-Id: <2591613.mvXUDI8C0e@daneel.sf-tec.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart11795432.O9o76ZdvQC"
List-Id: <linux-ia64.vger.kernel.org>
References: <20210723175008.22410-1-logang@deltatee.com> <20210723175008.22410-22-logang@deltatee.com>
In-Reply-To: <20210723175008.22410-22-logang@deltatee.com>
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, Logan Gunthorpe <logang@deltatee.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>

--nextPart11795432.O9o76ZdvQC
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Am Freitag, 23. Juli 2021, 19:50:08 CEST schrieb Logan Gunthorpe:
> Now that all the .map_sg operations have been converted to returning
> proper error codes, drop the code to handle a zero return value,
> add a warning if a zero is returned and update the comment for the
> map_sg operation.

I see no comment being touched here.

Eike
--nextPart11795432.O9o76ZdvQC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iF0EABECAB0WIQSaYVDeqwKa3fTXNeNcpIk+abn8TgUCYPuxpAAKCRBcpIk+abn8
TmEXAJ4y9fSVV7pgh2KPWXQ4YaTcwXP08ACgkfbFqKsGtxv2IZPJJiPcxo/F4Bg=
=swGr
-----END PGP SIGNATURE-----

--nextPart11795432.O9o76ZdvQC--


