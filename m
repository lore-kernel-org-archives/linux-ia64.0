From: Bjorn Helgaas <bhelgaas@google.com>
Date: Sun, 12 Jul 2015 22:02:02 +0000
Subject: [PATCH 2/3] x86, irq: Clarify "No irq handler" message
Message-Id: <20150712220202.7166.22099.stgit@bhelgaas-glaptop2.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150712215559.7166.33068.stgit@bhelgaas-glaptop2.roam.corp.google.com>
In-Reply-To: <20150712215559.7166.33068.stgit@bhelgaas-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org

Previously we printed, e.g.,

  do_IRQ: 0.242 No irq handler for vector (irq -1)

There's no clue about what "0.242" means, and the IRQ number, which is the
important generic information used by drivers and /proc/interrupts, is
almost an afterthought.

Change the format to this:

  No handler for IRQ -1 (CPU 0 vector 0xf2)

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/kernel/irq.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/irq.c b/arch/x86/kernel/irq.c
index 2949c6e..3c6b069 100644
--- a/arch/x86/kernel/irq.c
+++ b/arch/x86/kernel/irq.c
@@ -224,9 +224,8 @@ __visible unsigned int __irq_entry do_IRQ(struct pt_regs *regs)
 		ack_APIC_irq();
 
 		if (irq != IRQ_RETRIGGERED) {
-			pr_emerg_ratelimited("%s: %d.%d No irq handler for vector (irq %d)\n",
-					     __func__, smp_processor_id(),
-					     vector, irq);
+			pr_emerg_ratelimited("No handler for IRQ %d (CPU %d vector %#x)\n",
+					     irq, smp_processor_id(), vector);
 		} else {
 			__this_cpu_write(vector_irq[vector], IRQ_UNDEFINED);
 		}

