From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Thu, 24 Oct 2002 17:39:52 +0000
Subject: [Linux-ia64] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805233@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We need this driver as it's the only solution for DIG64 compliant IPF
> platforms.

No, not for all DIG64 compliant IPF platforms.  NEC TX7 is also
a DIG64 compliant IPF platform but doesn't need your driver.

DIG64(2.1) only states that:

 Firmware Support for PCI Hot-Plug
                               : Recommended if PCI Hot-Plug is
                                 implemented
 ACPI Support for PCI Hot-Plug : Recommended for platforms that
                                 implement PCI Hot-Plug without SHPC
 Using PCI Hot-Plug Specifications
                               : Recommended if PCI Hot-Plug is
                                 implemented

The spec also states that any PCI Hot-Plug controller must
follow one of PCI Hot-Plug spec 1.1, SHPC 1.0 or CompactPCI Hot Swap
spec.  It also strongly recommends SHPC 1.0, which is not covered
by J.I.'s driver yet.

But anyway Itanium2 platform using intel's hot-plug controller
will be shipping soon and J.I.'s driver has much better functionality
than acpiphp.  This would be a decent reason for having the
driver in the mainline.

And this also motivates us to clean up the duplicated code if
it were in mainline:)

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


