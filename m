From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 16 Sep 2003 23:25:01 +0000
Subject: [patch] small sn2 cleanup
Message-Id: <marc-linux-ia64-106375472623953@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

Attached is a small cleanup patch for the sn2 header files which removes
some cases of excessive header file inclusion.

Cheers,
Jes


=====================================linux/include/asm-ia64/sn/ksys/elsc.h
=====================================
--- /usr/tmp/TmpDir.14371-0/linux/include/asm-ia64/sn/ksys/elsc.h_1.5	Tue Sep 16 15:42:28 2003
+++ linux/include/asm-ia64/sn/ksys/elsc.h	Tue Sep 16 14:44:22 2003
@@ -9,9 +9,6 @@
 #ifndef _ASM_SN_KSYS_ELSC_H
 #define _ASM_SN_KSYS_ELSC_H
 
-#include <linux/config.h>
-#include <asm/sn/ksys/l1.h>
-
 /*
  * Error codes
  *

=====================================linux/include/asm-ia64/sn/ksys/l1.h
=====================================
--- /usr/tmp/TmpDir.14371-0/linux/include/asm-ia64/sn/ksys/l1.h_1.6	Tue Sep 16 15:42:28 2003
+++ linux/include/asm-ia64/sn/ksys/l1.h	Tue Sep 16 15:39:19 2003
@@ -10,10 +10,7 @@
 #ifndef _ASM_SN_KSYS_L1_H
 #define _ASM_SN_KSYS_L1_H
 
-#include <linux/config.h>
-#include <asm/sn/vector.h>
-#include <asm/sn/addrs.h>
-#include <asm/atomic.h>
+#include <asm/sn/types.h>
 
 /* L1 Target Addresses */
 /*
@@ -39,18 +36,6 @@
 #define L1_ADDR_TASK_BEDROCK	0x05	/* bedrock		*/
 #define L1_ADDR_TASK_GENERAL	0x06	/* general requests	*/
 
-#define L1_ADDR_LOCAL				\
-    (L1_ADDR_TYPE_L1 << L1_ADDR_TYPE_SHFT) |	\
-    (L1_ADDR_RACK_LOCAL << L1_ADDR_RACK_SHFT) |	\
-    (L1_ADDR_BAY_LOCAL << L1_ADDR_BAY_SHFT)
-
-#define L1_ADDR_LOCALIO					\
-    (L1_ADDR_TYPE_IOBRICK << L1_ADDR_TYPE_SHFT) |	\
-    (L1_ADDR_RACK_LOCAL << L1_ADDR_RACK_SHFT) |		\
-    (L1_ADDR_BAY_LOCAL << L1_ADDR_BAY_SHFT)
-
-#define L1_ADDR_LOCAL_SHFT	L1_ADDR_BAY_SHFT
-
 /* response argument types */
 #define L1_ARG_INT		0x00	/* 4-byte integer (big-endian)	*/
 #define L1_ARG_ASCII		0x01	/* null-terminated ASCII string */
@@ -133,18 +118,6 @@
 #define L1_EEP_IUSE		3	/* internal use area */
 #define L1_EEP_SPD		4	/* serial presence detect record */
 
-typedef uint32_t l1addr_t;
-
-#define L1_BUILD_ADDR(addr,at,r,s,t)					\
-    (*(l1addr_t *)(addr) = ((l1addr_t)(at) << L1_ADDR_TYPE_SHFT) |	\
-			     ((l1addr_t)(r)  << L1_ADDR_RACK_SHFT) |	\
-			     ((l1addr_t)(s)  << L1_ADDR_BAY_SHFT) |	\
-			     ((l1addr_t)(t)  << L1_ADDR_TASK_SHFT))
-
-#define L1_ADDRESS_TO_TASK(addr,trb,tsk)				\
-    (*(l1addr_t *)(addr) = (l1addr_t)(trb) |				\
-    			     ((l1addr_t)(tsk) << L1_ADDR_TASK_SHFT))
-
 #define L1_DISPLAY_LINE_LENGTH	12	/* L1 display characters/line */
 
 #ifdef L1_DISP_2LINES
@@ -154,11 +127,9 @@
 					 * to system software */
 #endif
 
-#define bzero(d, n)	memset((d), 0, (n))
-
 int	elsc_display_line(nasid_t nasid, char *line, int lnum);
-int	iobrick_rack_bay_type_get( nasid_t nasid, uint *rack,
-				   uint *bay, uint *brick_type );
+int	iobrick_rack_bay_type_get( nasid_t nasid, unsigned int *rack,
+				   unsigned int *bay, unsigned int *brick_type );
 int	iobrick_module_get( nasid_t nasid );
 
 

=====================================linux/include/asm-ia64/sn/pci/pcibr_private.h
=====================================
--- /usr/tmp/TmpDir.14371-0/linux/include/asm-ia64/sn/pci/pcibr_private.h_1.8	Tue Sep 16 15:42:28 2003
+++ linux/include/asm-ia64/sn/pci/pcibr_private.h	Tue Sep 16 15:30:22 2003
@@ -15,11 +15,9 @@
  * should ever peek into this file.
  */
 
-#include <linux/config.h>
 #include <linux/pci.h>
 #include <asm/sn/pci/pcibr.h>
 #include <asm/sn/pci/pciio_private.h>
-#include <asm/sn/ksys/l1.h>
 
 /*
  * convenience typedefs
