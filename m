From: Daniel Thompson <daniel.thompson@linaro.org>
Date: Mon, 28 Mar 2022 13:17:33 +0000
Subject: Re: [PATCH 01/22] orion5x: Replace comments with C99 initializers
Message-Id: <20220328131733.akhkwnldtldp7nyn@maple.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-1-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Benjamin =?utf-8?B?U3TDvHJ6?= <benni@stuerz.xyz>
Cc: andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On Sat, Mar 26, 2022 at 05:58:48PM +0100, Benjamin St=FCrz wrote:
> This replaces comments with C99's designated
> initializers because the kernel supports them now.

This commit description seems wrong to me. This patch doesn't include
use C99 designated initializers (or AFAICT any other language feature
that has recently been enabled in the kernel).

The changes here are just plain constant-expressions in enumeration
lists and were included in C89/C90.


Daniel.


>=20
> Signed-off-by: Benjamin St=FCrz <benni@stuerz.xyz>
> ---
>  arch/arm/mach-orion5x/dns323-setup.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/arch/arm/mach-orion5x/dns323-setup.c b/arch/arm/mach-orion5x=
/dns323-setup.c
> index 87cb47220e82..d762248c6512 100644
> --- a/arch/arm/mach-orion5x/dns323-setup.c
> +++ b/arch/arm/mach-orion5x/dns323-setup.c
> @@ -61,9 +61,9 @@
> =20
>  /* Exposed to userspace, do not change */
>  enum {
> -	DNS323_REV_A1,	/* 0 */
> -	DNS323_REV_B1,	/* 1 */
> -	DNS323_REV_C1,	/* 2 */
> +	DNS323_REV_A1 =3D 0,
> +	DNS323_REV_B1 =3D 1,
> +	DNS323_REV_C1 =3D 2,
>  };
> =20
> =20
> --=20
> 2.35.1
>=20
