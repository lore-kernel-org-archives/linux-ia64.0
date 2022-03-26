From: Joe Perches <joe@perches.com>
Date: Sat, 26 Mar 2022 19:44:26 +0000
Subject: Re: [PATCH 02/22] s3c: Replace comments with C99 initializers
Message-Id: <0441a5ec999492a8b03df0e6f649b19483006cbc.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
         <20220326165909.506926-2-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-2-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Benjamin =?ISO-8859-1?Q?St=FCrz?= <benni@stuerz.xyz>, andrew@lunn.ch
Cc: sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On Sat, 2022-03-26 at 17:58 +0100, Benjamin St=FCrz wrote:
> This replaces comments with C99's designated
> initializers because the kernel supports them now.
[]
> diff --git a/arch/arm/mach-s3c/bast-irq.c b/arch/arm/mach-s3c/bast-irq.c
[]
> @@ -29,22 +29,22 @@
>   * the irq is not implemented
>  */
>  static const unsigned char bast_pc104_irqmasks[] =3D {
> -	0,   /* 0 */
> -	0,   /* 1 */
> -	0,   /* 2 */
> -	1,   /* 3 */
> -	0,   /* 4 */
> -	2,   /* 5 */
> -	0,   /* 6 */
> -	4,   /* 7 */
> -	0,   /* 8 */
> -	0,   /* 9 */
> -	8,   /* 10 */
> -	0,   /* 11 */
> -	0,   /* 12 */
> -	0,   /* 13 */
> -	0,   /* 14 */
> -	0,   /* 15 */
> +	[0]  =3D 0,
> +	[1]  =3D 0,
> +	[2]  =3D 0,
> +	[3]  =3D 1,
> +	[4]  =3D 0,
> +	[5]  =3D 2,
> +	[6]  =3D 0,
> +	[7]  =3D 4,
> +	[8]  =3D 0,
> +	[9]  =3D 0,
> +	[10] =3D 8,
> +	[11] =3D 0,
> +	[12] =3D 0,
> +	[13] =3D 0,
> +	[14] =3D 0,
> +	[15] =3D 0,
>  };

I don't find this better than the initial array.

> =20
>  static const unsigned char bast_pc104_irqs[] =3D { 3, 5, 7, 10 };

For the same reason this array is just an array
without the specified indexing.

