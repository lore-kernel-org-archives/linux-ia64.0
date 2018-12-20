From: Thierry Reding <thierry.reding@gmail.com>
Date: Thu, 20 Dec 2018 16:44:18 +0000
Subject: Re: [PATCH 15/15] dma-mapping: bypass indirect calls for dma-direct
Message-Id: <20181220164418.GA18777@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
 <20181207190720.18517-16-hch@lst.de>
In-Reply-To: <20181207190720.18517-16-hch@lst.de>
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?utf-8?Q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 07, 2018 at 11:07:20AM -0800, Christoph Hellwig wrote:
[...]
> diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
> index 0b18cfbdde95..fc84c81029d9 100644
> --- a/kernel/dma/mapping.c
> +++ b/kernel/dma/mapping.c
[...]
> @@ -397,9 +404,9 @@ int dma_supported(struct device *dev, u64 mask)
>  {
>  	const struct dma_map_ops *ops =3D get_dma_ops(dev);
> =20
> -	if (!ops)
> -		return 0;
> -	if (!ops->dma_supported)
> +	if (dma_is_direct(ops))
> +		return dma_direct_supported(dev, mask);
> +	if (ops->dma_supported)
>  		return 1;
>  	return ops->dma_supported(dev, mask);
>  }

Hi Christoph,

This hunk causes a crash on boot for me. It looks like a ! got lost in
the rework here. The following patch fixes the crash for me and restores
the logic of the op->dma_supported check.

Feel free to squash this patch into the above if you prefer that.

Thierry

--- >8 ---
=46rom c502b29ab01fa857e81c78cd574d4d22d7d20e09 Mon Sep 17 00:00:00 2001
=46rom: Thierry Reding <treding@nvidia.com>
Date: Thu, 20 Dec 2018 17:35:47 +0100
Subject: [PATCH] dma-mapping: Fix inverted logic in dma_supported()

The cleanup in commit 356da6d0cde3 ("dma-mapping: bypass indirect calls
for dma-direct") accidentally inverted the logic in the check for the
presence of a ->dma_supported() callback. Switch this back to the way it
was to prevent a crash on boot.

Fixes: 356da6d0cde3 ("dma-mapping: bypass indirect calls for dma-direct")
Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 kernel/dma/mapping.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
index fc84c81029d9..d7c34d2d1ba5 100644
--- a/kernel/dma/mapping.c
+++ b/kernel/dma/mapping.c
@@ -406,7 +406,7 @@ int dma_supported(struct device *dev, u64 mask)
=20
 	if (dma_is_direct(ops))
 		return dma_direct_supported(dev, mask);
-	if (ops->dma_supported)
+	if (!ops->dma_supported)
 		return 1;
 	return ops->dma_supported(dev, mask);
 }
--=20
2.19.1

--G4iJoqBmSsgzjUCe
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAlwbxuAACgkQ3SOs138+
s6FOFBAAvk7KvF523TFilLtTgdqzgtbG0su3+Q9/rfoojbuGfvhM5uVjTT8i/Brp
4yx6kTZg7EbcIyiPhY4YN6MKtxFIQO4xRuCAnsiEG2XzwLKct0bmqf39UOMjRCiL
QgdUBn7wdWKH4gMLwHs9jupvvw6AWkDUF+d7s9/idZIy5+KGXeCYq6qgcRFhitXd
fOF4iBMnK49WcDhwRCBYieTE99Mb01ILjFOtdBFjnB4xnf3GyWs5uriDDwGdrurI
ASrZABnhANLKYYInPA61xDqpudGlydOTa+7BtIvDMVr1CGcRYpZ0ERknioCdQQQE
XoO6taGR2vfwIOm+frEvuIVNOBEUO7NNRFHfMaVWU3oEjQ5NNhzcp3t+EyxL+jTT
0zxaX2H3b9w703yxWo8/fvEwdyuBGbTYA7cmtCgoTo8QHRt2BhxBaE1X/n5wLDYW
Giu06kdfZQAks6U+YAogHzy7imPUpDYIZuH2Tko3Sw710nIF1et6j2zPrQmYO2nu
1i/orBSibV/5P1Y9DRVNztY56l9oDv7cOVmFeJWXtQXBz8OdYjyHIKI6KhDi1sQK
W/nqPzW9uvCC4KeTWDGaw90BChgtWyKy6rEhPdk1QpQnMQYerr+a0y4Za905TqlU
mgI8M4YFd34Cr424HZuguZ6NtgUACys5BnYqjMLUTfl/LK3lcW8=
=t2Tu
-----END PGP SIGNATURE-----

--G4iJoqBmSsgzjUCe--
