From: Greg KH <greg@kroah.com>
Date: Thu, 24 Oct 2002 22:06:08 +0000
Subject: [Linux-ia64] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805241@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 24, 2002 at 10:40:05AM -0700, Lee, Jung-Ik wrote:
> 
> **resource management**
> Non-ACPI platforms uses $HRT/EBDA, pcibios_*(), SMBIOS, etc. for slot
> enumeration/configuration.
> DIG64/ACPI, and SHPC requires ACPI for this. IPF platforms only have ACPI
> _CRS, _PRT, _HPP, _BBN, _STA, _ADR, _SUN, etc on the namespace for PHP, and
> we have to use them. (as a side note, this functionality is common for other
> hotplug-* as mentioned in first mail. No API will be common for
> hotplug-everything, but functionality is common and has not to be
> duplicated)
> 
> **event management in terms of controller/slot operations **
> ACPI provides only _EJ0, _PS?, _STA, etc for slot operations but these are
> not mandatory. That means, we can use either ACPI method or controller
> driver.
> intcphp driver has not enabled ACPI method based solution but uses
> controller driver.
> intcphp driver is also capable of performing ACPI method based solution
> since it works on ACPI namespace. This is why acpiphp and intcphp could be
> sharing resource management and event management.

Ok, that makes more sense to me now.  Thank you for taking the time to
explain this.

> > As this means there is a lot of "dead code" in the driver, you should
> > take all of it out.
> 
> Well, I removed many dead codes from the base driver. This is not dead code
> but needed to support other types.
> However, if it's not acceptable, I'll remove them.

If the code can never be called, it looks pretty dead to me :)

But as you're going to be sending me a patch for the existing driver, we
don't have to worry about this anymore.

> OK, then, I'll send you a patch against your cpqphp driver asap.

Looking forward to it.

thanks,

greg k-h

