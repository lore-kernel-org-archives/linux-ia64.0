From: Daniel Thompson <daniel.thompson@linaro.org>
Date: Mon, 28 Mar 2022 13:37:43 +0000
Subject: Re: [PATCH 02/22] s3c: Replace comments with C99 initializers
Message-Id: <20220328133743.xhdzmprlc7a6jxxy@maple.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
 <20220326165909.506926-2-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-2-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Benjamin =?utf-8?B?U3TDvHJ6?= <benni@stuerz.xyz>
Cc: andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On Sat, Mar 26, 2022 at 05:58:49PM +0100, Benjamin St=FCrz wrote:
> This replaces comments with C99's designated
> initializers because the kernel supports them now.

I'm a bit puzzled by "because the kernel supports them now". Designated
initializers are not purely a C99 feature... it is also a GNU C extension
to C89. This language feature has been used by the kernel for a very long t=
ime
(well over a decade).

On other words it would be much more effective to advocate for the
change by saying "because the code is clearer and easier to read" rather
than "because we can".


> Signed-off-by: Benjamin St=FCrz <benni@stuerz.xyz>
> ---
>  arch/arm/mach-s3c/bast-irq.c | 32 ++++++++++++++++----------------
>  1 file changed, 16 insertions(+), 16 deletions(-)
>=20
> diff --git a/arch/arm/mach-s3c/bast-irq.c b/arch/arm/mach-s3c/bast-irq.c
> index d299f124e6dc..bd5471f9973b 100644
> --- a/arch/arm/mach-s3c/bast-irq.c
> +++ b/arch/arm/mach-s3c/bast-irq.c
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

Shouldn't this just be as follows (in order to match bast_pc104_irqs)?

+static const unsigned char bast_pc104_irqmasks[16] =3D {
+	[3]  =3D 1,
+	[5]  =3D 2,
+	[7]  =3D 4,
+	[10] =3D 8,
 };
=20
 static const unsigned char bast_pc104_irqs[] =3D { 3, 5, 7, 10 };


Daniel.
