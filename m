From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 22 Apr 2004 02:20:24 +0000
Subject: RE: [RFC] ACPI IRQ proposal
Message-Id: <MDEEKOKJPMPMKGHIFAMAAEELDNAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403231537.14505.bjorn.helgaas@hp.com>
In-Reply-To: <200403231537.14505.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Bjorn,

It will be possible that iosapic_register_intr() runs on multiple CPUs in
parallel when your patch is applied. But I think current
iosapic_register_int()
doesn't take care of this. If iosapic_register_intr() is called for one gsi
on
multiple CPUs in parallel, two or more vectors might be assigned to one
gsi. A following patch is a sample patch to fix this issue. (This patch is
not
tested yet.)

Thanks,
Kenji Kaneshige

---

 linux-2.6.6-rc1-kanesige/arch/ia64/kernel/iosapic.c |    5 +++++
 1 files changed, 5 insertions(+)

diff -puN arch/ia64/kernel/iosapic.c~lock_iosapic_register_intr
arch/ia64/kernel/iosapic.c
--- linux-2.6.6-rc1/arch/ia64/kernel/iosapic.c~lock_iosapic_register_intr
2004-04-21 14:58:25.229102461 +0900
+++ linux-2.6.6-rc1-kanesige/arch/ia64/kernel/iosapic.c	2004-04-21
15:44:04.719878795 +0900
@@ -499,9 +499,12 @@ int
 iosapic_register_intr (unsigned int gsi,
 		       unsigned long polarity, unsigned long trigger)
 {
+	unsigned long flags;
 	int vector;
 	unsigned int dest = (ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff;

+	spin_lock_irqsave(&iosapic_lock, flags);
+
 	vector = gsi_to_vector(gsi);
 	if (vector < 0)
 		vector = assign_irq_vector(AUTO_ASSIGN);
@@ -509,6 +512,8 @@ iosapic_register_intr (unsigned int gsi,
 	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
 		      polarity, trigger);

+	spin_unlock_irqrestore(&iosapic_lock, flags);
+
 	printk(KERN_INFO "GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
 	       gsi, (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 	       (trigger = IOSAPIC_EDGE ? "edge" : "level"), dest, vector);

_

