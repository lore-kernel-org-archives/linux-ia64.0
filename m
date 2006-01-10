From: Dean Nelson <dcn@sgi.com>
Date: Tue, 10 Jan 2006 17:12:32 +0000
Subject: [PATCH 2/2] move xpc.h to include/asm-ia64/sn
Message-Id: <20060110171232.GA32287@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cleanup a few items after moving xpc.h from arch/ia64/sn/kernel to
include/asm-ia64/sn.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/include/asm-ia64/sn/xpc.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/xpc.h	2006-01-10 08:25:43.705867053 -0600
+++ linux-2.6/include/asm-ia64/sn/xpc.h	2006-01-10 08:25:43.724419924 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -11,8 +11,8 @@
  * Cross Partition Communication (XPC) structures and macros.
  */
 
-#ifndef _IA64_SN_KERNEL_XPC_H
-#define _IA64_SN_KERNEL_XPC_H
+#ifndef _ASM_IA64_SN_XPC_H
+#define _ASM_IA64_SN_XPC_H
 
 
 #include <linux/config.h>
@@ -1270,5 +1270,5 @@
 }
 
 
-#endif /* _IA64_SN_KERNEL_XPC_H */
+#endif /* _ASM_IA64_SN_XPC_H */
 
Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2006-01-10 08:00:42.441460880 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2006-01-10 08:27:56.373546380 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -24,7 +24,7 @@
 #include <linux/slab.h>
 #include <asm/sn/bte.h>
 #include <asm/sn/sn_sal.h>
-#include "xpc.h"
+#include <asm/sn/xpc.h>
 
 
 /*
Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-01-10 08:25:43.661926041 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-01-10 08:28:35.291612451 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -59,7 +59,7 @@
 #include <asm/sn/sn_sal.h>
 #include <asm/kdebug.h>
 #include <asm/uaccess.h>
-#include "xpc.h"
+#include <asm/sn/xpc.h>
 
 
 /* define two XPC debug device structures to be used with dev_dbg() et al */
Index: linux-2.6/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_partition.c	2006-01-10 08:00:45.579826575 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_partition.c	2006-01-10 08:29:03.072096726 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -28,7 +28,7 @@
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/nodepda.h>
 #include <asm/sn/addrs.h>
-#include "xpc.h"
+#include <asm/sn/xpc.h>
 
 
 /* XPC is exiting flag */
