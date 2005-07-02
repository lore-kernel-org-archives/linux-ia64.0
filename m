From: Keith Owens <kaos@sgi.com>
Date: Sat, 02 Jul 2005 06:26:49 +0000
Subject: [patch 2.6.13-rc1] Make ia64 die() preempt safe
Message-Id: <11315.1120285609@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make ia64 die() preempt safe.

SIgned-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/traps.c
=================================--- linux.orig/arch/ia64/kernel/traps.c	2005-07-01 19:25:06.388160657 +1000
+++ linux/arch/ia64/kernel/traps.c	2005-07-01 19:25:10.413553343 +1000
@@ -90,14 +90,16 @@ die (const char *str, struct pt_regs *re
 		.lock_owner_depth =	0
 	};
 	static int die_counter;
+	int cpu = get_cpu();
 
-	if (die.lock_owner != smp_processor_id()) {
+	if (die.lock_owner != cpu) {
 		console_verbose();
 		spin_lock_irq(&die.lock);
-		die.lock_owner = smp_processor_id();
+		die.lock_owner = cpu;
 		die.lock_owner_depth = 0;
 		bust_spinlocks(1);
 	}
+	put_cpu();
 
 	if (++die.lock_owner_depth < 3) {
 		printk("%s[%d]: %s %ld [%d]\n",

