From: Matthew Wilcox <willy@debian.org>
Date: Tue, 15 Jul 2003 13:11:25 +0000
Subject: Serial port numbering still broken in 2.5.75
Message-Id: <marc-linux-ia64-105827492908441@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This is with 2.5.75:

Serial: 8250/16550 driver $Revision: 1.90 $ IRQ sharing enabled
ttyS0 at MMIO 0xf0200019000 (irq = 54) is a 16550A
PCI: Found IRQ 54 for device 0002:00:00.0
ttyS14 at MMIO 0xf0200018000 (irq = 54) is a 16550A
PCI: Found IRQ 54 for device 0002:00:00.1
ttyS15 at MMIO 0xf0200019010 (irq = 54) is a 16550A
ttyS1 at MMIO 0xf0200019038 (irq = 54) is a 16550A
PCI: Found IRQ 92 for device 0003:00:00.0
ttyS2 at MMIO 0xf0300018000 (irq = 92) is a 16550A
PCI: Found IRQ 92 for device 0003:00:00.1
ttyS3 at MMIO 0xf0300019000 (irq = 92) is a 16550A
ttyS4 at MMIO 0xf0300019010 (irq = 92) is a 16550A
ttyS5 at MMIO 0xf0300019038 (irq = 92) is a 16550A

Non-legacy serial ports are numbered 0, 14, 15, 1, 2, 3, 4, 5.  This is
because of this part of uart_find_match_or_unused() in drivers/serial/core.c:

        /*
         * We didn't find a matching entry, so look for the first
         * free entry.  We look for one which hasn't been previously
         * used (indicated by zero iobase).
         */
        for (i = 0; i < drv->nr; i++)
                if (drv->state[i].port->type = PORT_UNKNOWN &&
                    drv->state[i].port->iobase = 0 &&
                    drv->state[i].count = 0)
                        return &drv->state[i];

If you look in include/asm-ia64/serial.h, you'll see ttyS14
and ttyS15 marked as `spare', and these are the ones found by
uart_find_match_or_unused() first [the first port gets to be ttyS0
because of how 8250_hcdp works].

I think this loop needs to be deleted from uart_find_match_or_unused()
so we don't attempt to use 14/15 first.  Alternatively, we could just
fill in some random iobases in include/asm-ia64/serial.h so this loop
always fails on ia64.  But I've seen people complaining about their
modem getting ttyS14 on i386 too, so I really think this needs to get
fixed for everyone.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
