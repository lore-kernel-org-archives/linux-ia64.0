From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 09 Mar 2004 23:26:54 +0000
Subject: Re: [ACPI] [PATCH] 5 of 6 avoid double conversion of ACPI OS interrupt
Message-Id: <200403091626.54746.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403091619.04333.bjorn.helgaas@hp.com>
In-Reply-To: <200403091619.04333.bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andi Kleen <ak-l3A5Bk7waGM@public.gmane.org>, "Nakajima, Jun" <jun.nakajima-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

ACPI: Avoid double conversion of ACPI OS interrupt

The global IRQ used to be converted once in
acpi_os_install_interrupt_handler() and again in
acpi_os_remove_interrupt_handler().

diff -Nru a/drivers/acpi/osl.c b/drivers/acpi/osl.c
--- a/drivers/acpi/osl.c	Tue Mar  9 14:24:15 2004
+++ b/drivers/acpi/osl.c	Tue Mar  9 14:24:15 2004
@@ -262,7 +262,7 @@
 		printk(KERN_ERR PREFIX "SCI (IRQ%d) allocation failed\n", irq);
 		return AE_NOT_ACQUIRED;
 	}
-	acpi_irq_irq = irq;
+	acpi_irq_irq = global_irq;
 
 	return AE_OK;
 }

