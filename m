From: Jes Sorensen <jes@sgi.com>
Date: Wed, 08 Feb 2006 15:19:28 +0000
Subject: [patch] prevent sn2 specific code to be run in generic kernels
Message-Id: <yq08xslnain.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Last two cases where sn2 specific init calls would execute on any
platform when running a generic kernel.

Both cases are non fatal, which is why we didn't notice it
before. Still shouldn't be run.

Cheers,
Jes

Prevent SN2 specific code to be executed on non SN2 platforms when
compiling a generic kernel.

Signed-off-by: Jes Sorensen <jes@sgi.com>

----

 arch/ia64/sn/kernel/mca.c           |    5 +++--
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    5 ++++-
 2 files changed, 7 insertions(+), 3 deletions(-)

Index: linux-2.6/arch/ia64/sn/kernel/mca.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/mca.c
+++ linux-2.6/arch/ia64/sn/kernel/mca.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2004 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/types.h>
@@ -137,7 +137,8 @@
 
 static int __init sn_salinfo_init(void)
 {
-	salinfo_platform_oemdata = &sn_salinfo_platform_oemdata;
+	if (ia64_platform_is("sn2"))
+		salinfo_platform_oemdata = &sn_salinfo_platform_oemdata;
 	return 0;
 }
 
Index: linux-2.6/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ linux-2.6/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2004-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Silicon Graphics, Inc. All rights reserved.
  *
  * SGI Altix topology and hardware performance monitoring API.
  * Mark Goodwin <markgw@sgi.com>. 
@@ -973,6 +973,9 @@
 {
 	int e;
 
+	if (!ia64_platform_is("sn2"))
+		return 0;
+
 	sn_hwperf_init();
 
 	/*

