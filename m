From: Grant Grundler <iod00d@hp.com>
Date: Thu, 21 Oct 2004 16:53:29 +0000
Subject: Re: request_irq() and setup_irq()
Message-Id: <20041021165329.GG30581@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4177D1A4.1040009@hob.de>
In-Reply-To: <4177D1A4.1040009@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 21, 2004 at 05:11:32PM +0200, Christian Hildner wrote:
> Hi,
> 
> looking through the sources of 2.4.21 there come up one question. If a 
> device wants to register its interrupt it may call request_irq() that 
> then calls setup_irq(). Now since SA_PERCPU_IRQ is not set by the device 
> setup_irq() does not initialize desc->handler.

Sorry - can you explain why this is a problem?
Are you trying to avoid the spinlock in do_IRQ() or something else?

It's been a while since I've last played with 2.4.21, but it mostly
worked for the things I was testing at the time.

> Can that be fixed by 
> adding SA_PERCPU_IRQ to irqflags in request_irq() or does that introduce 
> problems at another place?

For IO SAPIC generated interrupts, that should work fine on platforms
that don't implement XPR (IIRC, e.g. HP ZX1). Systems which implement
XPR could redirect the interrupt to a different CPU (e.g Intel).
IIRC, one can "pin" the IO SAPIC generated interrupt to a CPU despite
XPR but I don't recall details or if that's already being done.
You'll need to investigate this a bit more.

hth,
grant
