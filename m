From: Shaohua Li <shaohua.li@intel.com>
Date: Fri, 22 Feb 2008 07:28:26 +0000
Subject: [RFC] regression: 113134fcbca83619be4c68d0ca66db6093777b5d
Message-Id: <1203665306.8332.1.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

My tiger machine hangs since 2.6.23 with commit above. I always saw oops
in ia64_sal_physical_id_info(). In 2.6.22, if ia64_pal_logical_to_phys
returns UNIMPLENTED, ia64_sal_physical_id_info() isn't called. Below
patch fixes the issue. 

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 32ee597..6e0290b 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -878,13 +878,10 @@ identify_siblings(struct cpuinfo_ia64 *c)
 			printk(KERN_ERR
 				"ia64_pal_logical_to_phys failed with %ld\n",
 				status);
-			return;
 		}
-
-		info.overview_ppid = 0;
-		info.overview_cpp  = 1;
-		info.overview_tpc  = 1;
+		return;
 	}
+
 	if ((status = ia64_sal_physical_id_info(&pltid)) != PAL_STATUS_SUCCESS) {
 		printk(KERN_ERR "ia64_sal_pltid failed with %ld\n", status);
 		return;
@@ -892,9 +889,6 @@ identify_siblings(struct cpuinfo_ia64 *c)
 
 	c->socket_id =  (pltid << 8) | info.overview_ppid;
 
-	if (info.overview_cpp = 1 && info.overview_tpc = 1)
-		return;
-
 	c->cores_per_socket = info.overview_cpp;
 	c->threads_per_core = info.overview_tpc;
 	c->num_log = info.overview_num_log;


