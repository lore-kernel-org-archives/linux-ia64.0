From: Jack Steiner <steiner@sgi.com>
Date: Wed, 05 Nov 2003 14:44:26 +0000
Subject: Fix compiler warning in arch/ia64/kernel/irq_lsapic.c
Message-Id: <marc-linux-ia64-106804372231040@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Not sure if you are taking fixes like this right now, but...

This fixes a compoiler warning that occurs when NR_CPUS is > 64.



--- linux_base/arch/ia64/kernel/irq_lsapic.c	Wed Nov  5 08:39:39 2003
+++ linux/arch/ia64/kernel/irq_lsapic.c	Wed Nov  5 08:38:27 2003
@@ -34,5 +34,5 @@
 	.disable =	lsapic_noop,
 	.ack =		lsapic_noop,
 	.end =		lsapic_noop,
-	.set_affinity =	(void (*)(unsigned int, unsigned long)) lsapic_noop
+	.set_affinity =	(void (*)(unsigned int, cpumask_t)) lsapic_noop
 };



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


