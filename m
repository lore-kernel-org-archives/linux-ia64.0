From: Leon Romanovsky <leon@kernel.org>
Date: Sun, 27 Mar 2022 07:04:54 +0000
Subject: Re: [PATCH 11/22] rdmavt: Replace comments with C99 initializers
Message-Id: <YkAMlurdV15gNROq@unreal>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
 <20220326165909.506926-11-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-11-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Benjamin =?iso-8859-1?Q?St=FCrz?= <benni@stuerz.xyz>
Cc: andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On Sat, Mar 26, 2022 at 05:58:58PM +0100, Benjamin St=FCrz wrote:
> This replaces comments with C99's designated
> initializers because the kernel supports them now.
>=20
> Signed-off-by: Benjamin St=FCrz <benni@stuerz.xyz>
> ---
>  drivers/infiniband/sw/rdmavt/rc.c | 62 +++++++++++++++----------------
>  1 file changed, 31 insertions(+), 31 deletions(-)
>=20
> diff --git a/drivers/infiniband/sw/rdmavt/rc.c b/drivers/infiniband/sw/rd=
mavt/rc.c
> index 4e5d4a27633c..121b8a23ac07 100644
> --- a/drivers/infiniband/sw/rdmavt/rc.c
> +++ b/drivers/infiniband/sw/rdmavt/rc.c
> @@ -10,37 +10,37 @@
>   * Convert the AETH credit code into the number of credits.
>   */
>  static const u16 credit_table[31] =3D {
> -	0,                      /* 0 */
> -	1,                      /* 1 */
> -	2,                      /* 2 */
> -	3,                      /* 3 */
> -	4,                      /* 4 */
> -	6,                      /* 5 */
> -	8,                      /* 6 */
> -	12,                     /* 7 */
> -	16,                     /* 8 */
> -	24,                     /* 9 */
> -	32,                     /* A */
> -	48,                     /* B */
> -	64,                     /* C */
> -	96,                     /* D */
> -	128,                    /* E */
> -	192,                    /* F */
> -	256,                    /* 10 */
> -	384,                    /* 11 */
> -	512,                    /* 12 */
> -	768,                    /* 13 */
> -	1024,                   /* 14 */
> -	1536,                   /* 15 */
> -	2048,                   /* 16 */
> -	3072,                   /* 17 */
> -	4096,                   /* 18 */
> -	6144,                   /* 19 */
> -	8192,                   /* 1A */
> -	12288,                  /* 1B */
> -	16384,                  /* 1C */
> -	24576,                  /* 1D */
> -	32768                   /* 1E */
> +	[0x00] =3D 0,
> +	[0x01] =3D 1,
> +	[0x02] =3D 2,
> +	[0x03] =3D 3,
> +	[0x04] =3D 4,
> +	[0x05] =3D 6,
> +	[0x06] =3D 8,
> +	[0x07] =3D 12,
> +	[0x08] =3D 16,
> +	[0x09] =3D 24,
> +	[0x0A] =3D 32,
> +	[0x0B] =3D 48,
> +	[0x0C] =3D 64,
> +	[0x0D] =3D 96,
> +	[0x0E] =3D 128,
> +	[0x0F] =3D 192,
> +	[0x10] =3D 256,
> +	[0x11] =3D 384,
> +	[0x12] =3D 512,
> +	[0x13] =3D 768,
> +	[0x14] =3D 1024,
> +	[0x15] =3D 1536,
> +	[0x16] =3D 2048,
> +	[0x17] =3D 3072,
> +	[0x18] =3D 4096,
> +	[0x19] =3D 6144,
> +	[0x1A] =3D 8192,
> +	[0x1B] =3D 12288,
> +	[0x1C] =3D 16384,
> +	[0x1D] =3D 24576,
> +	[0x1E] =3D 32768
>  };

I have hard time to see any value in this commit, why is this change needed?

Thanks

> =20
>  /**
> --=20
> 2.35.1
>=20
>=20
