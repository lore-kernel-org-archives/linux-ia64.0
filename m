From: "Yinghai Lu" <yinghai@kernel.org>
Date: Sat, 06 Dec 2008 04:56:23 +0000
Subject: Re: genirq regression - CONFIG_AUTO_IRQ_AFFINITY
Message-Id: <86802c440812052056r6b08fd0dpfae41dee8ee9ac65@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200812051640.mB5Ge2U1122172@fcbayern.americas.sgi.com>
In-Reply-To: <200812051640.mB5Ge2U1122172@fcbayern.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, Ingo Molnar <mingo@elte.hu>

On Fri, Dec 5, 2008 at 8:40 AM, John Keller <jpk@sgi.com> wrote:
> The addition of the generic affinity autoselector has introduced
> a regression in SN2 Altix.
>
> In the past, request_irq()'s call to select_smp_affinity() was
> essentially a noop.
>
> #ifdef CONFIG_AUTO_IRQ_AFFINITY
> extern int select_smp_affinity(unsigned int irq);
> #else
> static inline int select_smp_affinity(unsigned int irq)
> {
>        return 1;
> }
>
>
> Now changes have created do_irq_select_affinity(), which is
> executed by a call to request_irq().
>
>  request_irq()
>   __setup_irq()
>    do_irq_select_affinity()
>
> do_irq_select_affinity() will call the set_affinity() routine,
> with a default mask. On SN2 (and possibly all ia64 platforms),
> this will retarget all device interrupts to the same CPU, most
> likely CPU0.

> I'm looking at a patch that makes use of the new IRQ_AFFINITY_SET
> flag in the irq_desc to get around this.
>

that bit only be set in irq_set_affinity(),

arch/mips/kernel/cevt-bcm1480.c:        irq_set_affinity(irq,
cpumask_of_cpu(cpu));
arch/mips/kernel/cevt-sb1250.c: irq_set_affinity(irq, cpumask_of_cpu(cpu));
arch/sparc64/kernel/of_device.c:                irq_set_affinity(irq,
numa_mask);
arch/sparc64/kernel/pci_msi.c:          irq_set_affinity(irq, numa_mask);
arch/x86/kernel/hpet.c:                 irq_set_affinity(hdev->irq,
cpumask_of_cpu(hdev->cpu));
arch/x86/kernel/hpet.c: irq_set_affinity(dev->irq, cpumask_of_cpu(dev->cpu));
drivers/xen/events.c:   irq_set_affinity(irq, cpumask_of_cpu(0));

kernel/irq/proc.c:      irq_set_affinity(irq, new_value);

kernel/time/tick-common.c:              irq_set_affinity(newdev->irq, *cpumask);

so you may need to call it in your arch code. like
setup_IO_APIC_irq(),  create_irq()...

YH
