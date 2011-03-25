From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:47 +0000
Subject: [patch 00/23] ia64: Full irq cleanup
Message-Id: <20110325204154.550907239@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

I took some time and went through the ia64 tree to sort out the
remaining issues aside of the irq_chip conversion.

The series is a bit longer now and fixes some odd ends first, which I
missed in the previous iteration.

It further cleans up the open coded irq_desc and status access all
over the place, which is necessary that the core code can drop all
the deprecated and compat stuff.

The last patches switch ia64 over to the generic show_interrupt()
implementation and do the final namespace cleanup for the irq_*
functions.

Thanks,

	tglx

