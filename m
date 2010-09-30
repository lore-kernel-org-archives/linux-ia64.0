From: Kyle McMartin <kyle@mcmartin.ca>
Date: Thu, 30 Sep 2010 02:41:03 +0000
Subject: Re: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <20100930024103.GB2604@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de>
 <20100930012641.GA2604@bombadil.infradead.org>
In-Reply-To: <20100930012641.GA2604@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kyle McMartin <kyle@mcmartin.ca>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-alpha@vger.kernel.org, linux-cris-kernel@axis.com, Haavard Skinnemoen <hskinnemoen@atmel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, linux-parisc@vger.kernel.org, Chris Zankel <chris@zankel.net>, linux-arch@vger.kernel.org

On Wed, Sep 29, 2010 at 09:26:41PM -0400, Kyle McMartin wrote:
> I'd appreciate a second pair of eyes, and if it's ok, I'll clean it up
> and submit it.
> 

Let's do h8300 while we're at it, since that also /looks/ trivial...
(probably famous last words.)

No idea if it's edge or level or what, but given the handlers that would
be called in the __do_IRQ patch, handle_edge_irq seems most sensible.

Executive summary: kill implied .ack = NULL, rename enable to unmask,
kill empty .end since dummy_irq_chip.end will suit us fine. Kill some
unneeded irq_desc initializers that are also implicit...

Again, if someone could build/boot/whatever test this, that would be
fantastic, and I'll add their Tested-by and submit.

--kyle

---
 irq.c |   16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/arch/h8300/kernel/irq.c b/arch/h8300/kernel/irq.c
index c25dc2c..acdbc07 100644
--- a/arch/h8300/kernel/irq.c
+++ b/arch/h8300/kernel/irq.c
@@ -50,10 +50,6 @@ static void h8300_disable_irq(unsigned int irq)
 		IER_REGS &= ~(1 << (irq - EXT_IRQ0));
 }
 
-static void h8300_end_irq(unsigned int irq)
-{
-}
-
 static unsigned int h8300_startup_irq(unsigned int irq)
 {
 	if (is_ext_irq(irq))
@@ -75,10 +71,9 @@ struct irq_chip h8300irq_chip = {
 	.name		= "H8300-INTC",
 	.startup	= h8300_startup_irq,
 	.shutdown	= h8300_shutdown_irq,
-	.enable		= h8300_enable_irq,
+	.unmask		= h8300_enable_irq,
+	.mask		= h8300_disable_irq,
 	.disable	= h8300_disable_irq,
-	.ack		= NULL,
-	.end		= h8300_end_irq,
 };
 
 #if defined(CONFIG_RAMKERNEL)
@@ -161,17 +156,14 @@ void __init init_IRQ(void)
 	setup_vector();
 
 	for (c = 0; c < NR_IRQS; c++) {
-		irq_desc[c].status = IRQ_DISABLED;
-		irq_desc[c].action = NULL;
-		irq_desc[c].depth = 1;
-		irq_desc[c].chip = &h8300irq_chip;
+		set_irq_chip_and_handler(c, &h8300_irq_chip, handle_edge_irq);
 	}
 }
 
 asmlinkage void do_IRQ(int irq)
 {
 	irq_enter();
-	__do_IRQ(irq);
+	generic_handle_irq(irq);
 	irq_exit();
 }
 
