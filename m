From: Dean Nelson <dcn@sgi.com>
Date: Mon, 09 Feb 2009 16:25:20 +0000
Subject: [PATCH] SGI IA64 UV: fix ia64 build error in the linux-next tree
Message-Id: <20090209162520.GA4882@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Fix the ia64 build error that occurs in the linux-next tree by introducing
an ia64 version of uv.h.  Additionally, clean up the usage of is_uv_system().

Signed-off-by: Dean Nelson <dcn@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>

---

 arch/ia64/include/asm/uv/uv.h  |   13 +++++++++++++
 drivers/misc/sgi-gru/gru.h     |    2 --
 drivers/misc/sgi-gru/grufile.c |   18 +++---------------
 drivers/misc/sgi-xp/xp.h       |   22 ++++++++--------------
 4 files changed, 24 insertions(+), 31 deletions(-)

Index: linux/arch/ia64/include/asm/uv/uv.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/include/asm/uv/uv.h	2009-02-09 09:18:45.657924900 -0600
@@ -0,0 +1,13 @@
+#ifndef _ASM_IA64_UV_UV_H
+#define _ASM_IA64_UV_UV_H
+
+#include <asm/system.h>
+#include <asm/sn/simulator.h>
+
+static inline int is_uv_system(void)
+{
+	/* temporary support for running on hardware simulator */
+	return IS_MEDUSA() || ia64_platform_is("uv");
+}
+
+#endif	/* _ASM_IA64_UV_UV_H */
Index: linux/drivers/misc/sgi-gru/gru.h
=================================--- linux.orig/drivers/misc/sgi-gru/gru.h	2009-02-09 09:18:43.485658003 -0600
+++ linux/drivers/misc/sgi-gru/gru.h	2009-02-09 09:18:45.677927344 -0600
@@ -19,8 +19,6 @@
 #ifndef __GRU_H__
 #define __GRU_H__
 
-#include <asm/uv/uv.h>
-
 /*
  * GRU architectural definitions
  */
Index: linux/drivers/misc/sgi-gru/grufile.c
=================================--- linux.orig/drivers/misc/sgi-gru/grufile.c	2009-02-09 09:18:43.485658003 -0600
+++ linux/drivers/misc/sgi-gru/grufile.c	2009-02-09 09:18:45.697930179 -0600
@@ -36,23 +36,11 @@
 #include <linux/interrupt.h>
 #include <linux/proc_fs.h>
 #include <linux/uaccess.h>
+#include <asm/uv/uv.h>
 #include "gru.h"
 #include "grulib.h"
 #include "grutables.h"
 
-#if defined CONFIG_X86_64
-#include <asm/genapic.h>
-#include <asm/irq.h>
-#define IS_UV()		is_uv_system()
-#elif defined CONFIG_IA64
-#include <asm/system.h>
-#include <asm/sn/simulator.h>
-/* temp support for running on hardware simulator */
-#define IS_UV()		IS_MEDUSA() || ia64_platform_is("uv")
-#else
-#define IS_UV()		0
-#endif
-
 #include <asm/uv/uv_hub.h>
 #include <asm/uv/uv_mmrs.h>
 
@@ -381,7 +369,7 @@ static int __init gru_init(void)
 	char id[10];
 	void *gru_start_vaddr;
 
-	if (!IS_UV())
+	if (!is_uv_system())
 		return 0;
 
 #if defined CONFIG_IA64
@@ -451,7 +439,7 @@ static void __exit gru_exit(void)
 	int order = get_order(sizeof(struct gru_state) *
 			      GRU_CHIPLETS_PER_BLADE);
 
-	if (!IS_UV())
+	if (!is_uv_system())
 		return;
 
 	for (i = 0; i < GRU_CHIPLETS_PER_BLADE; i++)
Index: linux/drivers/misc/sgi-xp/xp.h
=================================--- linux.orig/drivers/misc/sgi-xp/xp.h	2009-02-09 09:18:43.489658800 -0600
+++ linux/drivers/misc/sgi-xp/xp.h	2009-02-09 09:19:18.065905314 -0600
@@ -15,21 +15,19 @@
 
 #include <linux/mutex.h>
 
+#if defined CONFIG_X86_UV || defined CONFIG_IA64_SGI_UV
 #include <asm/uv/uv.h>
+#define is_uv()		is_uv_system()
+#endif
 
-#ifdef CONFIG_IA64
+#ifndef is_uv
+#define is_uv()		0
+#endif
+
+#if defined CONFIG_IA64
 #include <asm/system.h>
 #include <asm/sn/arch.h>	/* defines is_shub1() and is_shub2() */
 #define is_shub()	ia64_platform_is("sn2")
-#ifdef CONFIG_IA64_SGI_UV
-#define is_uv()		ia64_platform_is("uv")
-#else
-#define is_uv()		0
-#endif
-#endif
-#ifdef CONFIG_X86_64
-#include <asm/genapic.h>
-#define is_uv()		is_uv_system()
 #endif
 
 #ifndef is_shub1
@@ -44,10 +42,6 @@
 #define is_shub()	0
 #endif
 
-#ifndef is_uv
-#define is_uv()		0
-#endif
-
 #ifdef USE_DBUG_ON
 #define DBUG_ON(condition)	BUG_ON(condition)
 #else
