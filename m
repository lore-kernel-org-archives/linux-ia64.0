From: "White, Charles" <Charles.White@COMPAQ.com>
Date: Thu, 26 Oct 2000 15:22:38 +0000
Subject: [Linux-ia64] Remapping of the IA64 interrupts?
Message-Id: <marc-linux-ia64-105590678205634@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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




