From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 26 Jul 2004 03:25:44 +0000
Subject: Re: [PATCH] bug in irq_affinity_write_proc
Message-Id: <410479B8.4070800@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40FE2EBE.4070007@jp.fujitsu.com>
In-Reply-To: <40FE2EBE.4070007@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> How about using a bitset for pending_irq_redir?  Or at least a
> byte-array instead of a word-array.

I modified my patch to use bitset for pending_irq_redir.
Please take a look.

Thanks,
Kenji Kaneshige


Writing 'R' or 'r' character to /proc/irq/<IRQ#>/smp_affinity
cause a kernel Oops. The following patch fixes this issue.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.8-rc2-kanesige/arch/ia64/kernel/irq.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff -puN arch/ia64/kernel/irq.c~fix_irq_affinity_write_proc arch/ia64/kernel/irq.c
--- linux-2.6.8-rc2/arch/ia64/kernel/irq.c~fix_irq_affinity_write_proc	2004-07-26 10:43:03.000000000 +0900
+++ linux-2.6.8-rc2-kanesige/arch/ia64/kernel/irq.c	2004-07-26 10:54:00.000000000 +0900
@@ -88,6 +88,7 @@ irq_desc_t _irq_desc[NR_IRQS] __cachelin
  * This is updated when the user sets irq affinity via /proc
  */
 cpumask_t    __cacheline_aligned pending_irq_cpumask[NR_IRQS];
+static unsigned long pending_irq_redir[BITS_TO_LONGS(NR_IRQS)];
 
 #ifdef CONFIG_IA64_GENERIC
 irq_desc_t * __ia64_irq_desc (unsigned int irq)
@@ -973,6 +974,7 @@ static int irq_affinity_write_proc (stru
 	int prelen;
 	irq_desc_t *desc = irq_descp(irq);
 	unsigned long flags;
+	int redir = 0;
 
 	if (!desc->handler->set_affinity)
 		return -EIO;
@@ -995,7 +997,7 @@ static int irq_affinity_write_proc (stru
 	prelen = 0;
 	if (tolower(*rbuf) = 'r') {
 		prelen = strspn(rbuf, "Rr ");
-		irq |= IA64_IRQ_REDIRECTED;
+		redir++;
 	}
 
 	err = cpumask_parse(buffer+prelen, count-prelen, new_value);
@@ -1013,6 +1015,10 @@ static int irq_affinity_write_proc (stru
 
 	spin_lock_irqsave(&desc->lock, flags);
 	pending_irq_cpumask[irq] = new_value;
+	if (redir)
+		set_bit(irq, pending_irq_redir);
+	else
+		clear_bit(irq, pending_irq_redir);
 	spin_unlock_irqrestore(&desc->lock, flags);
 
 	return full_count;
@@ -1023,11 +1029,12 @@ void move_irq(int irq)
 	/* note - we hold desc->lock */
 	cpumask_t tmp;
 	irq_desc_t *desc = irq_descp(irq);
+	int irq_with_redir = test_bit(irq, pending_irq_redir) ? (irq | IA64_IRQ_REDIRECTED) : irq;
 
 	if (!cpus_empty(pending_irq_cpumask[irq])) {
 		cpus_and(tmp, pending_irq_cpumask[irq], cpu_online_map);
 		if (unlikely(!cpus_empty(tmp))) {
-			desc->handler->set_affinity(irq, pending_irq_cpumask[irq]);
+			desc->handler->set_affinity(irq_with_redir, pending_irq_cpumask[irq]);
 		}
 		cpus_clear(pending_irq_cpumask[irq]);
 	}

_


