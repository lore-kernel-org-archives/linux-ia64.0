From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Fri, 13 Jul 2001 18:59:11 +0000
Subject: [Linux-ia64] [PATCH] fix IRQ affinity
Message-Id: <marc-linux-ia64-105590693005851@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

IRQ affinity doesn't work due to missing of cpu_physical_id().
This patch fixes it.

--- arch/ia64/kernel/iosapic.c~ Fri Jul 13 12:29:18 2001
+++ arch/ia64/kernel/iosapic.c  Fri Jul 13 11:56:20 2001
@@ -215,7 +215,7 @@
        if (!mask || irq >= IA64_NUM_VECTORS)
                return;

-       dest = ffz(~mask);
+       dest = cpu_physical_id(ffz(~mask));

        pin = iosapic_irq[irq].pin;
        addr = iosapic_irq[irq].addr;


Regards,

---
Kimio Suganuma
NEC Systems, Inc.
k-suganuma@mvj.biglobe.ne.jp


