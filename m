From: Mark Rutland <mark.rutland@arm.com>
Date: Tue, 07 Oct 2014 10:59:41 +0000
Subject: Re: [PATCH 05/44] mfd: as3722: Drop reference to pm_power_off from devicetree bindings
Message-Id: <20141007105941.GD24725@leverpostej>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-6-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-6-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "adi-buildroot-devel@lists.sourceforge.net" <adi-buildroot-devel@lists.sourceforge.net>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "lguest@lists.ozlabs.org" <lguest@lists.ozlabs.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-am33-list@redhat.com" <linux-am33-list@redhat.com>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-m32r-ja@ml.linux-m32r.org" <linux-m32r-ja@ml.linux-m32r.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>

On Tue, Oct 07, 2014 at 06:28:07AM +0100, Guenter Roeck wrote:
> Devicetree bindings are supposed to be operating system independent
> and should thus not describe how a specific functionality is implemented
> in Linux.
> 
> Cc: Rob Herring <robh+dt@kernel.org>
> Cc: Pawel Moll <pawel.moll@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  Documentation/devicetree/bindings/mfd/as3722.txt | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

Thanks for the fix-up!

Acked-by: Mark Rutland <mark.rutland@arm.com>

Mark.

> 
> diff --git a/Documentation/devicetree/bindings/mfd/as3722.txt b/Documentation/devicetree/bindings/mfd/as3722.txt
> index 4f64b2a..0b2a609 100644
> --- a/Documentation/devicetree/bindings/mfd/as3722.txt
> +++ b/Documentation/devicetree/bindings/mfd/as3722.txt
> @@ -122,8 +122,7 @@ Following are properties of regulator subnode.
>  
>  Power-off:
>  ====> -AS3722 supports the system power off by turning off all its rail. This
> -is provided through pm_power_off.
> +AS3722 supports the system power off by turning off all its rails.
>  The device node should have the following properties to enable this
>  functionality
>  ams,system-power-controller: Boolean, to enable the power off functionality
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
