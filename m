From: Michal Simek <monstr@monstr.eu>
Date: Mon, 02 Sep 2019 14:19:08 +0000
Subject: Re: [PATCH 2/3] microblaze: remove ioremap_fullcache
Message-Id: <1e5e6ca9-3b09-df10-12e8-828d13590660@monstr.eu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="mfBAq2Hw8KEYFIQ59QLhb5U3IQWVJJCJo"
List-Id: <linux-ia64.vger.kernel.org>
References: <20190830161237.23033-1-hch@lst.de>
 <20190830161237.23033-3-hch@lst.de>
In-Reply-To: <20190830161237.23033-3-hch@lst.de>
To: Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-m68k@lists.linux-m68k.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mfBAq2Hw8KEYFIQ59QLhb5U3IQWVJJCJo
Content-Type: multipart/mixed; boundary="TsTbQ6Zq4dCF3p6vuwBULinZWnl3VOqZ2";
 protected-headers="v1"
From: Michal Simek <monstr@monstr.eu>
Reply-To: monstr@monstr.eu
To: Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>,
 Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-m68k@lists.linux-m68k.org, linux-ia64@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-ID: <1e5e6ca9-3b09-df10-12e8-828d13590660@monstr.eu>
Subject: Re: [PATCH 2/3] microblaze: remove ioremap_fullcache
References: <20190830161237.23033-1-hch@lst.de>
 <20190830161237.23033-3-hch@lst.de>
In-Reply-To: <20190830161237.23033-3-hch@lst.de>

--TsTbQ6Zq4dCF3p6vuwBULinZWnl3VOqZ2
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 30. 08. 19 18:12, Christoph Hellwig wrote:
> No callers of this function.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/microblaze/include/asm/io.h | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/arch/microblaze/include/asm/io.h b/arch/microblaze/include=
/asm/io.h
> index c7968139486f..86c95b2a1ce1 100644
> --- a/arch/microblaze/include/asm/io.h
> +++ b/arch/microblaze/include/asm/io.h
> @@ -40,7 +40,6 @@ extern void iounmap(volatile void __iomem *addr);
> =20
>  extern void __iomem *ioremap(phys_addr_t address, unsigned long size);=

>  #define ioremap_nocache(addr, size)		ioremap((addr), (size))
> -#define ioremap_fullcache(addr, size)		ioremap((addr), (size))
>  #define ioremap_wc(addr, size)			ioremap((addr), (size))
>  #define ioremap_wt(addr, size)			ioremap((addr), (size))
> =20
>=20

This single patch applied for v5.4 via microblaze tree.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Xilinx Microblaze
Maintainer of Linux kernel - Xilinx Zynq ARM and ZynqMP ARM64 SoCs
U-Boot custodian - Xilinx Microblaze/Zynq/ZynqMP/Versal SoCs



--TsTbQ6Zq4dCF3p6vuwBULinZWnl3VOqZ2--

--mfBAq2Hw8KEYFIQ59QLhb5U3IQWVJJCJo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQQbPNTMvXmYlBPRwx7KSWXLKUoMIQUCXW0k3AAKCRDKSWXLKUoM
Ic+tAJ4vGoKGabf+eZaw4Gche0V48YIrBACePFT26bcMWKEmEmc8Z6Bv5WH6EW0=
=rtJ9
-----END PGP SIGNATURE-----

--mfBAq2Hw8KEYFIQ59QLhb5U3IQWVJJCJo--
