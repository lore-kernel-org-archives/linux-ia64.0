From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 09 May 2005 12:06:31 +0000
Subject: [PATCH]: IA64: sparse cleanup of shub_mmr.h
Message-Id: <427F5247.4000309@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000702090704030403000300"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------000702090704030403000300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

This patch is a sparse compile cleanup of shub_mmr.h using both the 
defconfig and the sn2_defconfig config files.

The issue with this file was the missing usage of __IA64_UL_CONST 
wrapper. This wrapper is defined in include/asm-ia64/types.h and wraps a 
long constant definition with UL or with nothing depending on its usage 
in the kernel.  The missing wrapper caused many sparse compile errors like

         warning: constant 0x0x0000000010000380 so big it is long


--------------000702090704030403000300
Content-Type: text/plain;
 name="cgsparse2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cgsparse2.diff"

[PATCH]: IA64: sparse cleanup of shub_mmr.h

This patch is a sparse compile cleanup of shub_mmr.h using both the defconfig
and the sn2_defconfig config files.

The issue with this file was the missing usage of __IA64_UL_CONST wrapper.
This wrapper is defined in include/asm-ia64/types.h and wraps a long
constant definition with UL or with nothing depending on its usage in the
kernel.  The missing wrapper caused many sparse compile errors like

        warning: constant 0x0x0000000010000380 so big it is long

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit 25e33f032d38101d5e8abffc6e27f0e5cc9360b7
tree deed0faf877ef4aa0feb36fcde2b044a77a73b4c
parent 2512809255d018744fe6c2f5e996c83769846c07
author Prarit Bhargava <prarit@sgi.com> 1115394691 -0400
committer Prarit Bhargava <prarit@sgi.com> 1115394691 -0400

Index: arch/ia64/sn/kernel/sn2/ptc_deadlock.S
===================================================================
--- e220183081409fe4c5d1961cf1e56d93a91d7efc/arch/ia64/sn/kernel/sn2/ptc_deadlock.S  (mode:100644 sha1:7947312801eccc797975e338af4e76f12ace0c55)
+++ deed0faf877ef4aa0feb36fcde2b044a77a73b4c/arch/ia64/sn/kernel/sn2/ptc_deadlock.S  (mode:100644 sha1:96cb71d156820f9b33df9a07ea5049afe3bc77b9)
@@ -6,6 +6,7 @@
  * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
  */
 
+#include <asm/types.h>
 #include <asm/sn/shub_mmr.h>
 
 #define DEADLOCKBIT	SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_SHFT
Index: include/asm-ia64/sn/shub_mmr.h
===================================================================
--- e220183081409fe4c5d1961cf1e56d93a91d7efc/include/asm-ia64/sn/shub_mmr.h  (mode:100644 sha1:323fa0cd8d83d671d04fb51977dd9963b18784de)
+++ deed0faf877ef4aa0feb36fcde2b044a77a73b4c/include/asm-ia64/sn/shub_mmr.h  (mode:100644 sha1:7de1d1d4b71a9b7ccb67e10b09be4304fb047da8)
@@ -14,96 +14,98 @@
 /*                        Register "SH_IPI_INT"                         */
 /*               SHub Inter-Processor Interrupt Registers               */
 /* ==================================================================== */
-#define SH1_IPI_INT                               0x0000000110000380
-#define SH2_IPI_INT                               0x0000000010000380
+#define SH1_IPI_INT			__IA64_UL_CONST(0x0000000110000380)
+#define SH2_IPI_INT			__IA64_UL_CONST(0x0000000010000380)
 
 /*   SH_IPI_INT_TYPE                                                    */
 /*   Description:  Type of Interrupt: 0=INT, 2=PMI, 4=NMI, 5=INIT       */
-#define SH_IPI_INT_TYPE_SHFT                     0
-#define SH_IPI_INT_TYPE_MASK                     0x0000000000000007
+#define SH_IPI_INT_TYPE_SHFT				0
+#define SH_IPI_INT_TYPE_MASK		__IA64_UL_CONST(0x0000000000000007)
 
 /*   SH_IPI_INT_AGT                                                     */
 /*   Description:  Agent, must be 0 for SHub                            */
-#define SH_IPI_INT_AGT_SHFT                      3
-#define SH_IPI_INT_AGT_MASK                      0x0000000000000008
+#define SH_IPI_INT_AGT_SHFT				3
+#define SH_IPI_INT_AGT_MASK		__IA64_UL_CONST(0x0000000000000008)
 
 /*   SH_IPI_INT_PID                                                     */
 /*   Description:  Processor ID, same setting as on targeted McKinley  */
-#define SH_IPI_INT_PID_SHFT                      4
-#define SH_IPI_INT_PID_MASK                      0x00000000000ffff0
+#define SH_IPI_INT_PID_SHFT                      	4
+#define SH_IPI_INT_PID_MASK		__IA64_UL_CONST(0x00000000000ffff0)
 
 /*   SH_IPI_INT_BASE                                                    */
 /*   Description:  Optional interrupt vector area, 2MB aligned          */
-#define SH_IPI_INT_BASE_SHFT                     21
-#define SH_IPI_INT_BASE_MASK                     0x0003ffffffe00000
+#define SH_IPI_INT_BASE_SHFT				21
+#define SH_IPI_INT_BASE_MASK 		__IA64_UL_CONST(0x0003ffffffe00000)
 
 /*   SH_IPI_INT_IDX                                                     */
 /*   Description:  Targeted McKinley interrupt vector                   */
-#define SH_IPI_INT_IDX_SHFT                      52
-#define SH_IPI_INT_IDX_MASK                      0x0ff0000000000000
+#define SH_IPI_INT_IDX_SHFT				52
+#define SH_IPI_INT_IDX_MASK		__IA64_UL_CONST(0x0ff0000000000000)
 
 /*   SH_IPI_INT_SEND                                                    */
 /*   Description:  Send Interrupt Message to PI, This generates a puls  */
-#define SH_IPI_INT_SEND_SHFT                     63
-#define SH_IPI_INT_SEND_MASK                     0x8000000000000000
+#define SH_IPI_INT_SEND_SHFT				63
+#define SH_IPI_INT_SEND_MASK		__IA64_UL_CONST(0x8000000000000000)
 
 /* ==================================================================== */
 /*                     Register "SH_EVENT_OCCURRED"                     */
 /*                    SHub Interrupt Event Occurred                     */
 /* ==================================================================== */
-#define SH1_EVENT_OCCURRED                        0x0000000110010000
-#define SH1_EVENT_OCCURRED_ALIAS                  0x0000000110010008
-#define SH2_EVENT_OCCURRED                        0x0000000010010000
-#define SH2_EVENT_OCCURRED_ALIAS                  0x0000000010010008
+#define SH1_EVENT_OCCURRED		__IA64_UL_CONST(0x0000000110010000)
+#define SH1_EVENT_OCCURRED_ALIAS	__IA64_UL_CONST(0x0000000110010008)
+#define SH2_EVENT_OCCURRED		__IA64_UL_CONST(0x0000000010010000)
+#define SH2_EVENT_OCCURRED_ALIAS 	__IA64_UL_CONST(0x0000000010010008)
 
 /* ==================================================================== */
 /*                     Register "SH_PI_CAM_CONTROL"                     */
 /*                      CRB CAM MMR Access Control                      */
 /* ==================================================================== */
-#define SH1_PI_CAM_CONTROL                        0x0000000120050300
+#define SH1_PI_CAM_CONTROL		__IA64_UL_CONST(0x0000000120050300)
 
 /* ==================================================================== */
 /*                        Register "SH_SHUB_ID"                         */
 /*                            SHub ID Number                            */
 /* ==================================================================== */
-#define SH1_SHUB_ID                               0x0000000110060580
-#define SH1_SHUB_ID_REVISION_SHFT                 28
-#define SH1_SHUB_ID_REVISION_MASK                 0x00000000f0000000
+#define SH1_SHUB_ID			__IA64_UL_CONST(0x0000000110060580)
+#define SH1_SHUB_ID_REVISION_SHFT			28
+#define SH1_SHUB_ID_REVISION_MASK	__IA64_UL_CONST(0x00000000f0000000)
 
 /* ==================================================================== */
 /*                          Register "SH_RTC"                           */
 /*                           Real-time Clock                            */
 /* ==================================================================== */
-#define SH1_RTC                                   0x00000001101c0000
-#define SH2_RTC					  0x00000002101c0000
-#define SH_RTC_MASK                               0x007fffffffffffff
+#define SH1_RTC				__IA64_UL_CONST(0x00000001101c0000)
+#define SH2_RTC				__IA64_UL_CONST(0x00000002101c0000)
+#define SH_RTC_MASK			__IA64_UL_CONST(0x007fffffffffffff)
 
 /* ==================================================================== */
 /*                   Register "SH_PIO_WRITE_STATUS_0|1"                 */
 /*                      PIO Write Status for CPU 0 & 1                  */
 /* ==================================================================== */
-#define SH1_PIO_WRITE_STATUS_0                    0x0000000120070200
-#define SH1_PIO_WRITE_STATUS_1                    0x0000000120070280
-#define SH2_PIO_WRITE_STATUS_0                    0x0000000020070200
-#define SH2_PIO_WRITE_STATUS_1                    0x0000000020070280
-#define SH2_PIO_WRITE_STATUS_2                    0x0000000020070300
-#define SH2_PIO_WRITE_STATUS_3                    0x0000000020070380
+#define SH1_PIO_WRITE_STATUS_0		__IA64_UL_CONST(0x0000000120070200)
+#define SH1_PIO_WRITE_STATUS_1		__IA64_UL_CONST(0x0000000120070280)
+#define SH2_PIO_WRITE_STATUS_0		__IA64_UL_CONST(0x0000000020070200)
+#define SH2_PIO_WRITE_STATUS_1		__IA64_UL_CONST(0x0000000020070280)
+#define SH2_PIO_WRITE_STATUS_2		__IA64_UL_CONST(0x0000000020070300)
+#define SH2_PIO_WRITE_STATUS_3		__IA64_UL_CONST(0x0000000020070380)
 
 /*   SH_PIO_WRITE_STATUS_0_WRITE_DEADLOCK                               */
 /*   Description:  Deadlock response detected                           */
-#define SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_SHFT 1
-#define SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK 0x0000000000000002
+#define SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_SHFT		1
+#define SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK \
+					__IA64_UL_CONST(0x0000000000000002)
 
 /*   SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT                          */
 /*   Description:  Count of currently pending PIO writes                */
-#define SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_SHFT 56
-#define SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK 0x3f00000000000000
+#define SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_SHFT	56
+#define SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK \
+					__IA64_UL_CONST(0x3f00000000000000)
 
 /* ==================================================================== */
 /*                Register "SH_PIO_WRITE_STATUS_0_ALIAS"                */
 /* ==================================================================== */
-#define SH1_PIO_WRITE_STATUS_0_ALIAS              0x0000000120070208
-#define SH2_PIO_WRITE_STATUS_0_ALIAS              0x0000000020070208
+#define SH1_PIO_WRITE_STATUS_0_ALIAS	__IA64_UL_CONST(0x0000000120070208)
+#define SH2_PIO_WRITE_STATUS_0_ALIAS	__IA64_UL_CONST(0x0000000020070208)
 
 /* ==================================================================== */
 /*                     Register "SH_EVENT_OCCURRED"                     */
@@ -111,33 +113,33 @@
 /* ==================================================================== */
 /*   SH_EVENT_OCCURRED_UART_INT                                         */
 /*   Description:  Pending Junk Bus UART Interrupt                      */
-#define SH_EVENT_OCCURRED_UART_INT_SHFT          20
-#define SH_EVENT_OCCURRED_UART_INT_MASK          0x0000000000100000
+#define SH_EVENT_OCCURRED_UART_INT_SHFT			20
+#define SH_EVENT_OCCURRED_UART_INT_MASK	__IA64_UL_CONST(0x0000000000100000)
 
 /*   SH_EVENT_OCCURRED_IPI_INT                                          */
 /*   Description:  Pending IPI Interrupt                                */
-#define SH_EVENT_OCCURRED_IPI_INT_SHFT           28
-#define SH_EVENT_OCCURRED_IPI_INT_MASK           0x0000000010000000
+#define SH_EVENT_OCCURRED_IPI_INT_SHFT			28
+#define SH_EVENT_OCCURRED_IPI_INT_MASK	__IA64_UL_CONST(0x0000000010000000)
 
 /*   SH_EVENT_OCCURRED_II_INT0                                          */
 /*   Description:  Pending II 0 Interrupt                               */
-#define SH_EVENT_OCCURRED_II_INT0_SHFT           29
-#define SH_EVENT_OCCURRED_II_INT0_MASK           0x0000000020000000
+#define SH_EVENT_OCCURRED_II_INT0_SHFT			29
+#define SH_EVENT_OCCURRED_II_INT0_MASK	__IA64_UL_CONST(0x0000000020000000)
 
 /*   SH_EVENT_OCCURRED_II_INT1                                          */
 /*   Description:  Pending II 1 Interrupt                               */
-#define SH_EVENT_OCCURRED_II_INT1_SHFT           30
-#define SH_EVENT_OCCURRED_II_INT1_MASK           0x0000000040000000
+#define SH_EVENT_OCCURRED_II_INT1_SHFT			30
+#define SH_EVENT_OCCURRED_II_INT1_MASK	__IA64_UL_CONST(0x0000000040000000)
 
 /*   SH2_EVENT_OCCURRED_EXTIO_INT2                                      */
 /*   Description:  Pending SHUB 2 EXT IO INT2                           */
-#define SH2_EVENT_OCCURRED_EXTIO_INT2_SHFT       33
-#define SH2_EVENT_OCCURRED_EXTIO_INT2_MASK       0x0000000200000000
+#define SH2_EVENT_OCCURRED_EXTIO_INT2_SHFT		33
+#define SH2_EVENT_OCCURRED_EXTIO_INT2_MASK __IA64_UL_CONST(0x0000000200000000)
 
 /*   SH2_EVENT_OCCURRED_EXTIO_INT3                                      */
 /*   Description:  Pending SHUB 2 EXT IO INT3                           */
-#define SH2_EVENT_OCCURRED_EXTIO_INT3_SHFT       34
-#define SH2_EVENT_OCCURRED_EXTIO_INT3_MASK       0x0000000400000000
+#define SH2_EVENT_OCCURRED_EXTIO_INT3_SHFT		34
+#define SH2_EVENT_OCCURRED_EXTIO_INT3_MASK __IA64_UL_CONST(0x0000000400000000)
 
 #define SH_ALL_INT_MASK \
 	(SH_EVENT_OCCURRED_UART_INT_MASK | SH_EVENT_OCCURRED_IPI_INT_MASK | \
@@ -149,310 +151,310 @@
 /* ==================================================================== */
 /*                         LEDS                                         */
 /* ==================================================================== */
-#define SH1_REAL_JUNK_BUS_LED0			 0x7fed00000UL
-#define SH1_REAL_JUNK_BUS_LED1			 0x7fed10000UL
-#define SH1_REAL_JUNK_BUS_LED2			 0x7fed20000UL
-#define SH1_REAL_JUNK_BUS_LED3			 0x7fed30000UL
-
-#define SH2_REAL_JUNK_BUS_LED0			 0xf0000000UL
-#define SH2_REAL_JUNK_BUS_LED1			 0xf0010000UL
-#define SH2_REAL_JUNK_BUS_LED2			 0xf0020000UL
-#define SH2_REAL_JUNK_BUS_LED3			 0xf0030000UL
+#define SH1_REAL_JUNK_BUS_LED0			0x7fed00000UL
+#define SH1_REAL_JUNK_BUS_LED1			0x7fed10000UL
+#define SH1_REAL_JUNK_BUS_LED2			0x7fed20000UL
+#define SH1_REAL_JUNK_BUS_LED3			0x7fed30000UL
+
+#define SH2_REAL_JUNK_BUS_LED0			0xf0000000UL
+#define SH2_REAL_JUNK_BUS_LED1			0xf0010000UL
+#define SH2_REAL_JUNK_BUS_LED2			0xf0020000UL
+#define SH2_REAL_JUNK_BUS_LED3			0xf0030000UL
 
 /* ==================================================================== */
 /*                         Register "SH1_PTC_0"                         */
 /*       Puge Translation Cache Message Configuration Information       */
 /* ==================================================================== */
-#define SH1_PTC_0                                 0x00000001101a0000
+#define SH1_PTC_0			__IA64_UL_CONST(0x00000001101a0000)
 
 /*   SH1_PTC_0_A                                                        */
 /*   Description:  Type                                                 */
-#define SH1_PTC_0_A_SHFT                          0
+#define SH1_PTC_0_A_SHFT				0
 
 /*   SH1_PTC_0_PS                                                       */
 /*   Description:  Page Size                                            */
-#define SH1_PTC_0_PS_SHFT                         2
+#define SH1_PTC_0_PS_SHFT				2
 
 /*   SH1_PTC_0_RID                                                      */
 /*   Description:  Region ID                                            */
-#define SH1_PTC_0_RID_SHFT                        8
+#define SH1_PTC_0_RID_SHFT				8
 
 /*   SH1_PTC_0_START                                                    */
 /*   Description:  Start                                                */
-#define SH1_PTC_0_START_SHFT                      63
+#define SH1_PTC_0_START_SHFT				63
 
 /* ==================================================================== */
 /*                         Register "SH1_PTC_1"                         */
 /*       Puge Translation Cache Message Configuration Information       */
 /* ==================================================================== */
-#define SH1_PTC_1                                 0x00000001101a0080
+#define SH1_PTC_1			__IA64_UL_CONST(0x00000001101a0080)
 
 /*   SH1_PTC_1_START                                                    */
 /*   Description:  PTC_1 Start                                          */
-#define SH1_PTC_1_START_SHFT                      63
-
+#define SH1_PTC_1_START_SHFT				63
 
 /* ==================================================================== */
 /*                         Register "SH2_PTC"                           */
 /*       Puge Translation Cache Message Configuration Information       */
 /* ==================================================================== */
-#define SH2_PTC                                   0x0000000170000000
+#define SH2_PTC				__IA64_UL_CONST(0x0000000170000000)
 
 /*   SH2_PTC_A                                                          */
 /*   Description:  Type                                                 */
-#define SH2_PTC_A_SHFT                            0
+#define SH2_PTC_A_SHFT					0
 
 /*   SH2_PTC_PS                                                         */
 /*   Description:  Page Size                                            */
-#define SH2_PTC_PS_SHFT                           2
+#define SH2_PTC_PS_SHFT					2
 
 /*   SH2_PTC_RID                                                      */
 /*   Description:  Region ID                                            */
-#define SH2_PTC_RID_SHFT                          4
+#define SH2_PTC_RID_SHFT				4
 
 /*   SH2_PTC_START                                                      */
 /*   Description:  Start                                                */
-#define SH2_PTC_START_SHFT                        63
+#define SH2_PTC_START_SHFT				63
 
 /*   SH2_PTC_ADDR_RID                                                   */
 /*   Description:  Region ID                                            */
-#define SH2_PTC_ADDR_SHFT                         4
-#define SH2_PTC_ADDR_MASK                         0x1ffffffffffff000
+#define SH2_PTC_ADDR_SHFT				4
+#define SH2_PTC_ADDR_MASK		__IA64_UL_CONST(0x1ffffffffffff000)
 
 /* ==================================================================== */
 /*                    Register "SH_RTC1_INT_CONFIG"                     */
 /*                SHub RTC 1 Interrupt Config Registers                 */
 /* ==================================================================== */
 
-#define SH1_RTC1_INT_CONFIG                      0x0000000110001480
-#define SH2_RTC1_INT_CONFIG                      0x0000000010001480
-#define SH_RTC1_INT_CONFIG_MASK                  0x0ff3ffffffefffff
-#define SH_RTC1_INT_CONFIG_INIT                  0x0000000000000000
+#define SH1_RTC1_INT_CONFIG		__IA64_UL_CONST(0x0000000110001480)
+#define SH2_RTC1_INT_CONFIG		__IA64_UL_CONST(0x0000000010001480)
+#define SH_RTC1_INT_CONFIG_MASK		__IA64_UL_CONST(0x0ff3ffffffefffff)
+#define SH_RTC1_INT_CONFIG_INIT		__IA64_UL_CONST(0x0000000000000000)
 
 /*   SH_RTC1_INT_CONFIG_TYPE                                            */
 /*   Description:  Type of Interrupt: 0=INT, 2=PMI, 4=NMI, 5=INIT       */
-#define SH_RTC1_INT_CONFIG_TYPE_SHFT             0
-#define SH_RTC1_INT_CONFIG_TYPE_MASK             0x0000000000000007
+#define SH_RTC1_INT_CONFIG_TYPE_SHFT			0
+#define SH_RTC1_INT_CONFIG_TYPE_MASK	__IA64_UL_CONST(0x0000000000000007)
 
 /*   SH_RTC1_INT_CONFIG_AGT                                             */
 /*   Description:  Agent, must be 0 for SHub                            */
-#define SH_RTC1_INT_CONFIG_AGT_SHFT              3
-#define SH_RTC1_INT_CONFIG_AGT_MASK              0x0000000000000008
+#define SH_RTC1_INT_CONFIG_AGT_SHFT			3
+#define SH_RTC1_INT_CONFIG_AGT_MASK	__IA64_UL_CONST(0x0000000000000008)
 
 /*   SH_RTC1_INT_CONFIG_PID                                             */
 /*   Description:  Processor ID, same setting as on targeted McKinley  */
-#define SH_RTC1_INT_CONFIG_PID_SHFT              4
-#define SH_RTC1_INT_CONFIG_PID_MASK              0x00000000000ffff0
+#define SH_RTC1_INT_CONFIG_PID_SHFT			4
+#define SH_RTC1_INT_CONFIG_PID_MASK	__IA64_UL_CONST(0x00000000000ffff0)
 
 /*   SH_RTC1_INT_CONFIG_BASE                                            */
 /*   Description:  Optional interrupt vector area, 2MB aligned          */
-#define SH_RTC1_INT_CONFIG_BASE_SHFT             21
-#define SH_RTC1_INT_CONFIG_BASE_MASK             0x0003ffffffe00000
+#define SH_RTC1_INT_CONFIG_BASE_SHFT			21
+#define SH_RTC1_INT_CONFIG_BASE_MASK	__IA64_UL_CONST(0x0003ffffffe00000)
 
 /*   SH_RTC1_INT_CONFIG_IDX                                             */
 /*   Description:  Targeted McKinley interrupt vector                   */
-#define SH_RTC1_INT_CONFIG_IDX_SHFT              52
-#define SH_RTC1_INT_CONFIG_IDX_MASK              0x0ff0000000000000
+#define SH_RTC1_INT_CONFIG_IDX_SHFT			52
+#define SH_RTC1_INT_CONFIG_IDX_MASK	__IA64_UL_CONST(0x0ff0000000000000)
 
 /* ==================================================================== */
 /*                    Register "SH_RTC1_INT_ENABLE"                     */
 /*                SHub RTC 1 Interrupt Enable Registers                 */
 /* ==================================================================== */
 
-#define SH1_RTC1_INT_ENABLE                      0x0000000110001500
-#define SH2_RTC1_INT_ENABLE                      0x0000000010001500
-#define SH_RTC1_INT_ENABLE_MASK                  0x0000000000000001
-#define SH_RTC1_INT_ENABLE_INIT                  0x0000000000000000
+#define SH1_RTC1_INT_ENABLE		__IA64_UL_CONST(0x0000000110001500)
+#define SH2_RTC1_INT_ENABLE		__IA64_UL_CONST(0x0000000010001500)
+#define SH_RTC1_INT_ENABLE_MASK		__IA64_UL_CONST(0x0000000000000001)
+#define SH_RTC1_INT_ENABLE_INIT		__IA64_UL_CONST(0x0000000000000000)
 
 /*   SH_RTC1_INT_ENABLE_RTC1_ENABLE                                     */
 /*   Description:  Enable RTC 1 Interrupt                               */
-#define SH_RTC1_INT_ENABLE_RTC1_ENABLE_SHFT      0
-#define SH_RTC1_INT_ENABLE_RTC1_ENABLE_MASK      0x0000000000000001
+#define SH_RTC1_INT_ENABLE_RTC1_ENABLE_SHFT		0
+#define SH_RTC1_INT_ENABLE_RTC1_ENABLE_MASK \
+					__IA64_UL_CONST(0x0000000000000001)
 
 /* ==================================================================== */
 /*                    Register "SH_RTC2_INT_CONFIG"                     */
 /*                SHub RTC 2 Interrupt Config Registers                 */
 /* ==================================================================== */
 
-#define SH1_RTC2_INT_CONFIG                      0x0000000110001580
-#define SH2_RTC2_INT_CONFIG                      0x0000000010001580
-#define SH_RTC2_INT_CONFIG_MASK                  0x0ff3ffffffefffff
-#define SH_RTC2_INT_CONFIG_INIT                  0x0000000000000000
+#define SH1_RTC2_INT_CONFIG		__IA64_UL_CONST(0x0000000110001580)
+#define SH2_RTC2_INT_CONFIG		__IA64_UL_CONST(0x0000000010001580)
+#define SH_RTC2_INT_CONFIG_MASK		__IA64_UL_CONST(0x0ff3ffffffefffff)
+#define SH_RTC2_INT_CONFIG_INIT		__IA64_UL_CONST(0x0000000000000000)
 
 /*   SH_RTC2_INT_CONFIG_TYPE                                            */
 /*   Description:  Type of Interrupt: 0=INT, 2=PMI, 4=NMI, 5=INIT       */
-#define SH_RTC2_INT_CONFIG_TYPE_SHFT             0
-#define SH_RTC2_INT_CONFIG_TYPE_MASK             0x0000000000000007
+#define SH_RTC2_INT_CONFIG_TYPE_SHFT			0
+#define SH_RTC2_INT_CONFIG_TYPE_MASK	__IA64_UL_CONST(0x0000000000000007)
 
 /*   SH_RTC2_INT_CONFIG_AGT                                             */
 /*   Description:  Agent, must be 0 for SHub                            */
-#define SH_RTC2_INT_CONFIG_AGT_SHFT              3
-#define SH_RTC2_INT_CONFIG_AGT_MASK              0x0000000000000008
+#define SH_RTC2_INT_CONFIG_AGT_SHFT			3
+#define SH_RTC2_INT_CONFIG_AGT_MASK	__IA64_UL_CONST(0x0000000000000008)
 
 /*   SH_RTC2_INT_CONFIG_PID                                             */
 /*   Description:  Processor ID, same setting as on targeted McKinley  */
-#define SH_RTC2_INT_CONFIG_PID_SHFT              4
-#define SH_RTC2_INT_CONFIG_PID_MASK              0x00000000000ffff0
+#define SH_RTC2_INT_CONFIG_PID_SHFT			4
+#define SH_RTC2_INT_CONFIG_PID_MASK	__IA64_UL_CONST(0x00000000000ffff0)
 
 /*   SH_RTC2_INT_CONFIG_BASE                                            */
 /*   Description:  Optional interrupt vector area, 2MB aligned          */
-#define SH_RTC2_INT_CONFIG_BASE_SHFT             21
-#define SH_RTC2_INT_CONFIG_BASE_MASK             0x0003ffffffe00000
+#define SH_RTC2_INT_CONFIG_BASE_SHFT			21
+#define SH_RTC2_INT_CONFIG_BASE_MASK	__IA64_UL_CONST(0x0003ffffffe00000)
 
 /*   SH_RTC2_INT_CONFIG_IDX                                             */
 /*   Description:  Targeted McKinley interrupt vector                   */
-#define SH_RTC2_INT_CONFIG_IDX_SHFT              52
-#define SH_RTC2_INT_CONFIG_IDX_MASK              0x0ff0000000000000
+#define SH_RTC2_INT_CONFIG_IDX_SHFT			52
+#define SH_RTC2_INT_CONFIG_IDX_MASK	__IA64_UL_CONST(0x0ff0000000000000)
 
 /* ==================================================================== */
 /*                    Register "SH_RTC2_INT_ENABLE"                     */
 /*                SHub RTC 2 Interrupt Enable Registers                 */
 /* ==================================================================== */
 
-#define SH1_RTC2_INT_ENABLE                      0x0000000110001600
-#define SH2_RTC2_INT_ENABLE                      0x0000000010001600
-#define SH_RTC2_INT_ENABLE_MASK                  0x0000000000000001
-#define SH_RTC2_INT_ENABLE_INIT                  0x0000000000000000
+#define SH1_RTC2_INT_ENABLE		__IA64_UL_CONST(0x0000000110001600)
+#define SH2_RTC2_INT_ENABLE		__IA64_UL_CONST(0x0000000010001600)
+#define SH_RTC2_INT_ENABLE_MASK		__IA64_UL_CONST(0x0000000000000001)
+#define SH_RTC2_INT_ENABLE_INIT		__IA64_UL_CONST(0x0000000000000000)
 
 /*   SH_RTC2_INT_ENABLE_RTC2_ENABLE                                     */
 /*   Description:  Enable RTC 2 Interrupt                               */
-#define SH_RTC2_INT_ENABLE_RTC2_ENABLE_SHFT      0
-#define SH_RTC2_INT_ENABLE_RTC2_ENABLE_MASK      0x0000000000000001
+#define SH_RTC2_INT_ENABLE_RTC2_ENABLE_SHFT		0
+#define SH_RTC2_INT_ENABLE_RTC2_ENABLE_MASK \
+					__IA64_UL_CONST(0x0000000000000001)
 
 /* ==================================================================== */
 /*                    Register "SH_RTC3_INT_CONFIG"                     */
 /*                SHub RTC 3 Interrupt Config Registers                 */
 /* ==================================================================== */
 
-#define SH1_RTC3_INT_CONFIG                      0x0000000110001680
-#define SH2_RTC3_INT_CONFIG                      0x0000000010001680
-#define SH_RTC3_INT_CONFIG_MASK                  0x0ff3ffffffefffff
-#define SH_RTC3_INT_CONFIG_INIT                  0x0000000000000000
+#define SH1_RTC3_INT_CONFIG		__IA64_UL_CONST(0x0000000110001680)
+#define SH2_RTC3_INT_CONFIG		__IA64_UL_CONST(0x0000000010001680)
+#define SH_RTC3_INT_CONFIG_MASK		__IA64_UL_CONST(0x0ff3ffffffefffff)
+#define SH_RTC3_INT_CONFIG_INIT		__IA64_UL_CONST(0x0000000000000000)
 
 /*   SH_RTC3_INT_CONFIG_TYPE                                            */
 /*   Description:  Type of Interrupt: 0=INT, 2=PMI, 4=NMI, 5=INIT       */
-#define SH_RTC3_INT_CONFIG_TYPE_SHFT             0
-#define SH_RTC3_INT_CONFIG_TYPE_MASK             0x0000000000000007
+#define SH_RTC3_INT_CONFIG_TYPE_SHFT			0
+#define SH_RTC3_INT_CONFIG_TYPE_MASK	__IA64_UL_CONST(0x0000000000000007)
 
 /*   SH_RTC3_INT_CONFIG_AGT                                             */
 /*   Description:  Agent, must be 0 for SHub                            */
-#define SH_RTC3_INT_CONFIG_AGT_SHFT              3
-#define SH_RTC3_INT_CONFIG_AGT_MASK              0x0000000000000008
+#define SH_RTC3_INT_CONFIG_AGT_SHFT			3
+#define SH_RTC3_INT_CONFIG_AGT_MASK	__IA64_UL_CONST(0x0000000000000008)
 
 /*   SH_RTC3_INT_CONFIG_PID                                             */
 /*   Description:  Processor ID, same setting as on targeted McKinley  */
-#define SH_RTC3_INT_CONFIG_PID_SHFT              4
-#define SH_RTC3_INT_CONFIG_PID_MASK              0x00000000000ffff0
+#define SH_RTC3_INT_CONFIG_PID_SHFT			4
+#define SH_RTC3_INT_CONFIG_PID_MASK	__IA64_UL_CONST(0x00000000000ffff0)
 
 /*   SH_RTC3_INT_CONFIG_BASE                                            */
 /*   Description:  Optional interrupt vector area, 2MB aligned          */
-#define SH_RTC3_INT_CONFIG_BASE_SHFT             21
-#define SH_RTC3_INT_CONFIG_BASE_MASK             0x0003ffffffe00000
+#define SH_RTC3_INT_CONFIG_BASE_SHFT			21
+#define SH_RTC3_INT_CONFIG_BASE_MASK	__IA64_UL_CONST(0x0003ffffffe00000)
 
 /*   SH_RTC3_INT_CONFIG_IDX                                             */
 /*   Description:  Targeted McKinley interrupt vector                   */
-#define SH_RTC3_INT_CONFIG_IDX_SHFT              52
-#define SH_RTC3_INT_CONFIG_IDX_MASK              0x0ff0000000000000
+#define SH_RTC3_INT_CONFIG_IDX_SHFT			52
+#define SH_RTC3_INT_CONFIG_IDX_MASK	__IA64_UL_CONST(0x0ff0000000000000)
 
 /* ==================================================================== */
 /*                    Register "SH_RTC3_INT_ENABLE"                     */
 /*                SHub RTC 3 Interrupt Enable Registers                 */
 /* ==================================================================== */
 
-#define SH1_RTC3_INT_ENABLE                      0x0000000110001700
-#define SH2_RTC3_INT_ENABLE                      0x0000000010001700
-#define SH_RTC3_INT_ENABLE_MASK                  0x0000000000000001
-#define SH_RTC3_INT_ENABLE_INIT                  0x0000000000000000
+#define SH1_RTC3_INT_ENABLE		__IA64_UL_CONST(0x0000000110001700)
+#define SH2_RTC3_INT_ENABLE		__IA64_UL_CONST(0x0000000010001700)
+#define SH_RTC3_INT_ENABLE_MASK		__IA64_UL_CONST(0x0000000000000001)
+#define SH_RTC3_INT_ENABLE_INIT		__IA64_UL_CONST(0x0000000000000000)
 
 /*   SH_RTC3_INT_ENABLE_RTC3_ENABLE                                     */
 /*   Description:  Enable RTC 3 Interrupt                               */
-#define SH_RTC3_INT_ENABLE_RTC3_ENABLE_SHFT      0
-#define SH_RTC3_INT_ENABLE_RTC3_ENABLE_MASK      0x0000000000000001
+#define SH_RTC3_INT_ENABLE_RTC3_ENABLE_SHFT		0
+#define SH_RTC3_INT_ENABLE_RTC3_ENABLE_MASK \
+					__IA64_UL_CONST(0x0000000000000001)
 
 /*   SH_EVENT_OCCURRED_RTC1_INT                                         */
 /*   Description:  Pending RTC 1 Interrupt                              */
-#define SH_EVENT_OCCURRED_RTC1_INT_SHFT          24
-#define SH_EVENT_OCCURRED_RTC1_INT_MASK          0x0000000001000000
+#define SH_EVENT_OCCURRED_RTC1_INT_SHFT			24
+#define SH_EVENT_OCCURRED_RTC1_INT_MASK	__IA64_UL_CONST(0x0000000001000000)
 
 /*   SH_EVENT_OCCURRED_RTC2_INT                                         */
 /*   Description:  Pending RTC 2 Interrupt                              */
-#define SH_EVENT_OCCURRED_RTC2_INT_SHFT          25
-#define SH_EVENT_OCCURRED_RTC2_INT_MASK          0x0000000002000000
+#define SH_EVENT_OCCURRED_RTC2_INT_SHFT			25
+#define SH_EVENT_OCCURRED_RTC2_INT_MASK	__IA64_UL_CONST(0x0000000002000000)
 
 /*   SH_EVENT_OCCURRED_RTC3_INT                                         */
 /*   Description:  Pending RTC 3 Interrupt                              */
-#define SH_EVENT_OCCURRED_RTC3_INT_SHFT          26
-#define SH_EVENT_OCCURRED_RTC3_INT_MASK          0x0000000004000000
+#define SH_EVENT_OCCURRED_RTC3_INT_SHFT			26
+#define SH_EVENT_OCCURRED_RTC3_INT_MASK	__IA64_UL_CONST(0x0000000004000000)
 
 /* ==================================================================== */
 /*                       Register "SH_IPI_ACCESS"                       */
 /*                 CPU interrupt Access Permission Bits                 */
 /* ==================================================================== */
 
-#define SH1_IPI_ACCESS                           0x0000000110060480
-#define SH2_IPI_ACCESS0                          0x0000000010060c00
-#define SH2_IPI_ACCESS1                          0x0000000010060c80
-#define SH2_IPI_ACCESS2                          0x0000000010060d00
-#define SH2_IPI_ACCESS3                          0x0000000010060d80
+#define SH1_IPI_ACCESS			__IA64_UL_CONST(0x0000000110060480)
+#define SH2_IPI_ACCESS0			__IA64_UL_CONST(0x0000000010060c00)
+#define SH2_IPI_ACCESS1			__IA64_UL_CONST(0x0000000010060c80)
+#define SH2_IPI_ACCESS2			__IA64_UL_CONST(0x0000000010060d00)
+#define SH2_IPI_ACCESS3			__IA64_UL_CONST(0x0000000010060d80)
 
 /* ==================================================================== */
 /*                        Register "SH_INT_CMPB"                        */
 /*                  RTC Compare Value for Processor B                   */
 /* ==================================================================== */
 
-#define SH1_INT_CMPB                             0x00000001101b0080
-#define SH2_INT_CMPB                             0x00000000101b0080
-#define SH_INT_CMPB_MASK                         0x007fffffffffffff
-#define SH_INT_CMPB_INIT                         0x0000000000000000
+#define SH1_INT_CMPB			__IA64_UL_CONST(0x00000001101b0080)
+#define SH2_INT_CMPB			__IA64_UL_CONST(0x00000000101b0080)
+#define SH_INT_CMPB_MASK		__IA64_UL_CONST(0x007fffffffffffff)
+#define SH_INT_CMPB_INIT		__IA64_UL_CONST(0x0000000000000000)
 
 /*   SH_INT_CMPB_REAL_TIME_CMPB                                         */
 /*   Description:  Real Time Clock Compare                              */
-#define SH_INT_CMPB_REAL_TIME_CMPB_SHFT          0
-#define SH_INT_CMPB_REAL_TIME_CMPB_MASK          0x007fffffffffffff
+#define SH_INT_CMPB_REAL_TIME_CMPB_SHFT			0
+#define SH_INT_CMPB_REAL_TIME_CMPB_MASK	__IA64_UL_CONST(0x007fffffffffffff)
 
 /* ==================================================================== */
 /*                        Register "SH_INT_CMPC"                        */
 /*                  RTC Compare Value for Processor C                   */
 /* ==================================================================== */
 
-#define SH1_INT_CMPC                             0x00000001101b0100
-#define SH2_INT_CMPC                             0x00000000101b0100
-#define SH_INT_CMPC_MASK                         0x007fffffffffffff
-#define SH_INT_CMPC_INIT                         0x0000000000000000
+#define SH1_INT_CMPC			__IA64_UL_CONST(0x00000001101b0100)
+#define SH2_INT_CMPC			__IA64_UL_CONST(0x00000000101b0100)
+#define SH_INT_CMPC_MASK		__IA64_UL_CONST(0x007fffffffffffff)
+#define SH_INT_CMPC_INIT		__IA64_UL_CONST(0x0000000000000000)
 
 /*   SH_INT_CMPC_REAL_TIME_CMPC                                         */
 /*   Description:  Real Time Clock Compare                              */
-#define SH_INT_CMPC_REAL_TIME_CMPC_SHFT          0
-#define SH_INT_CMPC_REAL_TIME_CMPC_MASK          0x007fffffffffffff
+#define SH_INT_CMPC_REAL_TIME_CMPC_SHFT			0
+#define SH_INT_CMPC_REAL_TIME_CMPC_MASK	__IA64_UL_CONST(0x007fffffffffffff)
 
 /* ==================================================================== */
 /*                        Register "SH_INT_CMPD"                        */
 /*                  RTC Compare Value for Processor D                   */
 /* ==================================================================== */
 
-#define SH1_INT_CMPD                             0x00000001101b0180
-#define SH2_INT_CMPD                             0x00000000101b0180
-#define SH_INT_CMPD_MASK                         0x007fffffffffffff
-#define SH_INT_CMPD_INIT                         0x0000000000000000
+#define SH1_INT_CMPD			__IA64_UL_CONST(0x00000001101b0180)
+#define SH2_INT_CMPD			__IA64_UL_CONST(0x00000000101b0180)
+#define SH_INT_CMPD_MASK		__IA64_UL_CONST(0x007fffffffffffff)
+#define SH_INT_CMPD_INIT		__IA64_UL_CONST(0x0000000000000000)
 
 /*   SH_INT_CMPD_REAL_TIME_CMPD                                         */
 /*   Description:  Real Time Clock Compare                              */
-#define SH_INT_CMPD_REAL_TIME_CMPD_SHFT          0
-#define SH_INT_CMPD_REAL_TIME_CMPD_MASK          0x007fffffffffffff
+#define SH_INT_CMPD_REAL_TIME_CMPD_SHFT			0
+#define SH_INT_CMPD_REAL_TIME_CMPD_MASK	__IA64_UL_CONST(0x007fffffffffffff)
 
 /* ==================================================================== */
 /*                Register "SH_MD_DQLP_MMR_DIR_PRIVEC0"                 */
 /*                      privilege vector for acc=0                      */
 /* ==================================================================== */
-
-#define SH1_MD_DQLP_MMR_DIR_PRIVEC0              0x0000000100030300
+#define SH1_MD_DQLP_MMR_DIR_PRIVEC0	__IA64_UL_CONST(0x0000000100030300)
 
 /* ==================================================================== */
 /*                Register "SH_MD_DQRP_MMR_DIR_PRIVEC0"                 */
 /*                      privilege vector for acc=0                      */
 /* ==================================================================== */
-
-#define SH1_MD_DQRP_MMR_DIR_PRIVEC0              0x0000000100050300
+#define SH1_MD_DQRP_MMR_DIR_PRIVEC0	__IA64_UL_CONST(0x0000000100050300)
 
 /* ==================================================================== */
 /* Some MMRs are functionally identical (or close enough) on both SHUB1 */
@@ -484,17 +486,17 @@
 /*                    Engine 0 Control and Status Register                    */
 /* ========================================================================== */
 
-#define SH2_BT_ENG_CSR_0                         0x0000000030040000
-#define SH2_BT_ENG_SRC_ADDR_0                    0x0000000030040080
-#define SH2_BT_ENG_DEST_ADDR_0                   0x0000000030040100
-#define SH2_BT_ENG_NOTIF_ADDR_0                  0x0000000030040180
+#define SH2_BT_ENG_CSR_0		__IA64_UL_CONST(0x0000000030040000)
+#define SH2_BT_ENG_SRC_ADDR_0		__IA64_UL_CONST(0x0000000030040080)
+#define SH2_BT_ENG_DEST_ADDR_0		__IA64_UL_CONST(0x0000000030040100)
+#define SH2_BT_ENG_NOTIF_ADDR_0		__IA64_UL_CONST(0x0000000030040180)
 
 /* ========================================================================== */
 /*                       BTE interfaces 1-3                                   */
 /* ========================================================================== */
 
-#define SH2_BT_ENG_CSR_1                         0x0000000030050000
-#define SH2_BT_ENG_CSR_2                         0x0000000030060000
-#define SH2_BT_ENG_CSR_3                         0x0000000030070000
+#define SH2_BT_ENG_CSR_1		__IA64_UL_CONST(0x0000000030050000)
+#define SH2_BT_ENG_CSR_2		__IA64_UL_CONST(0x0000000030060000)
+#define SH2_BT_ENG_CSR_3		__IA64_UL_CONST(0x0000000030070000)
 
 #endif /* _ASM_IA64_SN_SHUB_MMR_H */

--------------000702090704030403000300--
