From: "Yu, Luming" <luming.yu@intel.com>
Date: Mon, 23 Jun 2003 06:02:08 +0000
Subject: [Linux-ia64] RE: [ACPI] acpi_irq_to_vector()
Message-Id: <marc-linux-ia64-105634836206576@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>For PCI devices, we just read the irq out of the struct pci_dev.
>The platform code gets the opportunity to mangle the irq in whatever
>way it chooses before the pci_dev is passed to the driver.  Can we do
>something similar for ACPI instead?

The acpi_irq_to_vector is called in acpi_os_install_interrupt_handler which is in acpi_init that is before pci_init get called.
So I don't think it is reasonable to use pci_dev in acpi_init. 


-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
Acpi-devel mailing list
Acpi-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/acpi-devel

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
