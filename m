From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 27 Jun 2001 16:42:31 +0000
Subject: Re: FW: [Linux-ia64] Interrupt redirection problem
Message-Id: <marc-linux-ia64-105590693005783@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 27 Jun 2001 11:15:13 -0500, "Miller, Mike (OS Dev)" <Mike.Miller@compaq.com> said:

  Mike> Is this to say that the BSP handling >90% of the interrupts is
  Mike> normal or OK?

For some reason, my earlier response to Andreas's question didn't make
it to the list, so I'm repeating it here: it is indeed normal for a
single CPU to receive most of the interrupts.  The way this works is
that normally all CPUs use an external task priority (xtp) of
"normal".  When a CPU runs its idle task, it lowers the xtp to "low"
and thereby actively solicits interrupt delivery to itself.  Now, when
the xtp across all CPUs is the same, the chipset gets to chose which
CPU to deliver an interrupt to.  IIRC, the 460gx in that case picks
the CPU which was programmed into the I/O SAPIC.  On Linux, that is by
default the CPU that installed the interrupt handler.  And since most
interrupt handlers are installed by the bootstrap processor, you
normally see most interrupts coming in on CPU 0.

	--david

