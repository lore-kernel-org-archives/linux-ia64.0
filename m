From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 16 Jan 2004 20:15:22 +0000
Subject: [PATCH] fix cast in irq_lsapic.c
Message-Id: <20040116201522.GA15454@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that I've disabled dependency violation checking in my build of
binutils, I can see real warnings much more easily.

This patch just updates the cast in irq_lsapic.c to use the cpumask_t
type for the noop cast assignment to smp_affinity.

Jesse

=== arch/ia64/kernel/irq_lsapic.c 1.3 vs edited ==--- 1.3/arch/ia64/kernel/irq_lsapic.c	Fri Jul 19 07:02:26 2002
+++ edited/arch/ia64/kernel/irq_lsapic.c	Fri Jan 16 12:11:04 2004
@@ -34,5 +34,5 @@
 	.disable =	lsapic_noop,
 	.ack =		lsapic_noop,
 	.end =		lsapic_noop,
-	.set_affinity =	(void (*)(unsigned int, unsigned long)) lsapic_noop
+	.set_affinity =	(void (*)(unsigned int, cpumask_t)) lsapic_noop
 };

