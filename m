From: "Rao, Goutham" <goutham.rao@intel.com>
Date: Thu, 26 Oct 2000 17:42:09 +0000
Subject: RE: [Linux-ia64] Remapping of the IA64 interrupts?
Message-Id: <marc-linux-ia64-105590678205635@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205634@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205634@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,
To answer your question... the legacy interrupts need to be re-mapped since
the vectors 0-15 are reserved on IA-64.  
Currently I have a patch that re-maps these interrupts and the PCI
interrupts via a pci_irq_to_vector interface... we will make this patch
available soon.  This may be a solution to the problem you are facing if you
are in fact facing a collision of vectors (PCI to ISA).

Thanks
Goutham
-----Original Message-----
From: White, Charles [mailto:Charles.White@COMPAQ.com]
Sent: Thursday, October 26, 2000 8:23 AM
To: 'linux-ia64@linuxia64.org'
Subject: [Linux-ia64] Remapping of the IA64 interrupts?


I am currently looking at an issue with the ISA interrupts, and it appears
to be caused by the re-mapping of these interrupts. 

From arch/ia64/kernel/irq_ia64.c
----------------------------------------
/*
 * Legacy IRQ to IA-64 vector translation table.  Any vector not in
 * this table maps to itself (ie: irq 0x30 => IA64 vector 0x30)
 */
__u8 isa_irq_to_vector_map[16] = {
	/* 8259 IRQ translation, first 16 entries */
	0x60, 0x50, 0x10, 0x51, 0x52, 0x53, 0x43, 0x54,
	0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x40, 0x41
};
------------------------------------------

Why do this legacy interrupts need to be remapped on the IA64 system?  What
specification did these re-map values come from? 




_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


