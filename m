From: Michal Simek <monstr@monstr.eu>
Date: Mon, 02 Sep 2019 14:16:52 +0000
Subject: Re: [PATCH 03/26] m68k, microblaze: remove ioremap_fullcache
Message-Id: <9a11ddb0-0799-c64a-f5aa-0504c564998f@monstr.eu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="sxrD5DzuLHXmSTexCf4xoEovzaJstmsXm"
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de>
 <20190817073253.27819-4-hch@lst.de>
In-Reply-To: <20190817073253.27819-4-hch@lst.de>
To: Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org
Cc: linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, linux-mtd@lists.infradead.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, nios2-dev@lists.rocketboards.org, linux-riscv@lists.infradead.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sxrD5DzuLHXmSTexCf4xoEovzaJstmsXm
Content-Type: multipart/mixed; boundary="Gv98DqTDPDXpgdAS8uye8pnF1A8XQfxBm";
 protected-headers="v1"
From: Michal Simek <monstr@monstr.eu>
Reply-To: monstr@monstr.eu
To: Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>,
 Guo Ren <guoren@kernel.org>, Greentime Hu <green.hu@gmail.com>,
 Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>,
 x86@kernel.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org,
 linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org,
 linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org,
 linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org,
 openrisc@lists.librecores.org, linux-parisc@vger.kernel.org,
 linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org,
 linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Message-ID: <9a11ddb0-0799-c64a-f5aa-0504c564998f@monstr.eu>
Subject: Re: [PATCH 03/26] m68k, microblaze: remove ioremap_fullcache
References: <20190817073253.27819-1-hch@lst.de>
 <20190817073253.27819-4-hch@lst.de>
In-Reply-To: <20190817073253.27819-4-hch@lst.de>

--Gv98DqTDPDXpgdAS8uye8pnF1A8XQfxBm
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 17. 08. 19 9:32, Christoph Hellwig wrote:
> No callers of this function.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/m68k/include/asm/kmap.h     | 7 -------
>  arch/microblaze/include/asm/io.h | 1 -
>  2 files changed, 8 deletions(-)
>=20
> diff --git a/arch/m68k/include/asm/kmap.h b/arch/m68k/include/asm/kmap.=
h
> index aac7f045f7f0..03d904fe6087 100644
> --- a/arch/m68k/include/asm/kmap.h
> +++ b/arch/m68k/include/asm/kmap.h
> @@ -43,13 +43,6 @@ static inline void __iomem *ioremap_wt(unsigned long=
 physaddr,
>  	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
>  }
> =20
> -#define ioremap_fullcache ioremap_fullcache
> -static inline void __iomem *ioremap_fullcache(unsigned long physaddr,
> -					      unsigned long size)
> -{
> -	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
> -}
> -
>  #define memset_io memset_io
>  static inline void memset_io(volatile void __iomem *addr, unsigned cha=
r val,
>  			     int count)
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

Acked-by: Michal Simek <monstr@monstr.eu> (for Microblaze)

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Xilinx Microblaze
Maintainer of Linux kernel - Xilinx Zynq ARM and ZynqMP ARM64 SoCs
U-Boot custodian - Xilinx Microblaze/Zynq/ZynqMP/Versal SoCs



--Gv98DqTDPDXpgdAS8uye8pnF1A8XQfxBm--

--sxrD5DzuLHXmSTexCf4xoEovzaJstmsXm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQQbPNTMvXmYlBPRwx7KSWXLKUoMIQUCXW0kVQAKCRDKSWXLKUoM
IUCIAJ0dq35U3Gq44M2ocYgcj4SW3Em/1wCfajAs22UIYAGzwTZZyZTvB5OFi1I=
=essT
-----END PGP SIGNATURE-----

--sxrD5DzuLHXmSTexCf4xoEovzaJstmsXm--
