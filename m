From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 07 Oct 2014 16:00:56 +0000
Subject: Re: [PATCH 21/44] power/reset: gpio-poweroff: Register with kernel poweroff handler
Message-Id: <20141007160056.GC19005@lunn.ch>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-22-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-22-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linux-mips@linux-mips.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-xtensa@linux-xtensa.org, devel@driverdev.osuosl.org, linux-s390@vger.kernel.org, lguest@lists.ozlabs.org, linux-c6x-dev@linux-c6x.org, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devicetree@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-pm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-m68k@lists.linux-m68k.org, linux-am33-list@redhat.com, linux-tegra@vger.kernel.org, openipmi-developer@lists.sourceforge.net, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, David Woodhouse <dwmw2@infrad>

On Mon, Oct 06, 2014 at 10:28:23PM -0700, Guenter Roeck wrote:
> Register with kernel poweroff handler instead of setting pm_power_off
> directly. Register with a low priority value of 64 to reflect that
> the original code only sets pm_power_off if it was not already set.
> 
> Other changes:
> 
> Drop note that there can not be an additional instance of this driver.
> The original reason no longer applies, it should be obvious that there
> can only be one instance of the driver if static variables are used to
> reflect its state, and support for multiple instances can now be added
> easily if needed by avoiding static variables.
> 
> Do not create an error message if another poweroff handler has already been
> registered. This is perfectly normal and acceptable.
> 
> Do not display a warning traceback if the poweroff handler fails to
> power off the system. There may be other poweroff handlers.

I would prefer to keep the warning traceback. We found on some
hardware the GPIO transitions were too fast and it failed to power
off. Seeing the traceback gives an idea where to go look for the
problem.

Other than that,

Acked-by: Andrew Lunn <andrew@lunn.ch>

> 
> Cc: Sebastian Reichel <sre@kernel.org>
> Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  drivers/power/reset/gpio-poweroff.c | 36 ++++++++++++++++++------------------
>  1 file changed, 18 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/power/reset/gpio-poweroff.c b/drivers/power/reset/gpio-poweroff.c
> index ce849bc..e95a7a1 100644
> --- a/drivers/power/reset/gpio-poweroff.c
> +++ b/drivers/power/reset/gpio-poweroff.c
> @@ -14,18 +14,18 @@
>  #include <linux/kernel.h>
>  #include <linux/init.h>
>  #include <linux/delay.h>
> +#include <linux/notifier.h>
> +#include <linux/pm.h>
>  #include <linux/platform_device.h>
>  #include <linux/gpio/consumer.h>
>  #include <linux/of_platform.h>
>  #include <linux/module.h>
>  
> -/*
> - * Hold configuration here, cannot be more than one instance of the driver
> - * since pm_power_off itself is global.
> - */
>  static struct gpio_desc *reset_gpio;
>  
> -static void gpio_poweroff_do_poweroff(void)
> +static int gpio_poweroff_do_poweroff(struct notifier_block *this,
> +				     unsigned long unused1, void *unused2)
> +
>  {
>  	BUG_ON(!reset_gpio);
>  
> @@ -42,20 +42,18 @@ static void gpio_poweroff_do_poweroff(void)
>  	/* give it some time */
>  	mdelay(3000);
>  
> -	WARN_ON(1);
> +	return NOTIFY_DONE;
>  }
>  
> +static struct notifier_block gpio_poweroff_nb = {
> +	.notifier_call = gpio_poweroff_do_poweroff,
> +	.priority = 64,
> +};
> +
>  static int gpio_poweroff_probe(struct platform_device *pdev)
>  {
>  	bool input = false;
> -
> -	/* If a pm_power_off function has already been added, leave it alone */
> -	if (pm_power_off != NULL) {
> -		dev_err(&pdev->dev,
> -			"%s: pm_power_off function already registered",
> -		       __func__);
> -		return -EBUSY;
> -	}
> +	int err;
>  
>  	reset_gpio = devm_gpiod_get(&pdev->dev, NULL);
>  	if (IS_ERR(reset_gpio))
> @@ -77,14 +75,16 @@ static int gpio_poweroff_probe(struct platform_device *pdev)
>  		}
>  	}
>  
> -	pm_power_off = &gpio_poweroff_do_poweroff;
> -	return 0;
> +	err = register_poweroff_handler(&gpio_poweroff_nb);
> +	if (err)
> +		dev_err(&pdev->dev, "Failed to register poweroff handler\n");
> +
> +	return err;
>  }
>  
>  static int gpio_poweroff_remove(struct platform_device *pdev)
>  {
> -	if (pm_power_off = &gpio_poweroff_do_poweroff)
> -		pm_power_off = NULL;
> +	unregister_poweroff_handler(&gpio_poweroff_nb);
>  
>  	return 0;
>  }
> -- 
> 1.9.1
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
