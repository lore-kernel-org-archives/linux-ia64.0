From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 12 Apr 2004 12:36:34 +0000
Subject: [PATCH] set_rte() should get iosapic_lock
Message-Id: <MDEEKOKJPMPMKGHIFAMAKELPDLAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_001A_01C420D6.3A5D4DE0"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_001A_01C420D6.3A5D4DE0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit

Hi,

Currently set_rte() changes RTE without iosapic_lock held. I guess it
assumes to be called only at the boot time. But set_rte() can be
called by PCI driver not only at the boot time. So I think set_rte()
should get iosapic_lock.

pci_enable_device(drivers/pci/pci.c)
|
+-> pci_enable_device_bars(drivers/pci/pci.c)
    |
    +-> pcibios_enable_device(arch/ia64/pci/pci.c)
        |
        +-> acpi_pci_irq_enable (drivers/acpi/pci_irq.c)
            |
            +-> iosapic_enable_intr (arch/ia64/kernel/iosapic.c)
                |
                +-> set_rte (arch_ia64/kernel/iosapic.c)

A following patch fixes this issue.  I'm also attaching this patch
because my mailer replace all tabs with blanks.

Thanks,
Kenji Kaneshige

diff -Naur linux-2.6.5/arch/ia64/kernel/iosapic.c
linux-2.6.5-changed/arch/ia64/kernel/iosapic.c
--- linux-2.6.5/arch/ia64/kernel/iosapic.c	2004-04-04 12:37:06.000000000
+0900
+++ linux-2.6.5-changed/arch/ia64/kernel/iosapic.c	2004-04-12
21:08:48.491220447 +0900
@@ -172,7 +172,7 @@
 static void
 set_rte (unsigned int vector, unsigned int dest, int mask)
 {
-	unsigned long pol, trigger, dmode;
+	unsigned long pol, trigger, dmode, flags;
 	u32 low32, high32;
 	char *addr;
 	int rte_index;
@@ -211,11 +211,15 @@
 	/* dest contains both id and eid */
 	high32 = (dest << IOSAPIC_DEST_SHIFT);

-	writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
-	writel(high32, addr + IOSAPIC_WINDOW);
-	writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
-	writel(low32, addr + IOSAPIC_WINDOW);
-	iosapic_intr_info[vector].low32 = low32;
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
+		writel(high32, addr + IOSAPIC_WINDOW);
+		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
+		writel(low32, addr + IOSAPIC_WINDOW);
+		iosapic_intr_info[vector].low32 = low32;
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
 }

 static void

------=_NextPart_000_001A_01C420D6.3A5D4DE0
Content-Type: application/octet-stream;
	name="fix_set_rte.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="fix_set_rte.patch"

diff -Naur linux-2.6.5/arch/ia64/kernel/iosapic.c =
linux-2.6.5-changed/arch/ia64/kernel/iosapic.c=0A=
--- linux-2.6.5/arch/ia64/kernel/iosapic.c	2004-04-04 12:37:06.000000000 =
+0900=0A=
+++ linux-2.6.5-changed/arch/ia64/kernel/iosapic.c	2004-04-12 =
21:08:48.491220447 +0900=0A=
@@ -172,7 +172,7 @@=0A=
 static void=0A=
 set_rte (unsigned int vector, unsigned int dest, int mask)=0A=
 {=0A=
-	unsigned long pol, trigger, dmode;=0A=
+	unsigned long pol, trigger, dmode, flags;=0A=
 	u32 low32, high32;=0A=
 	char *addr;=0A=
 	int rte_index;=0A=
@@ -211,11 +211,15 @@=0A=
 	/* dest contains both id and eid */=0A=
 	high32 =3D (dest << IOSAPIC_DEST_SHIFT);=0A=
 =0A=
-	writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
-	writel(high32, addr + IOSAPIC_WINDOW);=0A=
-	writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
-	writel(low32, addr + IOSAPIC_WINDOW);=0A=
-	iosapic_intr_info[vector].low32 =3D low32;=0A=
+	spin_lock_irqsave(&iosapic_lock, flags);=0A=
+	{=0A=
+		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
+		writel(high32, addr + IOSAPIC_WINDOW);=0A=
+		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);=0A=
+		writel(low32, addr + IOSAPIC_WINDOW);=0A=
+		iosapic_intr_info[vector].low32 =3D low32;=0A=
+	}=0A=
+	spin_unlock_irqrestore(&iosapic_lock, flags);=0A=
 }=0A=
 =0A=
 static void=0A=

------=_NextPart_000_001A_01C420D6.3A5D4DE0--

