From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 26 Feb 2004 23:44:25 +0000
Subject: Excessive time to handle interrupts
Message-Id: <16446.34009.722204.259663@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I'm seeing very long interrupt handling times here, on McKinley (HP
ZX2000) -- of the order of a few microseconds.

Profiling indicates more than 4000 cycles are being spent in
enable_irq() after each interrupt.  As enable_irq() disables interrupt
collection, it's a bit difficult to get profiling data within that
function, but I strongly suspect it's the readl() in unmask_irq()
that's taking the time -- and likewise in mask_irq().


Code like this in arch/ia64/kernel/iosapic.c

    spin_lock_irqsave(&iosapic_lock, flags);
    {
	writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
        low32 = readl(addr + IOSAPIC_WINDOW);
        low32 &= ~(1 << IOSAPIC_MASK_SHIFT);    /* set only the mask bit */
	writel(low32, addr + IOSAPIC_WINDOW);
    }
    spin_unlock_irqrestore(&iosapic_lock, flags);

I don't know enough about the hardware to say for sure, is it
feasible to keep a soft copy of the register rather than do the read
all the time?  If that's not going to break the hardware, I'll code it
up and see if interrupt latencies go down.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*


