From: Mark Rutland <mark.rutland@arm.com>
Date: Tue, 07 Oct 2014 16:58:35 +0000
Subject: Re: [PATCH 05/44] mfd: as3722: Drop reference to pm_power_off from devicetree bindings
Message-Id: <20141007165835.GE27216@leverpostej>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-6-git-send-email-linux@roeck-us.net>
 <543412F7.8040909@landley.net>
In-Reply-To: <543412F7.8040909-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org" <devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>, "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, "linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-cris-kernel-VrBV9hrLPhE@public.gmane.org" <linux-cris-kernel-VrBV9hrLPhE@public.gmane.org>, "linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org" <linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org>, "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

On Tue, Oct 07, 2014 at 05:21:11PM +0100, Rob Landley wrote:
> On 10/07/14 00:28, Guenter Roeck wrote:
> > Devicetree bindings are supposed to be operating system independent
> > and should thus not describe how a specific functionality is implemented
> > in Linux.
> 
> So your argument is that linux/Documentation/devicetree/bindings should
> not be specific to Linux. Merely hosted in the Linux kernel source
> repository.

Precisely. If nothing else as a general guideline this keeps us honest,
and prevents us from embedding arbitrary implementation details into
bidnings that cause pain later when we want to change things at either
end.

There are already otehr users of these bindings, so we can't really
claim they're strictly Linux-specific anyhow.

> Well that's certainly a point of view.

As far as I am aware, it's the point of view shared by the device tree
maintainers, and it's been that way for a while.

I don't really follow your concern. For one thing were this followed
more strictly this file wouldn't need patching at all to correct for
this Linux-internal rework...

Thanks,
Mark.
