From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Sat, 28 Feb 2004 04:22:41 +0000
Subject: RE: [Patch] speed up interrupt handling
Message-Id: <16448.6033.627657.932257@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Sat, 28 Feb 2004 08:27:40 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:
>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

Peter> Because IRQs are disabled for every hardware interrupt, and
Peter> enabled after each interrupt returns.

David> OK, it's been really long since I worked on this, but AFAIR,
David> for level-triggered interrupts, there should be no
David> masking/unmasking during interrupt delivery.  What am I
David> missing?

Sorry, I should have been more clear.  For the user-mode driver, we
need to disable the interrupt so that it can be acknowledged to the
device in the user-level code after the in-kernel generic  interrupt
handler has returned.

So the sequence goes:
  Kernel					Userspace handler
						read(irqfd)
						  enable_irq()
						  down(semaphore)	

   do_IRQ
      desc->handler->ack()
      desc->action() (= stub_handler())		
	disable_irq				
	up(semaphore)
	return IRQ_HANDLED
      desc->handler->end()
						return from read()
						Read device status
							register
						Handle interrupt

I'm sure I also saw enable_irq() in the profile for the normal
in-kernel driver, but I don't know where it comes from, and can't see
it now.

Peter C
