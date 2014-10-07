From: Lee Jones <lee.jones@linaro.org>
Date: Tue, 07 Oct 2014 08:00:48 +0000
Subject: Re: [PATCH 12/44] mfd: ab8500-sysctrl: Register with kernel poweroff handler
Message-Id: <20141007080048.GB25331@lee--X1>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-13-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-13-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, lguest@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-cris-kernel@axis.com, linux-efi@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-tegra@vger.kernel.org, linux-xtensa@linux-xtensa.org, openipmi-developer@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-pm@vger.kernel.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.orgLinusWalleij

On Mon, 06 Oct 2014, Guenter Roeck wrote:

> Register with kernel poweroff handler instead of setting pm_power_off
> directly. Register with a low priority value of 64 to reflect that
> the original code only sets pm_power_off if it was not already set.
>=20
> Cc: Linus Walleij <linus.walleij@linaro.org>
> Cc: Lee Jones <lee.jones@linaro.org>
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  drivers/mfd/ab8500-sysctrl.c | 26 +++++++++++++++-----------
>  1 file changed, 15 insertions(+), 11 deletions(-)
>=20
> diff --git a/drivers/mfd/ab8500-sysctrl.c b/drivers/mfd/ab8500-sysctrl.c
> index 8e0dae5..677438f 100644
> --- a/drivers/mfd/ab8500-sysctrl.c
> +++ b/drivers/mfd/ab8500-sysctrl.c
> @@ -6,6 +6,7 @@

[...]

> +static int ab8500_power_off(struct notifier_block *this, unsigned long u=
nused1,
> +			    void *unused2)
>  {
>  	sigset_t old;
>  	sigset_t all;
> @@ -34,11 +36,6 @@ static void ab8500_power_off(void)
>  	struct power_supply *psy;
>  	int ret;
> =20
> -	if (sysctrl_dev =3D NULL) {
> -		pr_err("%s: sysctrl not initialized\n", __func__);
> -		return;
> -	}

Can you explain the purpose of this change please?

>  	/*
>  	 * If we have a charger connected and we're powering off,
>  	 * reboot into charge-only mode.
> @@ -83,8 +80,15 @@ shutdown:
>  					 AB8500_STW4500CTRL1_SWRESET4500N);
>  		(void)sigprocmask(SIG_SETMASK, &old, NULL);
>  	}
> +
> +	return NOTIFY_DONE;
>  }

--=20
Lee Jones
Linaro STMicroelectronics Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
Follow Linaro: Facebook | Twitter | Blog
