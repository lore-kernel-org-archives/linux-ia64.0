From: Mark Rutland <mark.rutland@arm.com>
Date: Tue, 07 Oct 2014 11:03:32 +0000
Subject: Re: [PATCH 06/44] gpio-poweroff: Drop reference to pm_power_off from devicetree bindings
Message-Id: <20141007110332.GF24725@leverpostej>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-7-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-7-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "adi-buildroot-devel@lists.sourceforge.net" <adi-buildroot-devel@lists.sourceforge.net>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "lguest@lists.ozlabs.org" <lguest@lists.ozlabs.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-am33-list@redhat.com" <linux-am33-list@redhat.com>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-m32r-ja@ml.linux-m32r.org" <linux-m32r-ja@ml.linux-m32r.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>

On Tue, Oct 07, 2014 at 06:28:08AM +0100, Guenter Roeck wrote:
> pm_power_off is an implementation detail. Replace it with a more generic
> description of the driver's functionality.
> 
> Cc: Rob Herring <robh+dt@kernel.org>
> Cc: Pawel Moll <pawel.moll@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>

Acked-by: Mark Rutland <mark.rutland@arm.com>

> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
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
