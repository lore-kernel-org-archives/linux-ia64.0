From: dcn@sgi.com (Dean Nelson)
Date: Wed, 23 Mar 2005 19:07:49 +0000
Subject: [PATCH] Define some additional SHub1 and Shub2 register symbols
Message-Id: <4241BE85.mailxH8Q11M1PC@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Define some additional SHub1 and SHub2 register symbols.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/include/asm-ia64/sn/shub_mmr.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/shub_mmr.h	2005-03-08 09:06:20.255228689 -0600
+++ linux-2.6/include/asm-ia64/sn/shub_mmr.h	2005-03-08 09:21:45.493222414 -0600
@@ -368,6 +368,17 @@
 #define SH_EVENT_OCCURRED_RTC3_INT_MASK          0x0000000004000000
 
 /* ================================== */
+/*                       Register "SH_IPI_ACCESS"                       */
+/*                 CPU interrupt Access Permission Bits                 */
+/* ================================== */
+
+#define SH1_IPI_ACCESS                           0x0000000110060480
+#define SH2_IPI_ACCESS0                          0x0000000010060c00
+#define SH2_IPI_ACCESS1                          0x0000000010060c80
+#define SH2_IPI_ACCESS2                          0x0000000010060d00
+#define SH2_IPI_ACCESS3                          0x0000000010060d80
+
+/* ================================== */
 /*                        Register "SH_INT_CMPB"                        */
 /*                  RTC Compare Value for Processor B                   */
 /* ================================== */
@@ -412,6 +423,19 @@
 #define SH_INT_CMPD_REAL_TIME_CMPD_SHFT          0
 #define SH_INT_CMPD_REAL_TIME_CMPD_MASK          0x007fffffffffffff
 
+/* ================================== */
+/*                Register "SH_MD_DQLP_MMR_DIR_PRIVEC0"                 */
+/*                      privilege vector for acc=0                      */
+/* ================================== */
+
+#define SH1_MD_DQLP_MMR_DIR_PRIVEC0              0x0000000100030300
+
+/* ================================== */
+/*                Register "SH_MD_DQRP_MMR_DIR_PRIVEC0"                 */
+/*                      privilege vector for acc=0                      */
+/* ================================== */
+
+#define SH1_MD_DQRP_MMR_DIR_PRIVEC0              0x0000000100050300
 
 /* ================================== */
 /* Some MMRs are functionally identical (or close enough) on both SHUB1 */
