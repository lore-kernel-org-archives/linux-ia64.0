From: Christian Hildner <christian.hildner@hob.de>
Date: Thu, 21 Oct 2004 15:11:32 +0000
Subject: request_irq() and setup_irq()
Message-Id: <4177D1A4.1040009@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

looking through the sources of 2.4.21 there come up one question. If a 
device wants to register its interrupt it may call request_irq() that 
then calls setup_irq(). Now since SA_PERCPU_IRQ is not set by the device 
setup_irq() does not initialize desc->handler. Can that be fixed by 
adding SA_PERCPU_IRQ to irqflags in request_irq() or does that introduce 
problems at another place?

Christian

