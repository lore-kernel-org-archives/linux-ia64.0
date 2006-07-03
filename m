From: Jes Sorensen <jes@sgi.com>
Date: Mon, 03 Jul 2006 11:36:42 +0000
Subject: Re: [RFC][patch 09/44] IA64: Use the new IRQF_ constansts
Message-Id: <yq0r712hqd1.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060701145211.856500000@cruncher.tec.linutronix.de>
	<20060701145224.258259000@cruncher.tec.linutronix.de>
In-Reply-To: <20060701145224.258259000@cruncher.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org, torvalds@osdl.org

>>>>> "Thomas" = Thomas Gleixner <tglx@linutronix.de> writes:

Thomas> Use the new IRQF_ constants and remove the SA_INTERRUPT define

Hi Thomas,

You forgot to remove the duplicate define of IRQF_PERCPU from
include/asm-ia64/irq.h when you introduced the one in
include/linux/interrupt.h.

On ia64, without this patch, building Linus' git tree spits out
compile warnings left right and center (harmless ones though).

I checked the ia64 code and I don't see any place that actually relied
on the old define or hardcoded it in asm, but I could be wrong of
course.

It compiles, it boots, Enterprise Ready<tm>!

Linus and/or Tony, please apply.

Cheers,
Jes

Remove duplicate define of IRQF_PERCPU which is now defined in
include/linux/interrupt.h

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 include/asm-ia64/irq.h |    2 --
 1 file changed, 2 deletions(-)

Index: linux-2.6/include/asm-ia64/irq.h
=================================--- linux-2.6.orig/include/asm-ia64/irq.h
+++ linux-2.6/include/asm-ia64/irq.h
@@ -14,8 +14,6 @@
 #define NR_IRQS		256
 #define NR_IRQ_VECTORS	NR_IRQS
 
-#define IRQF_PERCPU	0x02000000
-
 static __inline__ int
 irq_canonicalize (int irq)
 {
