From: "Liu, Benjamin" <benjamin.liu@intel.com>
Date: Tue, 13 Apr 2004 09:07:00 +0000
Subject: RE: [PATCH] set_rte() should get iosapic_lock
Message-Id: <3ACA40606221794F80A5670F0AF15F8403F54143@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAKELPDLAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAKELPDLAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi, Kenji.

Lock is used to avoid racing during resource contention. It seems that your=
 patch is just for 2.6.5 which incorporates Bjorn's patch for ACPI IRQ clea=
nup.

Here iosapic_lock is used in
1. mask_irq() to protect I/O SAPIC config register write(REG SELECT, and RT=
E's lower word), iosapic_intr_info read(iosapic_intr_info[vec].low32).
2. unmask_irq() to protect I/O SAPIC config register write(REG SELECT, and =
RTE's lower word), iosapic_intr_info read(iosapic_intr_info[vec].low32).
3. iosapic_set_affinity() to protect I/O SAPIC config register write(REG SE=
LECT, and RTE's lower/higher words), iosapic_intr_info write(iosapic_intr_i=
nfo[vec].low32).

And in set_rte(), your patch intends to protect I/O SAPIC config register w=
rite(REG SELECT, and RTE's lower/higher words), iosapic_intr_info write(ios=
apic_intr_info[vec].low32). Bjorn's patch has defered RTE setting until dev=
ice driver initialization. So device module loading and "echo 0xff >/proc/i=
rq/xxx/smp_affinity" will cause racing, if without the lock in set_rte().

My question is whether it need to be applied to other kernel versions(befor=
e ACPI IRQ cleanup patch)?

Thanks,
Pingping (Benjamin) Liu
=20

>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org=20
>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Kenji Kaneshige
>Sent: 2004=C4=EA4=D4=C212=C8=D5 20:37
>To: linux-ia64@vger.kernel.org
>Subject: [PATCH] set_rte() should get iosapic_lock
>
>Hi,
>
>Currently set_rte() changes RTE without iosapic_lock held. I guess it
>assumes to be called only at the boot time. But set_rte() can be
>called by PCI driver not only at the boot time. So I think set_rte()
>should get iosapic_lock.
>
>pci_enable_device(drivers/pci/pci.c)
>|
>+-> pci_enable_device_bars(drivers/pci/pci.c)
>    |
>    +-> pcibios_enable_device(arch/ia64/pci/pci.c)
>        |
>        +-> acpi_pci_irq_enable (drivers/acpi/pci_irq.c)
>            |
>            +-> iosapic_enable_intr (arch/ia64/kernel/iosapic.c)
>                |
>                +-> set_rte (arch_ia64/kernel/iosapic.c)
>
>A following patch fixes this issue.  I'm also attaching this patch
>because my mailer replace all tabs with blanks.
>
>Thanks,
>Kenji Kaneshige
>
>diff -Naur linux-2.6.5/arch/ia64/kernel/iosapic.c
>linux-2.6.5-changed/arch/ia64/kernel/iosapic.c
>--- linux-2.6.5/arch/ia64/kernel/iosapic.c	2004-04-04=20
>12:37:06.000000000
>+0900
>+++ linux-2.6.5-changed/arch/ia64/kernel/iosapic.c	2004-04-12
>21:08:48.491220447 +0900
>@@ -172,7 +172,7 @@
> static void
> set_rte (unsigned int vector, unsigned int dest, int mask)
> {
>-	unsigned long pol, trigger, dmode;
>+	unsigned long pol, trigger, dmode, flags;
> 	u32 low32, high32;
> 	char *addr;
> 	int rte_index;
>@@ -211,11 +211,15 @@
> 	/* dest contains both id and eid */
> 	high32 =3D (dest << IOSAPIC_DEST_SHIFT);
>
>-	writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
>-	writel(high32, addr + IOSAPIC_WINDOW);
>-	writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
>-	writel(low32, addr + IOSAPIC_WINDOW);
>-	iosapic_intr_info[vector].low32 =3D low32;
>+	spin_lock_irqsave(&iosapic_lock, flags);
>+	{
>+		writel(IOSAPIC_RTE_HIGH(rte_index), addr +=20
>IOSAPIC_REG_SELECT);
>+		writel(high32, addr + IOSAPIC_WINDOW);
>+		writel(IOSAPIC_RTE_LOW(rte_index), addr +=20
>IOSAPIC_REG_SELECT);
>+		writel(low32, addr + IOSAPIC_WINDOW);
>+		iosapic_intr_info[vector].low32 =3D low32;
>+	}
>+	spin_unlock_irqrestore(&iosapic_lock, flags);
> }
>
> static void
>
