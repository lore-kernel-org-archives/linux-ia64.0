From: Jean-Francois Neyroud <Jean-Francois.Neyroud@bull.net>
Date: Tue, 20 Apr 2004 12:25:00 +0000
Subject: Re: [PATCH][RFC] Vector sharing
Message-Id: <4085169C.1090800@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030401060302040105010106"
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030401060302040105010106
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit



Kenji Kaneshige wrote:

>Hi,
>
>I'm trying to make a patch that allows device vectors to be shared by
>multiple interrupt sources. This patch enables ia64 linux to boot on
>the machine that has single vector number space and many device
>interrupt sources (more than 184).
>
>I
>
Hi Kenji,

An other or complementary way is to attach a vector only for interrupt
lines witch are used, PCI slots have 4 interrupt lines but only 1 or
sometime 2 are used by adapters.

Find hereafter a patch tested on IA64 platform.

Jean-Francois.

-- 
Jean-Francois Neyroud 
Bull SA                                               http://www-frec.bull.com 



--------------030401060302040105010106
Content-Type: text/plain;
 name="Bull_irq_dynamic.patch"
Content-Disposition: inline;
 filename="Bull_irq_dynamic.patch"
Content-Transfer-Encoding: 8bit

--- linux-2.6.3_ref/drivers/acpi/pci_irq.c	Wed Feb 18 04:57:46 2004
+++ linux-2.6.3/drivers/acpi/pci_irq.c	Fri Feb 27 14:06:37 2004
@@ -264,8 +264,15 @@
 		}
 	}
 	else if (!entry->irq) {
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Invalid static routing entry (IRQ 0)\n"));
-		return_VALUE(0);
+		int irq;
+	    
+		irq = iosapic_register_intr(entry->link.index, IOSAPIC_POL_LOW, IOSAPIC_LEVEL);
+		if (irq < 0) {
+
+			ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Invalid static routing entry (IRQ 0)\n"));
+			return_VALUE(0);
+		}
+		entry->irq = irq;
 	}
 
 	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Found IRQ %d\n", entry->irq));
--- linux-2.6.3_ref/arch/ia64/kernel/iosapic.c	Fri Feb 27 13:57:06 2004
+++ linux-2.6.3/arch/ia64/kernel/iosapic.c	Fri Feb 27 14:03:20 2004
@@ -706,8 +706,8 @@
 			if (pcat_compat && (gsi < 16))
 				vector = isa_irq_to_vector(gsi);
 			else
-				/* new GSI; allocate a vector for it */
-				vector = ia64_alloc_vector();
+				/* new GSI; don't allocate a vector for it */
+				continue;
 
 			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, IOSAPIC_POL_LOW,
 				      IOSAPIC_LEVEL);

--------------030401060302040105010106--

