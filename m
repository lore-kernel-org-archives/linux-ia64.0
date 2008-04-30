From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 30 Apr 2008 12:29:21 +0000
Subject: [PATCH 08/15] ia64/pv_ops: paravirtualize minstate.h.
Message-Id: <12095585683403-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077165494039-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077165494039-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

paravirtualize minstate.h which are hand written assembly code.
They include sensitive or performance critical privileged
instructions. So that they are appropriate for paravirtualization.

Signed-off-by: Yaozu (Eddie) Dong <eddie.dong@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/minstate.h      |   13 +++++++------
 arch/ia64/kernel/paravirt_inst.h |   29 +++++++++++++++++++++++++++++
 include/asm-ia64/native/inst.h   |    2 ++
 3 files changed, 38 insertions(+), 6 deletions(-)
 create mode 100644 arch/ia64/kernel/paravirt_inst.h

diff --git a/arch/ia64/kernel/minstate.h b/arch/ia64/kernel/minstate.h
index 7c548ac..9db53cf 100644
--- a/arch/ia64/kernel/minstate.h
+++ b/arch/ia64/kernel/minstate.h
@@ -2,6 +2,7 @@
 #include <asm/cache.h>
 
 #include "entry.h"
+#include "paravirt_inst.h"
 
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 /* read ar.itc in advance, and use it before leaving bank 0 */
@@ -40,16 +41,16 @@
  * Note that psr.ic is NOT turned on by this macro.  This is so that
  * we can pass interruption state as arguments to a handler.
  */
-#define DO_SAVE_MIN(COVER,SAVE_IFS,EXTRA)							\
+#define IA64_NATIVE_DO_SAVE_MIN(__COVER,SAVE_IFS,EXTRA)						\
 	mov r16=IA64_KR(CURRENT);	/* M */							\
 	mov r27=ar.rsc;			/* M */							\
 	mov r20=r1;			/* A */							\
 	mov r25=ar.unat;		/* M */							\
-	mov r29=cr.ipsr;		/* M */							\
+	MOV_FROM_IPSR(p0,r29);		/* M */							\
 	mov r26=ar.pfs;			/* I */							\
-	mov r28=cr.iip;			/* M */							\
+	MOV_FROM_IIP(r28);		/* M */							\
 	mov r21=ar.fpsr;		/* M */							\
-	COVER;				/* B;; (or nothing) */					\
+	__COVER;			/* B;; (or nothing) */					\
 	;;											\
 	adds r16=IA64_TASK_THREAD_ON_USTACK_OFFSET,r16;						\
 	;;											\
@@ -206,6 +207,6 @@
 	st8 [r25]=r10;      	/* ar.ssd */	\
 	;;
 
-#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover, mov r30=cr.ifs,)
-#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover, mov r30=cr.ifs, mov r15=r19)
+#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(COVER, mov r30=cr.ifs,)
+#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(COVER, mov r30=cr.ifs, mov r15=r19)
 #define SAVE_MIN		DO_SAVE_MIN(     , mov r30=r0, )
diff --git a/arch/ia64/kernel/paravirt_inst.h b/arch/ia64/kernel/paravirt_inst.h
new file mode 100644
index 0000000..5cad6fb
--- /dev/null
+++ b/arch/ia64/kernel/paravirt_inst.h
@@ -0,0 +1,29 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/paravirt_inst.h
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifdef __IA64_ASM_PARAVIRTUALIZED_XEN
+#include <asm/xen/inst.h>
+#include <asm/xen/minstate.h>
+#else
+#include <asm/native/inst.h>
+#endif
+
diff --git a/include/asm-ia64/native/inst.h b/include/asm-ia64/native/inst.h
index 295fde3..c167b7d 100644
--- a/include/asm-ia64/native/inst.h
+++ b/include/asm-ia64/native/inst.h
@@ -20,6 +20,8 @@
  *
  */
 
+#define DO_SAVE_MIN		IA64_NATIVE_DO_SAVE_MIN
+
 #ifdef CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK
 # define PARAVIRT_POISON	0xdeadbeefbaadf00d
 # define CLOBBER(clob)				\
-- 
1.5.3

