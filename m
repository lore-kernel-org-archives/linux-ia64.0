From: "Lee, Jung-Ik" <jung-ik.lee@intel.com>
Date: Thu, 24 Oct 2002 18:39:35 +0000
Subject: [Linux-ia64] RE: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805239@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > We need this driver as it's the only solution for DIG64 
> compliant IPF
> > platforms.
> 
> No, not for all DIG64 compliant IPF platforms.  NEC TX7 is also
> a DIG64 compliant IPF platform but doesn't need your driver.

Well, I forgot acpiphp driver was removed in this driver patch :)
acpiphp is also for DIG64/ACPI and will do for some DIG64/ACPI machines
while intcphp is feature full driver for IPF platform PHP.

> 
> DIG64(2.1) only states that:
> 
>  Firmware Support for PCI Hot-Plug
>                                : Recommended if PCI Hot-Plug is
>                                  implemented
>  ACPI Support for PCI Hot-Plug : Recommended for platforms that
>                                  implement PCI Hot-Plug without SHPC
>  Using PCI Hot-Plug Specifications
>                                : Recommended if PCI Hot-Plug is
>                                  implemented

ACPI IS mandatory for DIG64 PHP resource management by SHPC, while ACPI
based slot operation is not required.
The above sentence only could be misleading.

> 
> The spec also states that any PCI Hot-Plug controller must
> follow one of PCI Hot-Plug spec 1.1, SHPC 1.0 or CompactPCI Hot Swap
> spec.  It also strongly recommends SHPC 1.0, which is not covered
> by J.I.'s driver yet.

intcphp is desined with SHPC on plan in terms of ACPI resource management,
as SHPC spec says
"DIG64 compliant platforms must use ACPI to describe resource allocation."
But it is not completely ready for SHPC yet. It's a matter of deployment
schedules of dependencies such as HPRT, ACPI methods OSHP, HBRB, etc which
will need to be enabled in Linux kernel ACPI driver/platform firmware.

> 
> But anyway Itanium2 platform using intel's hot-plug controller
> will be shipping soon and J.I.'s driver has much better functionality
> than acpiphp.  This would be a decent reason for having the
> driver in the mainline.
> 
> And this also motivates us to clean up the duplicated code if
> it were in mainline:)

\o/ second to this :)

> 
> Thanks,
> -- 
> KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>
> 

