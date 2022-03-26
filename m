From: Mauro Carvalho Chehab <mchehab@kernel.org>
Date: Sat, 26 Mar 2022 18:20:20 +0000
Subject: Re: [PATCH 01/22] orion5x: Replace comments with C99 initializers
Message-Id: <20220326192020.670e0b2f@coco.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-1-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Benjamin =?UTF-8?B?U3TDvHJ6?= <benni@stuerz.xyz>
Cc: andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

Em Sat, 26 Mar 2022 17:58:48 +0100
Benjamin Stürz <benni@stuerz.xyz> escreveu:

> This replaces comments with C99's designated
> initializers because the kernel supports them now.

Please:

1. Split this series per sub-system. It makes no sense to mailbomb all
   subsystems for things that won't belong there;

2. Add a patch 00 to the series, in order to make easier to do reviews
   like this that are meant to the series as a hole.

Regards,
Mauro
> 
> Signed-off-by: Benjamin Stürz <benni@stuerz.xyz>
> ---
>  arch/arm/mach-orion5x/dns323-setup.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm/mach-orion5x/dns323-setup.c b/arch/arm/mach-orion5x/dns323-setup.c
> index 87cb47220e82..d762248c6512 100644
> --- a/arch/arm/mach-orion5x/dns323-setup.c
> +++ b/arch/arm/mach-orion5x/dns323-setup.c
> @@ -61,9 +61,9 @@
>  
>  /* Exposed to userspace, do not change */
>  enum {
> -	DNS323_REV_A1,	/* 0 */
> -	DNS323_REV_B1,	/* 1 */
> -	DNS323_REV_C1,	/* 2 */
> +	DNS323_REV_A1 = 0,
> +	DNS323_REV_B1 = 1,
> +	DNS323_REV_C1 = 2,
>  };
>  
>  



Thanks,
Mauro
