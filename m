From: Jack Steiner <steiner@sgi.com>
Date: Wed, 01 Dec 2004 20:39:28 +0000
Subject: SN support for new chipset - [2 of 4]
Message-Id: <20041201203928.GA26271@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Add support for a future SGI chipset (shub2).
(All code is SN-specific)

This patch adds the addresses of shub2 MMRS to the shub_mmr
header file. During boot, a SAL call is made to determine the 
type of the shub. Platform initialization sets the appropriate
MMR addresses for the platform. 

A new macro (is_shub1() & is_shub2()) can be used at runtime to 
determine the type of the shub.






Index: linux/include/asm-ia64/sn/shub_mmr.h
=================================--- linux.orig/include/asm-ia64/sn/shub_mmr.h	2004-12-01 12:47:56.111758858 -0600
+++ linux/include/asm-ia64/sn/shub_mmr.h	2004-12-01 13:28:31.015274921 -0600
@@ -14,117 +14,96 @@
 /*                        Register "SH_IPI_INT"                         */
 /*               SHub Inter-Processor Interrupt Registers               */
 /* ================================== */
-#define SH_IPI_INT                               0x0000000110000380UL
-#define SH_IPI_INT_MASK                          0x8ff3ffffffefffffUL
-#define SH_IPI_INT_INIT                          0x0000000000000000UL
+#define SH1_IPI_INT                               0x0000000110000380
+#define SH2_IPI_INT                               0x0000000010000380
 
 /*   SH_IPI_INT_TYPE                                                    */
 /*   Description:  Type of Interrupt: 0=INT, 2=PMI, 4=NMI, 5=INIT       */
 #define SH_IPI_INT_TYPE_SHFT                     0
-#define SH_IPI_INT_TYPE_MASK                     0x0000000000000007UL
+#define SH_IPI_INT_TYPE_MASK                     0x0000000000000007
 
 /*   SH_IPI_INT_AGT                                                     */
 /*   Description:  Agent, must be 0 for SHub                            */
 #define SH_IPI_INT_AGT_SHFT                      3
-#define SH_IPI_INT_AGT_MASK                      0x0000000000000008UL
+#define SH_IPI_INT_AGT_MASK                      0x0000000000000008
 
 /*   SH_IPI_INT_PID                                                     */
 /*   Description:  Processor ID, same setting as on targeted McKinley  */
 #define SH_IPI_INT_PID_SHFT                      4
-#define SH_IPI_INT_PID_MASK                      0x00000000000ffff0UL
+#define SH_IPI_INT_PID_MASK                      0x00000000000ffff0
 
 /*   SH_IPI_INT_BASE                                                    */
 /*   Description:  Optional interrupt vector area, 2MB aligned          */
 #define SH_IPI_INT_BASE_SHFT                     21
-#define SH_IPI_INT_BASE_MASK                     0x0003ffffffe00000UL
+#define SH_IPI_INT_BASE_MASK                     0x0003ffffffe00000
 
 /*   SH_IPI_INT_IDX                                                     */
 /*   Description:  Targeted McKinley interrupt vector                   */
 #define SH_IPI_INT_IDX_SHFT                      52
-#define SH_IPI_INT_IDX_MASK                      0x0ff0000000000000UL
+#define SH_IPI_INT_IDX_MASK                      0x0ff0000000000000
 
 /*   SH_IPI_INT_SEND                                                    */
 /*   Description:  Send Interrupt Message to PI, This generates a puls  */
 #define SH_IPI_INT_SEND_SHFT                     63
-#define SH_IPI_INT_SEND_MASK                     0x8000000000000000UL
+#define SH_IPI_INT_SEND_MASK                     0x8000000000000000
 
 /* ================================== */
 /*                     Register "SH_EVENT_OCCURRED"                     */
 /*                    SHub Interrupt Event Occurred                     */
 /* ================================== */
-#define SH_EVENT_OCCURRED                        0x0000000110010000UL
-#define SH_EVENT_OCCURRED_ALIAS                  0x0000000110010008UL
+#define SH1_EVENT_OCCURRED                        0x0000000110010000
+#define SH1_EVENT_OCCURRED_ALIAS                  0x0000000110010008
+#define SH2_EVENT_OCCURRED                        0x0000000010010000
+#define SH2_EVENT_OCCURRED_ALIAS                  0x0000000010010008
 
 /* ================================== */
 /*                     Register "SH_PI_CAM_CONTROL"                     */
 /*                      CRB CAM MMR Access Control                      */
 /* ================================== */
-#ifndef __ASSEMBLY__
-#define SH_PI_CAM_CONTROL                        0x0000000120050300UL
-#else
-#define SH_PI_CAM_CONTROL                        0x0000000120050300
-#endif
+#define SH1_PI_CAM_CONTROL                        0x0000000120050300
 
 /* ================================== */
 /*                        Register "SH_SHUB_ID"                         */
 /*                            SHub ID Number                            */
 /* ================================== */
-#define SH_SHUB_ID                               0x0000000110060580UL
-#define SH_SHUB_ID_REVISION_SHFT                 28
-#define SH_SHUB_ID_REVISION_MASK                 0x00000000f0000000
-
-/* ================================== */
-/*                         Register "SH_PTC_0"                          */
-/*       Puge Translation Cache Message Configuration Information       */
-/* ================================== */
-#define SH_PTC_0                                 0x00000001101a0000UL
-#define SH_PTC_1                                 0x00000001101a0080UL
+#define SH1_SHUB_ID                               0x0000000110060580
+#define SH1_SHUB_ID_REVISION_SHFT                 28
+#define SH1_SHUB_ID_REVISION_MASK                 0x00000000f0000000
 
 /* ================================== */
 /*                          Register "SH_RTC"                           */
 /*                           Real-time Clock                            */
 /* ================================== */
-#define SH_RTC                                   0x00000001101c0000UL
-#define SH_RTC_MASK                              0x007fffffffffffffUL
-
-/* ================================== */
-/*                 Register "SH_MEMORY_WRITE_STATUS_0|1"                */
-/*                    Memory Write Status for CPU 0 & 1                 */
-/* ================================== */
-#define SH_MEMORY_WRITE_STATUS_0                 0x0000000120070000UL
-#define SH_MEMORY_WRITE_STATUS_1                 0x0000000120070080UL
+#define SH1_RTC                                   0x00000001101c0000
+#define SH2_RTC					  0x00000002101c0000
+#define SH_RTC_MASK                               0x007fffffffffffff
 
 /* ================================== */
 /*                   Register "SH_PIO_WRITE_STATUS_0|1"                 */
 /*                      PIO Write Status for CPU 0 & 1                  */
 /* ================================== */
-#ifndef __ASSEMBLY__
-#define SH_PIO_WRITE_STATUS_0                    0x0000000120070200UL
-#define SH_PIO_WRITE_STATUS_1                    0x0000000120070280UL
+#define SH1_PIO_WRITE_STATUS_0                    0x0000000120070200
+#define SH1_PIO_WRITE_STATUS_1                    0x0000000120070280
+#define SH2_PIO_WRITE_STATUS_0                    0x0000000020070200
+#define SH2_PIO_WRITE_STATUS_1                    0x0000000020070280
+#define SH2_PIO_WRITE_STATUS_2                    0x0000000020070300
+#define SH2_PIO_WRITE_STATUS_3                    0x0000000020070380
 
 /*   SH_PIO_WRITE_STATUS_0_WRITE_DEADLOCK                               */
 /*   Description:  Deadlock response detected                           */
-#define SH_PIO_WRITE_STATUS_0_WRITE_DEADLOCK_SHFT 1
-#define SH_PIO_WRITE_STATUS_0_WRITE_DEADLOCK_MASK 0x0000000000000002
+#define SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_SHFT 1
+#define SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK 0x0000000000000002
 
 /*   SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT                          */
 /*   Description:  Count of currently pending PIO writes                */
-#define SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_SHFT 56
-#define SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK 0x3f00000000000000UL
-#else
-#define SH_PIO_WRITE_STATUS_0                    0x0000000120070200
-#define SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_SHFT 56
-#define SH_PIO_WRITE_STATUS_0_WRITE_DEADLOCK_SHFT 1
-#endif
+#define SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_SHFT 56
+#define SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK 0x3f00000000000000
 
 /* ================================== */
 /*                Register "SH_PIO_WRITE_STATUS_0_ALIAS"                */
 /* ================================== */
-#ifndef __ASSEMBLY__
-#define SH_PIO_WRITE_STATUS_0_ALIAS              0x0000000120070208UL
-#else
-#define SH_PIO_WRITE_STATUS_0_ALIAS              0x0000000120070208
-#endif
+#define SH1_PIO_WRITE_STATUS_0_ALIAS              0x0000000120070208
+#define SH2_PIO_WRITE_STATUS_0_ALIAS              0x0000000020070208
 
 /* ================================== */
 /*                     Register "SH_EVENT_OCCURRED"                     */
@@ -151,61 +130,72 @@
 #define SH_EVENT_OCCURRED_II_INT1_MASK           0x0000000040000000
 
 /* ================================== */
-/*                         Register "SH_PTC_0"                          */
+/*                         Register "SH1_PTC_0"                         */
 /*       Puge Translation Cache Message Configuration Information       */
 /* ================================== */
-#define SH_PTC_0                                 0x00000001101a0000UL
-#define SH_PTC_0_MASK                            0x80000000fffffffd
-#define SH_PTC_0_INIT                            0x0000000000000000
+#define SH1_PTC_0                                 0x00000001101a0000
 
-/*   SH_PTC_0_A                                                         */
+/*   SH1_PTC_0_A                                                        */
 /*   Description:  Type                                                 */
-#define SH_PTC_0_A_SHFT                          0
-#define SH_PTC_0_A_MASK                          0x0000000000000001
+#define SH1_PTC_0_A_SHFT                          0
 
-/*   SH_PTC_0_PS                                                        */
+/*   SH1_PTC_0_PS                                                       */
 /*   Description:  Page Size                                            */
-#define SH_PTC_0_PS_SHFT                         2
-#define SH_PTC_0_PS_MASK                         0x00000000000000fc
+#define SH1_PTC_0_PS_SHFT                         2
 
-/*   SH_PTC_0_RID                                                       */
+/*   SH1_PTC_0_RID                                                      */
 /*   Description:  Region ID                                            */
-#define SH_PTC_0_RID_SHFT                        8
-#define SH_PTC_0_RID_MASK                        0x00000000ffffff00
+#define SH1_PTC_0_RID_SHFT                        8
 
-/*   SH_PTC_0_START                                                     */
+/*   SH1_PTC_0_START                                                    */
 /*   Description:  Start                                                */
-#define SH_PTC_0_START_SHFT                      63
-#define SH_PTC_0_START_MASK                      0x8000000000000000
+#define SH1_PTC_0_START_SHFT                      63
 
 /* ================================== */
-/*                         Register "SH_PTC_1"                          */
+/*                         Register "SH1_PTC_1"                         */
 /*       Puge Translation Cache Message Configuration Information       */
 /* ================================== */
-#define SH_PTC_1                                 0x00000001101a0080UL
-#define SH_PTC_1_MASK                            0x9ffffffffffff000
-#define SH_PTC_1_INIT                            0x0000000000000000
-
-/*   SH_PTC_1_VPN                                                       */
-/*   Description:  Virtual page number                                  */
-#define SH_PTC_1_VPN_SHFT                        12
-#define SH_PTC_1_VPN_MASK                        0x1ffffffffffff000
+#define SH1_PTC_1                                 0x00000001101a0080
 
-/*   SH_PTC_1_START                                                     */
+/*   SH1_PTC_1_START                                                    */
 /*   Description:  PTC_1 Start                                          */
-#define SH_PTC_1_START_SHFT                      63
-#define SH_PTC_1_START_MASK                      0x8000000000000000
+#define SH1_PTC_1_START_SHFT                      63
+
+
+/* ================================== */
+/*                         Register "SH2_PTC"                           */
+/*       Puge Translation Cache Message Configuration Information       */
+/* ================================== */
+#define SH2_PTC                                   0x0000000170000000
 
-/*
- * Register definitions
- */
+/*   SH2_PTC_A                                                          */
+/*   Description:  Type                                                 */
+#define SH2_PTC_A_SHFT                            0
+
+/*   SH2_PTC_PS                                                         */
+/*   Description:  Page Size                                            */
+#define SH2_PTC_PS_SHFT                           2
+
+/*   SH2_PTC_RID                                                      */
+/*   Description:  Region ID                                            */
+#define SH2_PTC_RID_SHFT                          4
+
+/*   SH2_PTC_START                                                      */
+/*   Description:  Start                                                */
+#define SH2_PTC_START_SHFT                        63
+
+/*   SH2_PTC_ADDR_RID                                                   */
+/*   Description:  Region ID                                            */
+#define SH2_PTC_ADDR_SHFT                         4
+#define SH2_PTC_ADDR_MASK                         0x1ffffffffffff000
 
 /* ================================== */
 /*                    Register "SH_RTC1_INT_CONFIG"                     */
 /*                SHub RTC 1 Interrupt Config Registers                 */
 /* ================================== */
 
-#define SH_RTC1_INT_CONFIG                       0x0000000110001480
+#define SH1_RTC1_INT_CONFIG                      0x0000000110001480
+#define SH2_RTC1_INT_CONFIG                      0x0000000010001480
 #define SH_RTC1_INT_CONFIG_MASK                  0x0ff3ffffffefffff
 #define SH_RTC1_INT_CONFIG_INIT                  0x0000000000000000
 
@@ -239,7 +229,8 @@
 /*                SHub RTC 1 Interrupt Enable Registers                 */
 /* ================================== */
 
-#define SH_RTC1_INT_ENABLE                       0x0000000110001500
+#define SH1_RTC1_INT_ENABLE                      0x0000000110001500
+#define SH2_RTC1_INT_ENABLE                      0x0000000010001500
 #define SH_RTC1_INT_ENABLE_MASK                  0x0000000000000001
 #define SH_RTC1_INT_ENABLE_INIT                  0x0000000000000000
 
@@ -253,7 +244,8 @@
 /*                SHub RTC 2 Interrupt Config Registers                 */
 /* ================================== */
 
-#define SH_RTC2_INT_CONFIG                       0x0000000110001580
+#define SH1_RTC2_INT_CONFIG                      0x0000000110001580
+#define SH2_RTC2_INT_CONFIG                      0x0000000010001580
 #define SH_RTC2_INT_CONFIG_MASK                  0x0ff3ffffffefffff
 #define SH_RTC2_INT_CONFIG_INIT                  0x0000000000000000
 
@@ -287,7 +279,8 @@
 /*                SHub RTC 2 Interrupt Enable Registers                 */
 /* ================================== */
 
-#define SH_RTC2_INT_ENABLE                       0x0000000110001600
+#define SH1_RTC2_INT_ENABLE                      0x0000000110001600
+#define SH2_RTC2_INT_ENABLE                      0x0000000010001600
 #define SH_RTC2_INT_ENABLE_MASK                  0x0000000000000001
 #define SH_RTC2_INT_ENABLE_INIT                  0x0000000000000000
 
@@ -301,7 +294,8 @@
 /*                SHub RTC 3 Interrupt Config Registers                 */
 /* ================================== */
 
-#define SH_RTC3_INT_CONFIG                       0x0000000110001680
+#define SH1_RTC3_INT_CONFIG                      0x0000000110001680
+#define SH2_RTC3_INT_CONFIG                      0x0000000010001680
 #define SH_RTC3_INT_CONFIG_MASK                  0x0ff3ffffffefffff
 #define SH_RTC3_INT_CONFIG_INIT                  0x0000000000000000
 
@@ -335,7 +329,8 @@
 /*                SHub RTC 3 Interrupt Enable Registers                 */
 /* ================================== */
 
-#define SH_RTC3_INT_ENABLE                       0x0000000110001700
+#define SH1_RTC3_INT_ENABLE                      0x0000000110001700
+#define SH2_RTC3_INT_ENABLE                      0x0000000010001700
 #define SH_RTC3_INT_ENABLE_MASK                  0x0000000000000001
 #define SH_RTC3_INT_ENABLE_INIT                  0x0000000000000000
 
@@ -364,7 +359,8 @@
 /*                  RTC Compare Value for Processor B                   */
 /* ================================== */
 
-#define SH_INT_CMPB                              0x00000001101b0080
+#define SH1_INT_CMPB                             0x00000001101b0080
+#define SH2_INT_CMPB                             0x00000000101b0080
 #define SH_INT_CMPB_MASK                         0x007fffffffffffff
 #define SH_INT_CMPB_INIT                         0x0000000000000000
 
@@ -378,7 +374,8 @@
 /*                  RTC Compare Value for Processor C                   */
 /* ================================== */
 
-#define SH_INT_CMPC                              0x00000001101b0100
+#define SH1_INT_CMPC                             0x00000001101b0100
+#define SH2_INT_CMPC                             0x00000000101b0100
 #define SH_INT_CMPC_MASK                         0x007fffffffffffff
 #define SH_INT_CMPC_INIT                         0x0000000000000000
 
@@ -392,7 +389,8 @@
 /*                  RTC Compare Value for Processor D                   */
 /* ================================== */
 
-#define SH_INT_CMPD                              0x00000001101b0180
+#define SH1_INT_CMPD                             0x00000001101b0180
+#define SH2_INT_CMPD                             0x00000000101b0180
 #define SH_INT_CMPD_MASK                         0x007fffffffffffff
 #define SH_INT_CMPD_INIT                         0x0000000000000000
 
@@ -401,4 +399,29 @@
 #define SH_INT_CMPD_REAL_TIME_CMPD_SHFT          0
 #define SH_INT_CMPD_REAL_TIME_CMPD_MASK          0x007fffffffffffff
 
+
+/* ================================== */
+/* Some MMRs are functionally identical (or close enough) on both SHUB1 */
+/* and SHUB2 that it makes sense to define a geberic name for the MMR.  */
+/* It is acceptible to use (for example) SH_IPI_INT to reference the    */
+/* the IPI MMR. The value of SH_IPI_INT is determined at runtime based  */
+/* on the type of the SHUB. Do not use these #defines in performance    */
+/* critical code  or loops - there is a small performance penalty.      */
+/* ================================== */
+#define shubmmr(a,b) 		(is_shub2() ? a##2_##b : a##1_##b)
+
+#define SH_IPI_INT		shubmmr(SH, IPI_INT)
+#define SH_EVENT_OCCURRED	shubmmr(SH, EVENT_OCCURRED)
+#define SH_EVENT_OCCURRED_ALIAS	shubmmr(SH, EVENT_OCCURRED_ALIAS)
+#define SH_RTC			shubmmr(SH, RTC)
+#define SH_RTC1_INT_CONFIG	shubmmr(SH, RTC1_INT_CONFIG)
+#define SH_RTC1_INT_ENABLE	shubmmr(SH, RTC1_INT_ENABLE)
+#define SH_RTC2_INT_CONFIG	shubmmr(SH, RTC2_INT_CONFIG)
+#define SH_RTC2_INT_ENABLE	shubmmr(SH, RTC2_INT_ENABLE)
+#define SH_RTC3_INT_CONFIG	shubmmr(SH, RTC3_INT_CONFIG)
+#define SH_RTC3_INT_ENABLE	shubmmr(SH, RTC3_INT_ENABLE)
+#define SH_INT_CMPB		shubmmr(SH, INT_CMPB)
+#define SH_INT_CMPC		shubmmr(SH, INT_CMPC)
+#define SH_INT_CMPD		shubmmr(SH, INT_CMPD)
+
 #endif /* _ASM_IA64_SN_SHUB_MMR_H */
Index: linux/arch/ia64/sn/kernel/sn2/timer.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/timer.c	2004-12-01 13:26:48.438186582 -0600
+++ linux/arch/ia64/sn/kernel/sn2/timer.c	2004-12-01 13:28:31.063121434 -0600
@@ -15,7 +15,6 @@
 #include <asm/hw_irq.h>
 #include <asm/system.h>
 
-#include "shub.h"
 #include <asm/sn/leds.h>
 #include <asm/sn/shub_mmr.h>
 #include <asm/sn/clksupport.h>
Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2004-12-01 13:03:49.300015941 -0600
+++ linux/arch/ia64/sn/kernel/setup.c	2004-12-01 13:31:23.782204409 -0600
@@ -215,8 +215,10 @@ static inline int __init is_shub_1_1(int
 	unsigned long id;
 	int rev;
 
-	id = REMOTE_HUB_L(nasid, SH_SHUB_ID);
-	rev = (id & SH_SHUB_ID_REVISION_MASK) >> SH_SHUB_ID_REVISION_SHFT;
+	if (is_shub2())
+		return 0;
+	id = REMOTE_HUB_L(nasid, SH1_SHUB_ID);
+	rev = (id & SH1_SHUB_ID_REVISION_MASK) >> SH1_SHUB_ID_REVISION_SHFT;
 	return rev <= 2;
 }
 
@@ -224,9 +226,13 @@ static void __init sn_check_for_wars(voi
 {
 	int cnode;
 
-	for (cnode = 0; cnode < numnodes; cnode++)
-		if (is_shub_1_1(cnodeid_to_nasid(cnode)))
-			shub_1_1_found = 1;
+	if (is_shub2()) {
+		/* none yet */
+	} else {
+		for (cnode = 0; cnode < numnodes; cnode++)
+			if (is_shub_1_1(cnodeid_to_nasid(cnode)))
+				shub_1_1_found = 1;
+	}
 }
 
 /**
@@ -477,21 +483,29 @@ void __init sn_cpu_init(void)
 	pda->shub_1_1_found = shub_1_1_found;
 
 	/*
-	 * We must use different memory allocators for first cpu (bootmem 
-	 * allocator) than for the other cpus (regular allocator).
+	 * Set up addresses of PIO/MEM write status registers.
 	 */
-	pda->pio_write_status_addr = (volatile unsigned long *)
-	    LOCAL_MMR_ADDR((slice <
-			    2 ? SH_PIO_WRITE_STATUS_0 : SH_PIO_WRITE_STATUS_1));
+	{
+		u64 pio1[] = {SH1_PIO_WRITE_STATUS_0, 0, SH1_PIO_WRITE_STATUS_1, 0};
+		u64 pio2[] = {SH2_PIO_WRITE_STATUS_0, SH2_PIO_WRITE_STATUS_1, 
+			SH2_PIO_WRITE_STATUS_2, SH2_PIO_WRITE_STATUS_3};
+		u64 *pio;
+		pio = is_shub1() ? pio1 : pio2;
+		pda->pio_write_status_addr = (volatile unsigned long *) LOCAL_MMR_ADDR(pio[slice]);
+		pda->pio_write_status_val = is_shub1() ? SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK : 0;
+	}
 
-	if (local_node_data->active_cpu_count++ = 0) {
+	/*
+	 * WAR addresses for SHUB 1.x.
+	 */
+	if (local_node_data->active_cpu_count++ = 0 && is_shub1()) {
 		int buddy_nasid;
 		buddy_nasid  		    cnodeid_to_nasid(numa_node_id() =
 				     numnodes - 1 ? 0 : numa_node_id() + 1);
 		pda->pio_shub_war_cam_addr  		    (volatile unsigned long *)GLOBAL_MMR_ADDR(nasid,
-							      SH_PI_CAM_CONTROL);
+							      SH1_PI_CAM_CONTROL);
 	}
 }
 
Index: linux/include/asm-ia64/sn/arch.h
=================================--- linux.orig/include/asm-ia64/sn/arch.h	2004-12-01 12:47:56.111758858 -0600
+++ linux/include/asm-ia64/sn/arch.h	2004-12-01 13:28:31.066050813 -0600
@@ -20,7 +20,8 @@
  * Effectively, it's the maximum number of compact node ids (cnodeid_t).
  * This is not necessarily the same as MAX_NASIDS.
  */
-#define MAX_COMPACT_NODES       2048
+#define MAX_COMPACT_NODES	2048
+#define CPUS_PER_NODE		4
 
 extern void sn_flush_all_caches(long addr, long bytes);
 
Index: linux/arch/ia64/sn/kernel/iomv.c
=================================--- linux.orig/arch/ia64/sn/kernel/iomv.c	2004-12-01 12:47:56.114688238 -0600
+++ linux/arch/ia64/sn/kernel/iomv.c	2004-12-01 13:28:31.068980191 -0600
@@ -42,8 +42,7 @@ void *sn_io_addr(unsigned long port)
 		 */
 		if ((port >= 0x1f0 && port <= 0x1f7) ||
 		    port = 0x3f6 || port = 0x3f7) {
-			io_base = (0xc000000fcc000000UL |
-				   ((unsigned long)get_nasid() << 38));
+			io_base = GLOBAL_MMR_ADDR(get_nasid(), 0xfcc000000UL);
 			addr = io_base | ((port >> 2) << 12) | (port & 0xfff);
 		} else {
 			addr = __ia64_get_io_port_base() | ((port >> 2) << 2);
@@ -66,9 +65,10 @@ EXPORT_SYMBOL(sn_io_addr);
  */
 void __sn_mmiowb(void)
 {
-	while ((((volatile unsigned long)(*pda->pio_write_status_addr)) &
-		SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK) !-	       SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK)
+	volatile unsigned long *adr = pda->pio_write_status_addr;
+	unsigned long val = pda->pio_write_status_val;
+
+	while ((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != val)
 		cpu_relax();
 }
 
Index: linux/include/asm-ia64/sn/sn_cpuid.h
=================================--- linux.orig/include/asm-ia64/sn/sn_cpuid.h	2004-12-01 12:47:56.112735318 -0600
+++ linux/include/asm-ia64/sn/sn_cpuid.h	2004-12-01 13:28:31.069956651 -0600
@@ -13,6 +13,7 @@
 
 #include <linux/config.h>
 #include <linux/smp.h>
+#include <asm/sn/addrs.h>
 #include <asm/sn/pda.h>
 #include <asm/intrinsics.h>
 
@@ -86,11 +87,9 @@
 #endif
 
 
-#define get_node_number(addr)			(((unsigned long)(addr)>>38) & 0x7ff)
+#define get_node_number(addr)			NASID_GET(addr)
 
 /*
- * NOTE: id & eid refer to Intel's definitions of the LID register
- * 
  * NOTE: on non-MP systems, only cpuid 0 exists
  */
 
Index: linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	2004-12-01 12:47:56.113711778 -0600
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2004-12-01 13:28:31.070933110 -0600
@@ -46,15 +46,14 @@ static unsigned long sn2_ptc_deadlock_co
 
 static inline unsigned long wait_piowc(void)
 {
-	volatile unsigned long *piows;
+	volatile unsigned long *piows, piows_val;
 	unsigned long ws;
 
 	piows = pda->pio_write_status_addr;
+	piows_val = pda->pio_write_status_val;
 	do {
-		ia64_mfa();
-	} while (((ws -		   *piows) & SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK) !-		 SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK);
+		cpu_relax();
+	} while (((ws = *piows) & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != piows_val);
 	return ws;
 }
 
@@ -129,20 +128,20 @@ sn2_global_tlb_purge(unsigned long start
 	     cnode = find_next_bit(&nodes_flushed, NR_NODES, ++cnode))
 		nasids[nix++] = cnodeid_to_nasid(cnode);
 
-	data0 = (1UL << SH_PTC_0_A_SHFT) |
-	    (nbits << SH_PTC_0_PS_SHFT) |
-	    ((ia64_get_rr(start) >> 8) << SH_PTC_0_RID_SHFT) |
-	    (1UL << SH_PTC_0_START_SHFT);
+	data0 = (1UL << SH1_PTC_0_A_SHFT) |
+	    (nbits << SH1_PTC_0_PS_SHFT) |
+	    ((ia64_get_rr(start) >> 8) << SH1_PTC_0_RID_SHFT) |
+	    (1UL << SH1_PTC_0_START_SHFT);
 
-	ptc0 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH_PTC_0);
-	ptc1 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH_PTC_1);
+	ptc0 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_0);
+	ptc1 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_1);
 
 	mynasid = get_nasid();
 
 	spin_lock_irqsave(&sn2_global_ptc_lock, flags);
 
 	do {
-		data1 = start | (1UL << SH_PTC_1_START_SHFT);
+		data1 = start | (1UL << SH1_PTC_1_START_SHFT);
 		for (i = 0; i < nix; i++) {
 			nasid = nasids[i];
 			if (likely(nasid = mynasid)) {
@@ -159,7 +158,7 @@ sn2_global_tlb_purge(unsigned long start
 
 		if (flushed
 		    && (wait_piowc() &
-			SH_PIO_WRITE_STATUS_0_WRITE_DEADLOCK_MASK)) {
+			SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK)) {
 			sn2_ptc_deadlock_recovery(data0, data1);
 		}
 
@@ -188,8 +187,8 @@ void sn2_ptc_deadlock_recovery(unsigned 
 
 	sn2_ptc_deadlock_count++;
 
-	ptc0 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH_PTC_0);
-	ptc1 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH_PTC_1);
+	ptc0 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_0);
+	ptc1 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_1);
 	piows = (long *)pda->pio_write_status_addr;
 
 	mycnode = numa_node_id();
Index: linux/arch/ia64/sn/kernel/sn2/ptc_deadlock.S
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/ptc_deadlock.S	2004-12-01 12:47:56.113711778 -0600
+++ linux/arch/ia64/sn/kernel/sn2/ptc_deadlock.S	2004-12-01 13:28:31.070933110 -0600
@@ -9,9 +9,9 @@
 #include <asm/sn/shub_mmr.h>
 
 #define ZEROVAL		0x3f		// "zero" value for outstanding PIO requests
-#define DEADLOCKBIT	SH_PIO_WRITE_STATUS_0_WRITE_DEADLOCK_SHFT
-#define WRITECOUNT	SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_SHFT
-#define ALIAS_OFFSET	(SH_PIO_WRITE_STATUS_0_ALIAS-SH_PIO_WRITE_STATUS_0)
+#define DEADLOCKBIT	SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_SHFT
+#define WRITECOUNT	SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_SHFT
+#define ALIAS_OFFSET	(SH1_PIO_WRITE_STATUS_0_ALIAS-SH1_PIO_WRITE_STATUS_0)
 
 
 	.global	sn2_ptc_deadlock_recovery_core
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


