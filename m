From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Tue, 04 Oct 2005 23:35:31 +0000
Subject: [Patch] fix siblings field value in /proc/cpuinfo
Message-Id: <20051004163531.A30098@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony, Please apply the appended patch.

thanks,
suresh

--
Fix the "siblings" field value in /proc/cpuinfo so that it now shows the
number of siblings as seen by OS, instead of what is available from
hardware perspective.

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>

diff -pNru linux-2.6.14-rc3/arch/ia64/kernel/setup.c linux-2.6.14-rc3-core/arch/ia64/kernel/setup.c
--- linux-2.6.14-rc3/arch/ia64/kernel/setup.c	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3-core/arch/ia64/kernel/setup.c	2005-10-03 16:29:44.000000000 -0700
@@ -526,7 +526,7 @@ show_cpuinfo (struct seq_file *m, void *
 		   c->itc_freq / 1000000, c->itc_freq % 1000000,
 		   lpj*HZ/500000, (lpj*HZ/5000) % 100);
 #ifdef CONFIG_SMP
-	seq_printf(m, "siblings   : %u\n", c->num_log);
+	seq_printf(m, "siblings   : %u\n", cpus_weight(cpu_core_map[cpunum]));
 	if (c->threads_per_core > 1 || c->cores_per_socket > 1)
 		seq_printf(m,
 		   	   "physical id: %u\n"
