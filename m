From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 11 Aug 2005 23:49:12 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <42FBE3F8.1090006@pobox.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com> <20050811214807.GA9775@havoc.gtf.org> <42FBC985.4030602@pobox.com> <200508111707.30861.bjorn.helgaas@hp.com>
In-Reply-To: <200508111707.30861.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>

Bjorn Helgaas wrote:
> You deduce this by the absence of SecO and PriO?  I wonder if lspci
> should be enhanced to notice this, too.  I assume that the IRQ 169
> doesn't correspond to anything in /proc/interrupts.

Correct.


> So the scenario in question (correct me if I'm wrong) is that we
> have a PCI IDE device that is handed off in compatibility mode (and
> may only work in that mode).  In that case, the PCI *device* still
> exists, so shouldn't the IDE PCI code claim that device, notice that
> it's in compatibility mode, and use the legacy ports and IRQs if
> necessary?
> 
> It seems like that all should work even if we don't have IDE_GENERIC.

Yes, you're right.  Thinking more, the PCI IDE code should pick that up, 
not the IDE_GENERIC code.

	Jeff


