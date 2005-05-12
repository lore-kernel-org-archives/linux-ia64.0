From: Grant Grundler <iod00d@hp.com>
Date: Thu, 12 May 2005 20:11:59 +0000
Subject: Re: Redirectable IRQs
Message-Id: <20050512201159.GJ14123@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <OFC99CCFB1.3123C49E-ON07256FFF.00687D83-07256FFF.0069CEAC@us-phx1.az05.bull.com>
In-Reply-To: <OFC99CCFB1.3123C49E-ON07256FFF.00687D83-07256FFF.0069CEAC@us-phx1.az05.bull.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 12, 2005 at 12:15:41PM -0700, Michael.Meduna@Bull.com wrote:
> Is there a way to permanently disable interrupts for specific CPUs.

Yes - but it may not be exactly what you want.
See /proc/irq/*/smp_affinity.

I'm not sure what /sys/class/pci_bus/*/cpuaffinity does.
It looks like a cpu set mask though.

...
> I have a few critical applications each bound to a cpuset with its
> own processor.  Ideally, I would not want these CPUs to take interrupts.

Simple solution is to bind each IRQ "manually" to a single processor.

> Is there a way to set the XTP register such that processors
> 4-7 will never take an interrupt?

ISTR, HP IA64 platforms do not implement XTP.
Binding IRQs 1:1 with CPUs was seen as a better choice.
MSI-X allows intelligent 1:N if devices really need to load
multiple CPUs.

grant
