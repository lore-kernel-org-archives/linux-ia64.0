From: John Keller <jpk@sgi.com>
Date: Fri, 05 Dec 2008 16:40:01 +0000
Subject: genirq regression - CONFIG_AUTO_IRQ_AFFINITY
Message-Id: <200812051640.mB5Ge2U1122172@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: akpm@linux-foundation.org, tglx@linutronix.de

The addition of the generic affinity autoselector has introduced
a regression in SN2 Altix.

In the past, request_irq()'s call to select_smp_affinity() was
essentially a noop. 

#ifdef CONFIG_AUTO_IRQ_AFFINITY
extern int select_smp_affinity(unsigned int irq);
#else
static inline int select_smp_affinity(unsigned int irq)
{
        return 1;
}


Now changes have created do_irq_select_affinity(), which is
executed by a call to request_irq().

  request_irq()
   __setup_irq()
    do_irq_select_affinity()

do_irq_select_affinity() will call the set_affinity() routine,
with a default mask. On SN2 (and possibly all ia64 platforms),
this will retarget all device interrupts to the same CPU, most
likely CPU0.


#ifndef CONFIG_AUTO_IRQ_AFFINITY
/*
 * Generic version of the affinity autoselector.
 */
int do_irq_select_affinity(unsigned int irq, struct irq_desc *desc)
{
        cpumask_t mask;

        if (!irq_can_set_affinity(irq))
                return 0;

        cpus_and(mask, cpu_online_map, irq_default_affinity);

        /*
         * Preserve an userspace affinity setup, but make sure that
         * one of the targets is online.
         */
        if (desc->status & (IRQ_AFFINITY_SET | IRQ_NO_BALANCING)) {
                if (cpus_intersects(desc->affinity, cpu_online_map))
                        mask = desc->affinity;
                else
                        desc->status &= ~IRQ_AFFINITY_SET;
        }

        desc->affinity = mask;
        desc->chip->set_affinity(irq, mask);

        return 0;
}

This set_affinity call undoes all the performance related interrupt
targetting that the SN2 PROM did at boot.

I'm looking at a patch that makes use of the new IRQ_AFFINITY_SET
flag in the irq_desc to get around this.

Is this an issue for all ia64 platforms? Or does irq balancing
factor in here? IRQ balancing is disabled on SN2.

John Keller

