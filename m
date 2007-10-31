From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 31 Oct 2007 11:06:13 +0000
Subject: [PATCH] ia64: Clean up /proc/interrupts output
Message-Id: <472861A5.1010403@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Clean up /proc/interrupts output on the system that has 10 or more
CPUs.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/irq.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

Index: linux-2.6.24-rc1/arch/ia64/kernel/irq.c
=================================--- linux-2.6.24-rc1.orig/arch/ia64/kernel/irq.c
+++ linux-2.6.24-rc1/arch/ia64/kernel/irq.c
@@ -61,9 +61,11 @@ int show_interrupts(struct seq_file *p, 
 	unsigned long flags;
 
 	if (i = 0) {
-		seq_printf(p, "           ");
+		char cpuname[16];
+		seq_printf(p, "     ");
 		for_each_online_cpu(j) {
-			seq_printf(p, "CPU%d       ",j);
+			snprintf(cpuname, 10, "CPU%d", j);
+			seq_printf(p, "%10s ", cpuname);
 		}
 		seq_putc(p, '\n');
 	}

