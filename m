From: Bjorn Helgaas <bhelgaas@google.com>
Date: Sun, 12 Jul 2015 22:01:54 +0000
Subject: [PATCH 1/3] x86, irq: Rename VECTOR_UNDEFINED and VECTOR_RETRIGGERED to IRQ_*
Message-Id: <20150712220154.7166.48327.stgit@bhelgaas-glaptop2.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150712215559.7166.33068.stgit@bhelgaas-glaptop2.roam.corp.google.com>
In-Reply-To: <20150712215559.7166.33068.stgit@bhelgaas-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org

The per-cpu vector_irq[] table is indexed by CPU vector numbers, and each
entry contains an IRQ number.

Rename the special values VECTOR_UNDEFINED and VECTOR_RETRIGGERED to
IRQ_UNDEFINED and IRQ_RETRIGGERED to indicate that they are in the IRQ
number space, not the CPU vector number space.

No functional change.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/include/asm/hw_irq.h |    4 ++--
 arch/x86/kernel/apic/vector.c |   14 +++++++-------
 arch/x86/kernel/irq.c         |   12 ++++++------
 arch/x86/kernel/irqinit.c     |    4 ++--
 4 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/arch/x86/include/asm/hw_irq.h b/arch/x86/include/asm/hw_irq.h
index 6615032..b51a1ca 100644
--- a/arch/x86/include/asm/hw_irq.h
+++ b/arch/x86/include/asm/hw_irq.h
@@ -182,8 +182,8 @@ extern char irq_entries_start[];
 #define trace_irq_entries_start irq_entries_start
 #endif
 
-#define VECTOR_UNDEFINED	(-1)
-#define VECTOR_RETRIGGERED	(-2)
+#define IRQ_UNDEFINED	(-1)
+#define IRQ_RETRIGGERED	(-2)
 
 typedef int vector_irq_t[NR_VECTORS];
 DECLARE_PER_CPU(vector_irq_t, vector_irq);
diff --git a/arch/x86/kernel/apic/vector.c b/arch/x86/kernel/apic/vector.c
index 28eba2d..8ae84b4 100644
--- a/arch/x86/kernel/apic/vector.c
+++ b/arch/x86/kernel/apic/vector.c
@@ -170,7 +170,7 @@ next:
 
 		for_each_cpu_and(new_cpu, vector_cpumask, cpu_online_mask) {
 			if (per_cpu(vector_irq, new_cpu)[vector] >
-			    VECTOR_UNDEFINED)
+			    IRQ_UNDEFINED)
 				goto next;
 		}
 		/* Found one! */
@@ -232,7 +232,7 @@ static void clear_irq_vector(int irq, struct apic_chip_data *data)
 
 	vector = data->cfg.vector;
 	for_each_cpu_and(cpu, data->domain, cpu_online_mask)
-		per_cpu(vector_irq, cpu)[vector] = VECTOR_UNDEFINED;
+		per_cpu(vector_irq, cpu)[vector] = IRQ_UNDEFINED;
 
 	data->cfg.vector = 0;
 	cpumask_clear(data->domain);
@@ -247,7 +247,7 @@ static void clear_irq_vector(int irq, struct apic_chip_data *data)
 		     vector++) {
 			if (per_cpu(vector_irq, cpu)[vector] != irq)
 				continue;
-			per_cpu(vector_irq, cpu)[vector] = VECTOR_UNDEFINED;
+			per_cpu(vector_irq, cpu)[vector] = IRQ_UNDEFINED;
 			break;
 		}
 	}
@@ -429,12 +429,12 @@ static void __setup_vector_irq(int cpu)
 	/* Mark the free vectors */
 	for (vector = 0; vector < NR_VECTORS; ++vector) {
 		irq = per_cpu(vector_irq, cpu)[vector];
-		if (irq <= VECTOR_UNDEFINED)
+		if (irq <= IRQ_UNDEFINED)
 			continue;
 
 		data = apic_chip_data(irq_get_irq_data(irq));
 		if (!cpumask_test_cpu(cpu, data->domain))
-			per_cpu(vector_irq, cpu)[vector] = VECTOR_UNDEFINED;
+			per_cpu(vector_irq, cpu)[vector] = IRQ_UNDEFINED;
 	}
 	raw_spin_unlock(&vector_lock);
 }
@@ -553,7 +553,7 @@ asmlinkage __visible void smp_irq_move_cleanup_interrupt(void)
 
 		irq = __this_cpu_read(vector_irq[vector]);
 
-		if (irq <= VECTOR_UNDEFINED)
+		if (irq <= IRQ_UNDEFINED)
 			continue;
 
 		desc = irq_to_desc(irq);
@@ -589,7 +589,7 @@ asmlinkage __visible void smp_irq_move_cleanup_interrupt(void)
 			apic->send_IPI_self(IRQ_MOVE_CLEANUP_VECTOR);
 			goto unlock;
 		}
-		__this_cpu_write(vector_irq[vector], VECTOR_UNDEFINED);
+		__this_cpu_write(vector_irq[vector], IRQ_UNDEFINED);
 unlock:
 		raw_spin_unlock(&desc->lock);
 	}
diff --git a/arch/x86/kernel/irq.c b/arch/x86/kernel/irq.c
index 88b36648..2949c6e 100644
--- a/arch/x86/kernel/irq.c
+++ b/arch/x86/kernel/irq.c
@@ -223,12 +223,12 @@ __visible unsigned int __irq_entry do_IRQ(struct pt_regs *regs)
 	if (!handle_irq(irq, regs)) {
 		ack_APIC_irq();
 
-		if (irq != VECTOR_RETRIGGERED) {
+		if (irq != IRQ_RETRIGGERED) {
 			pr_emerg_ratelimited("%s: %d.%d No irq handler for vector (irq %d)\n",
 					     __func__, smp_processor_id(),
 					     vector, irq);
 		} else {
-			__this_cpu_write(vector_irq[vector], VECTOR_UNDEFINED);
+			__this_cpu_write(vector_irq[vector], IRQ_UNDEFINED);
 		}
 	}
 
@@ -489,7 +489,7 @@ void fixup_irqs(void)
 	for (vector = FIRST_EXTERNAL_VECTOR; vector < NR_VECTORS; vector++) {
 		unsigned int irr;
 
-		if (__this_cpu_read(vector_irq[vector]) <= VECTOR_UNDEFINED)
+		if (__this_cpu_read(vector_irq[vector]) <= IRQ_UNDEFINED)
 			continue;
 
 		irr = apic_read(APIC_IRR + (vector / 32 * 0x10));
@@ -502,12 +502,12 @@ void fixup_irqs(void)
 			raw_spin_lock(&desc->lock);
 			if (chip->irq_retrigger) {
 				chip->irq_retrigger(data);
-				__this_cpu_write(vector_irq[vector], VECTOR_RETRIGGERED);
+				__this_cpu_write(vector_irq[vector], IRQ_RETRIGGERED);
 			}
 			raw_spin_unlock(&desc->lock);
 		}
-		if (__this_cpu_read(vector_irq[vector]) != VECTOR_RETRIGGERED)
-			__this_cpu_write(vector_irq[vector], VECTOR_UNDEFINED);
+		if (__this_cpu_read(vector_irq[vector]) != IRQ_RETRIGGERED)
+			__this_cpu_write(vector_irq[vector], IRQ_UNDEFINED);
 	}
 }
 #endif
diff --git a/arch/x86/kernel/irqinit.c b/arch/x86/kernel/irqinit.c
index a3a5e15..fc1822d 100644
--- a/arch/x86/kernel/irqinit.c
+++ b/arch/x86/kernel/irqinit.c
@@ -52,7 +52,7 @@ static struct irqaction irq2 = {
 };
 
 DEFINE_PER_CPU(vector_irq_t, vector_irq) = {
-	[0 ... NR_VECTORS - 1] = VECTOR_UNDEFINED,
+	[0 ... NR_VECTORS - 1] = IRQ_UNDEFINED,
 };
 
 int vector_used_by_percpu_irq(unsigned int vector)
@@ -60,7 +60,7 @@ int vector_used_by_percpu_irq(unsigned int vector)
 	int cpu;
 
 	for_each_online_cpu(cpu) {
-		if (per_cpu(vector_irq, cpu)[vector] > VECTOR_UNDEFINED)
+		if (per_cpu(vector_irq, cpu)[vector] > IRQ_UNDEFINED)
 			return 1;
 	}
 

