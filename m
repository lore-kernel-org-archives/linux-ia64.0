From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 08 Mar 2004 10:42:53 +0000
Subject: RE: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <MDEEKOKJPMPMKGHIFAMAAEDEDGAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401B1A019@PDSMSX403.ccr.corp.intel.com>
References: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Liu, Benjamin" <benjamin.liu@intel.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Hi,

As a matter of fact, I don't have special reason to leave RTEs unmasked in
iosapic_register_intr(), iosapic_register_platform_intr(),
iosapic_override_isa_irq().
I think it is better that interrupts are unmasked by individual device
drivers, but
there are some exceptions. For example, PMI and INIT don't need device
drivers.
So I think more investigation is needed about them.

Regards,
Kenji Kaneshige

> -----Original Message-----
> From: Liu, Benjamin [mailto:benjamin.liu@intel.com]
> Sent: Monday, March 08, 2004 6:15 PM
> To: Kenji Kaneshige; linux-ia64@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Subject: RE: [PATCH] fix PCI interrupt setting for ia64
>
>
> Thank you for the information, Kenji. But is there any reason to
> leave it unmasked in iosapic_register_intr(),
> iosapic_register_platform_intr(), iosapic_override_isa_irq(),
> given the fact that they would be unmasked finally in individual
> device drivers?

