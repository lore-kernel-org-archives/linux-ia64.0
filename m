From: Matthew Wilcox <willy@debian.org>
Date: Thu, 24 Oct 2002 17:59:14 +0000
Subject: Re: [Linux-ia64] RE: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805237@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 24, 2002 at 10:40:05AM -0700, Lee, Jung-Ik wrote:
> **resource management**
> Non-ACPI platforms uses $HRT/EBDA, pcibios_*(), SMBIOS, etc. for slot
> enumeration/configuration.
> DIG64/ACPI, and SHPC requires ACPI for this. IPF platforms only have ACPI
> _CRS, _PRT, _HPP, _BBN, _STA, _ADR, _SUN, etc on the namespace for PHP, and
> we have to use them. (as a side note, this functionality is common for other
> hotplug-* as mentioned in first mail. No API will be common for
> hotplug-everything, but functionality is common and has not to be
> duplicated)

> **event management in terms of controller/slot operations **
> ACPI provides only _EJ0, _PS?, _STA, etc for slot operations but these are
> not mandatory. That means, we can use either ACPI method or controller
> driver.
> intcphp driver has not enabled ACPI method based solution but uses
> controller driver.
> intcphp driver is also capable of performing ACPI method based solution
> since it works on ACPI namespace. This is why acpiphp and intcphp could be
> sharing resource management and event management.

Sounds like we want a library of ACPI code that can be used by individual
drivers rather than an ACPI driver with pluggable event management
functions then.

-- 
Revolutions do not require corporate support.

