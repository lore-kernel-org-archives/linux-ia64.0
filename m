From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Jun 2003 16:17:14 +0000
Subject: [PATCH] bitshift & warning fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2B/JsCI69OhZNC5r"
Message-Id: <marc-linux-ia64-105595346915718@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--2B/JsCI69OhZNC5r
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I think there are other 64p issues in other places, but we found this
one while doing 2.5 bringup on hardware.

Thanks,
Jesse

--2B/JsCI69OhZNC5r
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="fix-64p-2.5.69-ia64-bk.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1145  -> 1.1146 
#	arch/ia64/kernel/smpboot.c	1.34    -> 1.35   
#	include/asm-ia64/smp.h	1.9     -> 1.10   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/17	jbarnes@tomahawk.engr.sgi.com	1.1146
# partial fix for >32p support
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c	Tue Jun 17 14:46:03 2003
+++ b/arch/ia64/kernel/smpboot.c	Tue Jun 17 14:46:03 2003
@@ -451,7 +451,7 @@
 		sapicid = smp_boot_data.cpu_phys_id[i];
 		if (sapicid == boot_cpu_id)
 			continue;
-		phys_cpu_present_map |= (1 << cpu);
+		phys_cpu_present_map |= (1UL << cpu);
 		ia64_cpu_to_sapicid[cpu] = sapicid;
 		cpu++;
 	}
diff -Nru a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- a/include/asm-ia64/smp.h	Tue Jun 17 14:46:03 2003
+++ b/include/asm-ia64/smp.h	Tue Jun 17 14:46:03 2003
@@ -135,6 +135,7 @@
 
 extern int smp_call_function_single (int cpuid, void (*func) (void *info), void *info,
 				     int retry, int wait);
+extern void smp_build_cpu_map(void);
 extern void smp_send_reschedule (int cpu);
 extern void smp_send_reschedule_all (void);
 

--2B/JsCI69OhZNC5r--
