From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Jun 2003 16:18:19 +0000
Subject: [PATCH] mark_idle fixes for sn2
MIME-Version: 1
Content-Type: multipart/mixed; boundary="OBd5C1Lgu00Gd/Tn"
Message-Id: <marc-linux-ia64-105595346915722@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--OBd5C1Lgu00Gd/Tn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Small patch to fixup the new mark_idle() stuff for sn2.

Thanks,
Jesse

--OBd5C1Lgu00Gd/Tn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mark-idle-fixes-2.5.69-ia64-bk.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1147  -> 1.1148 
#	arch/ia64/sn/kernel/Makefile	1.13    -> 1.14   
#	arch/ia64/sn/kernel/setup.c	1.14    -> 1.15   
#	arch/ia64/sn/kernel/idle.c	1.1     -> 1.2    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/17	jbarnes@tomahawk.engr.sgi.com	1.1148
# mark_idle fixes
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
--- a/arch/ia64/sn/kernel/Makefile	Tue Jun 17 14:46:36 2003
+++ b/arch/ia64/sn/kernel/Makefile	Tue Jun 17 14:46:36 2003
@@ -9,7 +9,8 @@
 
 EXTRA_CFLAGS := -DLITTLE_ENDIAN
 
-obj-y				:= probe.o setup.o sv.o bte.o irq.o mca.o sn2/
+obj-y				:= probe.o setup.o sv.o bte.o irq.o mca.o \
+				   idle.o sn2/
 
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
 obj-$(CONFIG_MODULES)           += sn_ksyms.o
diff -Nru a/arch/ia64/sn/kernel/idle.c b/arch/ia64/sn/kernel/idle.c
--- a/arch/ia64/sn/kernel/idle.c	Tue Jun 17 14:46:36 2003
+++ b/arch/ia64/sn/kernel/idle.c	Tue Jun 17 14:46:36 2003
@@ -12,7 +12,7 @@
 
 void snidle(int state) {
 	if (state) {
-		if (pda.idle_flag == 0) {
+		if (pda->idle_flag == 0) {
 			/* 
 			 * Turn the activity LED off.
 			 */
@@ -24,13 +24,13 @@
 			SIMULATOR_SLEEP();
 #endif
 
-		pda.idle_flag = 1;
+		pda->idle_flag = 1;
 	} else {
 		/* 
 		 * Turn the activity LED on.
 		 */
 		set_led_bits(LED_CPU_ACTIVITY, LED_CPU_ACTIVITY);
 
-		pda.idle_flag = 0;
+		pda->idle_flag = 0;
 	}
 }
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Tue Jun 17 14:46:36 2003
+++ b/arch/ia64/sn/kernel/setup.c	Tue Jun 17 14:46:36 2003
@@ -75,11 +75,13 @@
 
 #define pxm_to_nasid(pxm) ((pxm)<<1)
 
+#define MAX_PHYS_MEMORY		(1UL << 49)     /* 1 TB */
+
 extern void bte_init_node (nodepda_t *, cnodeid_t);
 extern void bte_init_cpu (void);
-extern void sn_timer_init (void);
+extern void sn_timer_init(void);
 extern void (*ia64_mark_idle)(int);
-void snidle(int);
+extern void snidle(int);
 
 unsigned long sn_rtc_cycles_per_second;   
 
@@ -296,21 +298,20 @@
 	 */
 	sn_check_for_wars();
 
+	ia64_mark_idle = &snidle;
+
 	/* 
 	 * For the bootcpu, we do this here. All other cpus will make the
 	 * call as part of cpu_init in slave cpu initialization.
 	 */
 	sn_cpu_init();
 
-
 #ifdef CONFIG_SMP
 	init_smp_config();
 #endif
 	screen_info = sn_screen_info;
 
 	sn_timer_init();
-
-	ia64_mark_idle = &snidle;
 }
 
 /**
@@ -437,20 +438,4 @@
 	}
 
 	bte_init_cpu();
-}
-
-void snidle(int idleness)
-{
-	if (!idleness) {
-		if (pda->idle_flag == 0) {
-			set_led_bits(0, LED_CPU_ACTIVITY);
-		}
-
-		pda->idle_flag = 1;
-	}
-	else {
-		set_led_bits(LED_CPU_ACTIVITY, LED_CPU_ACTIVITY);
-
-		pda->idle_flag = 0;
-	}
 }

--OBd5C1Lgu00Gd/Tn--
