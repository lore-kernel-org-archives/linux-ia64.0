From: Akinobu Mita <mita@miraclelinux.com>
Date: Tue, 14 Feb 2006 05:03:53 +0000
Subject: [patch 02/47] ia64: use cpu_set() instead of __set_bit()
Message-Id: <20060214050442.027415000@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060214050351.252615000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, Akinobu Mita <mita@miraclelinux.com>

__set_bit() --> cpu_set() cleanup

Signed-off-by: Akinobu Mita <mita@miraclelinux.com>
 arch/ia64/kernel/mca.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

Index: 2.6-rc/arch/ia64/kernel/mca.c
=================================--- 2.6-rc.orig/arch/ia64/kernel/mca.c
+++ 2.6-rc/arch/ia64/kernel/mca.c
@@ -69,6 +69,7 @@
 #include <linux/kernel.h>
 #include <linux/smp.h>
 #include <linux/workqueue.h>
+#include <linux/cpumask.h>
 
 #include <asm/delay.h>
 #include <asm/kdebug.h>
@@ -1430,7 +1431,7 @@ format_mca_init_stack(void *mca_data, un
 	ti->cpu = cpu;
 	p->thread_info = ti;
 	p->state = TASK_UNINTERRUPTIBLE;
-	__set_bit(cpu, &p->cpus_allowed);
+	cpu_set(cpu, p->cpus_allowed);
 	INIT_LIST_HEAD(&p->tasks);
 	p->parent = p->real_parent = p->group_leader = p;
 	INIT_LIST_HEAD(&p->children);

--
