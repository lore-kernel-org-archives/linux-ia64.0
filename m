From: Jack Steiner <steiner@sgi.com>
Date: Wed, 02 Mar 2005 02:52:03 +0000
Subject: [PATCH 2/2] - New chipset support for SN platform
Message-Id: <20050302025203.GA17854@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Here are 2 additional patches for supporting the next SGI
chipset (shub2).

The patches do the following:

patch 1 of 2:
	- add new parameters to a platform-specific SAL 
	  call to retrieve addition chipset specific info.

	- change partition_coherence_id() so that it works
	  on platforms using the new chipset.

patch 2 of 2:
	- move a number of fields out of the SN pda & into 
	  per-cpu data. The pda is ugly & will be deleted. 
	  This is a first step.  Additional patches will follow.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---------------------------------------------------------------------------


Index: linux/include/asm-ia64/sn/pda.h
=================================--- linux.orig/include/asm-ia64/sn/pda.h	2005-03-01 18:58:47.527670247 -0600
+++ linux/include/asm-ia64/sn/pda.h	2005-03-01 18:59:26.640493554 -0600
@@ -37,11 +37,6 @@ typedef struct pda_s {
 	 * Support for SN LEDs
 	 */
 	volatile short	*led_address;
-	u16		nasid_bitmask;
-	u8		shub2;
-	u8		nasid_shift;
-	u8		as_shift;
-	u8		shub_1_1_found;
 	u8		led_state;
 	u8		hb_state;	/* supports blinking heartbeat leds */
 	unsigned int	hb_count;
@@ -84,12 +79,4 @@ DECLARE_PER_CPU(struct pda_s, pda_percpu
 
 #define pdacpu(cpu)	(&per_cpu(pda_percpu, cpu))
 
-/*
- * Use this macro to test if shub 1.1 wars should be enabled
- */
-#define enable_shub_wars_1_1()	(pda->shub_1_1_found)
-
-#define is_shub2()	(pda->shub2)
-#define is_shub1()	(pda->shub2 = 0)
-
 #endif /* _ASM_IA64_SN_PDA_H */
Index: linux/include/asm-ia64/sn/arch.h
=================================--- linux.orig/include/asm-ia64/sn/arch.h	2005-03-01 18:58:47.527670247 -0600
+++ linux/include/asm-ia64/sn/arch.h	2005-03-01 18:59:26.641470105 -0600
@@ -12,10 +12,34 @@
 #define _ASM_IA64_SN_ARCH_H
 
 #include <asm/types.h>
+#include <asm/percpu.h>
 #include <asm/sn/types.h>
 #include <asm/sn/sn_cpuid.h>
 
 /*
+ * The following defines attributes of the HUB chip. These attributes are
+ * frequently referenced. They are kept in the per-cpu data areas of each cpu.
+ * They are kept together in a struct to minimize cache misses.
+ */
+struct sn_hub_info_s {
+	u8 shub2;
+	u8 nasid_shift;
+	u8 as_shift;
+	u8 shub_1_1_found;
+	u16 nasid_bitmask;
+};
+DECLARE_PER_CPU(struct sn_hub_info_s, __sn_hub_info);
+#define sn_hub_info 	(&__get_cpu_var(__sn_hub_info))
+#define is_shub2()	(sn_hub_info->shub2)
+#define is_shub1()	(sn_hub_info->shub2 = 0)
+
+/*
+ * Use this macro to test if shub 1.1 wars should be enabled
+ */
+#define enable_shub_wars_1_1()	(sn_hub_info->shub_1_1_found)
+
+
+/*
  * This is the maximum number of nodes that can be part of a kernel.
  * Effectively, it's the maximum number of compact node ids (cnodeid_t).
  * This is not necessarily the same as MAX_NASIDS.
Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2005-03-01 18:59:07.726652496 -0600
+++ linux/arch/ia64/sn/kernel/setup.c	2005-03-01 19:00:19.840066076 -0600
@@ -67,9 +67,11 @@ extern void snidle(int);
 extern unsigned char acpi_kbd_controller_present;
 
 unsigned long sn_rtc_cycles_per_second;
-
 EXPORT_SYMBOL(sn_rtc_cycles_per_second);
 
+DEFINE_PER_CPU(struct sn_hub_info_s, __sn_hub_info);
+EXPORT_PER_CPU_SYMBOL(__sn_hub_info);
+
 partid_t sn_partid = -1;
 EXPORT_SYMBOL(sn_partid);
 char sn_system_serial_number_string[128];
@@ -242,7 +244,7 @@ static void __init sn_check_for_wars(voi
 	} else {
 		for_each_online_node(cnode) {
 			if (is_shub_1_1(cnodeid_to_nasid(cnode)))
-				shub_1_1_found = 1;
+				sn_hub_info->shub_1_1_found = 1;
 		}
 	}
 }
@@ -437,11 +439,11 @@ void __init sn_cpu_init(void)
 	static int wars_have_been_checked;
 
 	memset(pda, 0, sizeof(pda));
-	if (ia64_sn_get_sn_info(0, &pda->shub2, &pda->nasid_bitmask, &pda->nasid_shift, 
+	if (ia64_sn_get_sn_info(0, &sn_hub_info->shub2, &sn_hub_info->nasid_bitmask, &sn_hub_info->nasid_shift,
 				&sn_system_size, &sn_sharing_domain_size, &sn_partition_id,
 				&sn_coherency_id, &sn_region_size))
 		BUG();
-	pda->as_shift = pda->nasid_shift - 2;
+	sn_hub_info->as_shift = sn_hub_info->nasid_shift - 2;
 
 	/*
 	 * The boot cpu makes this call again after platform initialization is
@@ -490,7 +492,7 @@ void __init sn_cpu_init(void)
 		sn_check_for_wars();
 		wars_have_been_checked = 1;
 	}
-	pda->shub_1_1_found = shub_1_1_found;
+	sn_hub_info->shub_1_1_found = shub_1_1_found;
 
 	/*
 	 * Set up addresses of PIO/MEM write status registers.
Index: linux/include/asm-ia64/sn/addrs.h
=================================--- linux.orig/include/asm-ia64/sn/addrs.h	2005-03-01 18:58:47.528646798 -0600
+++ linux/include/asm-ia64/sn/addrs.h	2005-03-01 18:59:26.658071474 -0600
@@ -11,6 +11,7 @@
 
 #include <asm/percpu.h>
 #include <asm/sn/types.h>
+#include <asm/sn/arch.h>
 #include <asm/sn/pda.h>
 
 /*
@@ -57,9 +58,9 @@
 /*
  * Define basic shift & mask constants for manipulating NASIDs and AS values.
  */
-#define NASID_BITMASK		(pda->nasid_bitmask)
-#define NASID_SHIFT		(pda->nasid_shift)
-#define AS_SHIFT		(pda->as_shift)
+#define NASID_BITMASK		(sn_hub_info->nasid_bitmask)
+#define NASID_SHIFT		(sn_hub_info->nasid_shift)
+#define AS_SHIFT		(sn_hub_info->as_shift)
 #define AS_BITMASK		0x3UL
 
 #define NASID_MASK              ((u64)NASID_BITMASK << NASID_SHIFT)
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


