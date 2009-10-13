From: spender@grsecurity.net (Brad Spengler)
Date: Tue, 13 Oct 2009 04:58:08 +0000
Subject: Re: [PATCH] ia64: Don't call SAL < 3.2 for extended config space
Message-Id: <20091013045808.GB9782@grsecurity.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="XF85m9dhOBO43t/C"
List-Id: <linux-ia64.vger.kernel.org>
References: <20091011074531.GA12357@grsecurity.net> <4AD1AE0D.1030007@kernel.org> <4AD24766.7050205@kernel.org> <20091011213245.GC18513@grsecurity.net> <20091011231039.GB7545@parisc-linux.org> <20091012135628.GA310@grsecurity.net> <20091012142430.GE7545@parisc-linux.org>
In-Reply-To: <20091012142430.GE7545@parisc-linux.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Yinghai Lu <yinghai@kernel.org>, Jesse Barnes <jbarnes@virtuousgeek.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org


--XF85m9dhOBO43t/C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I've confirmed that the below patch (with the syntax fixes already=20
mentioned) resolves the issue on the SGI 750.

-Brad

> From: Matthew Wilcox <willy@linux.intel.com>
> Subject: Require SAL 3.2 in order to do extended config space ops
>=20
> We had assumed that SAL firmware would return an error if it didn't
> understand extended config space.  Unfortunately, the SAL on the SGI 750
> doesn't do that, it panics the machine.  So, condition the extended PCI
> config space accesses on SAL revision 3.2.
>=20
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
>=20
> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
> index 7de76dd..61363cc 100644
> --- a/arch/ia64/pci/pci.c
> +++ b/arch/ia64/pci/pci.c
> @@ -56,10 +56,13 @@ int raw_pci_read(unsigned int seg, unsigned int bus, =
unsigned int devfn,
>  	if ((seg | reg) <=3D 255) {
>  		addr =3D PCI_SAL_ADDRESS(seg, bus, devfn, reg);
>  		mode =3D 0;
> -	} else {
> +	} else if (sal_revision >=3D SAL_VERSION_CODE(3,2))
>  		addr =3D PCI_SAL_EXT_ADDRESS(seg, bus, devfn, reg);
>  		mode =3D 1;
> +	} else {
> +		return -EINVAL;
>  	}
> +
>  	result =3D ia64_sal_pci_config_read(addr, mode, len, &data);
>  	if (result !=3D 0)
>  		return -EINVAL;
> @@ -80,9 +83,11 @@ int raw_pci_write(unsigned int seg, unsigned int bus, =
unsigned int devfn,
>  	if ((seg | reg) <=3D 255) {
>  		addr =3D PCI_SAL_ADDRESS(seg, bus, devfn, reg);
>  		mode =3D 0;
> -	} else {
> +	} else if (sal_revision >=3D SAL_VERSION_CODE(3,2))
>  		addr =3D PCI_SAL_EXT_ADDRESS(seg, bus, devfn, reg);
>  		mode =3D 1;
> +	} else {
> +		return -EINVAL;
>  	}
>  	result =3D ia64_sal_pci_config_write(addr, mode, len, value);
>  	if (result !=3D 0)
>=20
> --=20
> Matthew Wilcox				Intel Open Source Technology Centre
> "Bill, look, we understand that you're interested in selling us this
> operating system, but compare it to ours.  We can't possibly take such
> a retrograde step."

--XF85m9dhOBO43t/C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFK1AjfmHm2SUJF1GoRAkvLAJ41aysysnsmrxh+dszx6/S/c7tthgCfcwpr
iLjMADqFkyGTgv2KFfLNT6U=
=2UdH
-----END PGP SIGNATURE-----

--XF85m9dhOBO43t/C--
