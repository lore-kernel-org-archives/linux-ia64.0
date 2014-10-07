From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 07 Oct 2014 15:50:44 +0000
Subject: Re: [PATCH 06/44] gpio-poweroff: Drop reference to pm_power_off from devicetree bindings
Message-Id: <20141007155044.GA19005@lunn.ch>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-7-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-7-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, openipmi-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, Rob

On Mon, Oct 06, 2014 at 10:28:08PM -0700, Guenter Roeck wrote:
> pm_power_off is an implementation detail. Replace it with a more generic
> description of the driver's functionality.
> 
> Cc: Rob Herring <robh+dt@kernel.org>
> Cc: Pawel Moll <pawel.moll@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
> ---
>  Documentation/devicetree/bindings/gpio/gpio-poweroff.txt | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/gpio/gpio-poweroff.txt b/Documentation/devicetree/bindings/gpio/gpio-poweroff.txt
> index d4eab92..c95a1a6 100644
> --- a/Documentation/devicetree/bindings/gpio/gpio-poweroff.txt
> +++ b/Documentation/devicetree/bindings/gpio/gpio-poweroff.txt
> @@ -2,12 +2,12 @@ Driver a GPIO line that can be used to turn the power off.
>  
>  The driver supports both level triggered and edge triggered power off.
>  At driver load time, the driver will request the given gpio line and
> -install a pm_power_off handler. If the optional properties 'input' is
> -not found, the GPIO line will be driven in the inactive
> +install a handler to power off the system. If the optional properties
> +'input' is not found, the GPIO line will be driven in the inactive
>  state. Otherwise its configured as an input.
>  
> -When the pm_power_off is called, the gpio is configured as an output,
> -and drive active, so triggering a level triggered power off
> +When the the poweroff handler is called, the gpio is configured as an
> +output, and drive active, so triggering a level triggered power off
>  condition. This will also cause an inactive->active edge condition, so
>  triggering positive edge triggered power off. After a delay of 100ms,
>  the GPIO is set to inactive, thus causing an active->inactive edge,
> @@ -24,7 +24,7 @@ Required properties:
>  
>  Optional properties:
>  - input : Initially configure the GPIO line as an input. Only reconfigure
> -  it to an output when the pm_power_off function is called. If this optional
> +  it to an output when the poweroff handler is called. If this optional
>    property is not specified, the GPIO is initialized as an output in its
>    inactive state.
>  
> -- 
> 1.9.1
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
