From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 26 Jul 2004 23:39:12 +0000
Subject: Re: [PATCH] bug in irq_affinity_write_proc
Message-Id: <16645.38432.152087.784787@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40FE2EBE.4070007@jp.fujitsu.com>
In-Reply-To: <40FE2EBE.4070007@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 Jul 2004 12:25:44 +0900, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> said:

  >> How about using a bitset for pending_irq_redir?  Or at least a
  >> byte-array instead of a word-array.

  Kenji> I modified my patch to use bitset for pending_irq_redir.
  Kenji> Please take a look.

OK, I checked that in now, with an additional small change which I
think improves readability a bit (see below).

Thanks,

	--david

--
diff -Nru a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c	2004-07-26 16:37:58 -07:00
+++ b/arch/ia64/kernel/irq.c	2004-07-26 16:37:58 -07:00
@@ -1029,12 +1029,13 @@
 	/* note - we hold desc->lock */
 	cpumask_t tmp;
 	irq_desc_t *desc = irq_descp(irq);
-	int irq_with_redir = test_bit(irq, pending_irq_redir) ? (irq | IA64_IRQ_REDIRECTED) : irq;
+	int redir = test_bit(irq, pending_irq_redir);
 
 	if (!cpus_empty(pending_irq_cpumask[irq])) {
 		cpus_and(tmp, pending_irq_cpumask[irq], cpu_online_map);
 		if (unlikely(!cpus_empty(tmp))) {
-			desc->handler->set_affinity(irq_with_redir, pending_irq_cpumask[irq]);
+			desc->handler->set_affinity(irq | (redir ? IA64_IRQ_REDIRECTED : 0),
+						    pending_irq_cpumask[irq]);
 		}
 		cpus_clear(pending_irq_cpumask[irq]);
 	}
