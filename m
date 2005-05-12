From: Michael.Meduna@Bull.com
Date: Thu, 12 May 2005 19:15:41 +0000
Subject: Redirectable IRQs
Message-Id: <OFC99CCFB1.3123C49E-ON07256FFF.00687D83-07256FFF.0069CEAC@us-phx1.az05.bull.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org





Is there a way to permanently disable interrupts for specific CPUs.  I
am running on a 2.6 kernel and have designated CPU 0 in lowest priority
delivery mode.  I understand how to set lowest priority delivery mode or
fixed delivery mode for a specific IRQ.  What I would like to do is set
CPU 0 in lowest priority delivery mode for all IRQs but then, have the
ability to permanently disable interrupts for specific CPUs.

I realize that I could set CPU 0 to be the only processor to accept all
interrupts, however it would be best to allow Linux to spread the
interrupts
across other processors.  I have a few critical applications each bound to
a
cpuset with its own processor.  Ideally, I would not want these CPUs to
take
interrupts.

For example:  lets say I have a system with 8 host CPUs.  I create a
processor set that will contain a pool of CPUs (0-3).  I create another set
of processor sets (4 of them) that will contain processors 4-7.  All IRQs
are set to CPU 0 in lowest priority delivery mode.  I do not want
processors
4-7 to take an interrupt.  However, I do want interrupts to be spread
across
processors 0-3.  Is there a way to set the XTP register such that
processors
4-7 will never take an interrupt?

