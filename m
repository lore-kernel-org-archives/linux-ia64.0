From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Thu, 28 Aug 2003 05:32:59 +0000
Subject: Fix for nosmp (2.6)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="5vNYLRcllDrimb99"
Message-Id: <marc-linux-ia64-106204881928311@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Patch should be self-explanatory.

Thanks,
Matt


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="smpboot.diff"

--- linux-2.6.0-test4/arch/ia64/kernel/smpboot.c.orig	2003-08-28 13:34:27.000000000 +1000
+++ linux-2.6.0-test4/arch/ia64/kernel/smpboot.c	2003-08-28 15:23:15.000000000 +1000
@@ -534,8 +534,8 @@
 		printk(KERN_INFO "SMP mode deactivated.\n");
 		cpus_clear(cpu_online_map);
 		cpus_clear(phys_cpu_present_map);
-		cpu_set(1, cpu_online_map);
-		cpu_set(1, phys_cpu_present_map);
+		cpu_set(0, cpu_online_map);
+		cpu_set(0, phys_cpu_present_map);
 		return;
 	}
 }

--5vNYLRcllDrimb99--
