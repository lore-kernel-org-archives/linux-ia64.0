From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 08 Mar 2004 08:31:01 +0000
Subject: RE: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <MDEEKOKJPMPMKGHIFAMAMECODGAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401B1A016@PDSMSX403.ccr.corp.intel.com>
References: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Liu, Benjamin" <benjamin.liu@intel.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Hi Liu,

I think it is not converse.
What I wanted to do was to mask (disable) IRQ in iosapic_enable_intr().
I think PCI IRQ should be unmasked (enabled) by device driver, not by
iosapic_enable_intr() at the boot time.

Regards,
Kenji Kaneshige

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Liu, Benjamin
> Sent: Monday, March 08, 2004 4:34 PM
> To: Kenji Kaneshige; linux-ia64@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Subject: RE: [PATCH] fix PCI interrupt setting for ia64
>
>
> Hi, Kenji,
>
> I am a little bit confused with the patch:
> Mask bit of RDL's low word indicates the interrupt is enabled
> when it is zero, disabled when it is 1. But from the patch below,
> it seems that Kenji enable interrupts in iosapic_register_intr(),
> iosapic_register_platform_intr(), iosapic_override_isa_irq(), and
> disable the interrupt in iosapic_enable_intr(). Is it converse?
>
> Thanks,
> Pingping (Benjamin) Liu
> Intel China Software Center
>
>
> >-----Original Message-----
> >From: linux-ia64-owner@vger.kernel.org
> >[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Kenji Kaneshige
> >Sent: 2004=C4=EA3=D4=C28=C8=D5 10:49
> >To: linux-ia64@vger.kernel.org
> >Cc: linux-kernel@vger.kernel.org
> >Subject: [PATCH] fix PCI interrupt setting for ia64
> >
> >
> >Hi,
> >
> >In ia64 kernel, IOSAPIC's RTEs for PCI interrupts are unmasked at the
> >boot time before installing device drivers. I think it is very
> >dangerous.
> >If some PCI devices without device driver generate interrupts,
> >interrupts
> >are generated repeatedly because these interrupt requests are never
> >cleared. I think RTEs for PCI interrupts should be unmasked by device
> >driver.
> >
> >A following patch fixes this issue.
> >
> >Regards,
> >Kenji Kaneshige
> >
> >
> >diff -Naur linux-2.6.4-rc2/arch/ia64/kernel/iosapic.c
> >linux-2.6.4-rc2-changed/arch/ia64/kernel/iosapic.c
> >--- linux-2.6.4-rc2/arch/ia64/kernel/iosapic.c  2004-03-05
> >15:13:53.155237277 +0900
> >+++ linux-2.6.4-rc2-changed/arch/ia64/kernel/iosapic.c  2004-03-05
> >16:48:31.856142526 +0900
> >@@ -170,7 +170,7 @@
> > }
> >
> > static void
> >-set_rte (unsigned int vector, unsigned int dest)
> >+set_rte (unsigned int vector, unsigned int dest, int mask)
> > {
> >        unsigned long pol, trigger, dmode;
> >        u32 low32, high32;
> >@@ -205,6 +205,7 @@
> >        low32 =3D ((pol << IOSAPIC_POLARITY_SHIFT) |
> >                 (trigger << IOSAPIC_TRIGGER_SHIFT) |
> >                 (dmode << IOSAPIC_DELIVERY_SHIFT) |
> >+                ((mask ? 1 : 0) << IOSAPIC_MASK_SHIFT) |
> >                 vector);
> >
> >        /* dest contains both id and eid */
> >@@ -509,7 +510,7 @@
> >               (trigger =3D IOSAPIC_EDGE ? "edge" : "level"),
> >dest, vector);
> >
> >        /* program the IOSAPIC routing table */
> >-       set_rte(vector, dest);
> >+       set_rte(vector, dest, 0);
> >        return vector;
> > }
> >
> >@@ -557,7 +558,7 @@
> >               (trigger =3D IOSAPIC_EDGE ? "edge" : "level"),
> >dest, vector);
> >
> >        /* program the IOSAPIC routing table */
> >-       set_rte(vector, dest);
> >+       set_rte(vector, dest, 0);
> >        return vector;
> > }
> >
> >@@ -583,7 +584,7 @@
> >            trigger =3D IOSAPIC_EDGE ? "edge" : "level", dest, vector);
> >
> >        /* program the IOSAPIC routing table */
> >-       set_rte(vector, dest);
> >+       set_rte(vector, dest, 0);
> > }
> >
> > void __init
> >@@ -669,7 +670,7 @@
> >        /* direct the interrupt vector to the running cpu id */
> >        dest =3D (ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff;
> > #endif
> >-       set_rte(vector, dest);
> >+       set_rte(vector, dest, 1);
> >
> >        printk(KERN_INFO "IOSAPIC: vector %d -> CPU 0x%04x, enabled\n",
> >               vector, dest);
> >
> >-
> >To unsubscribe from this list: send the line "unsubscribe
> >linux-ia64" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

