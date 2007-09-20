From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 20 Sep 2007 20:21:11 +0000
Subject: [patch 1/2] ia64: abstract SAL_CALL wrapper to allow other firmware entry points
Message-Id: <200709201421.12094.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200709201420.24023.bjorn.helgaas@hp.com>
In-Reply-To: <200709201420.24023.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-acpi@vger.kernel.org

SAL_CALL() always calls through the ia64_sal function pointer.  I am adding
new functionality that needs the same conventions as SAL_CALL (FP regs
saved/restored, sal_lock acquired, etc), but doesn't use the ia64_sal
function pointer.

This patch pulls the body of SAL_CALL out into a new "IA64_FW_CALL" that
takes care of these calling conventions, but allows the caller to specify
either ia64_sal or some other firmware entry point.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work2/include/asm-ia64/sal.h
=================================--- work2.orig/include/asm-ia64/sal.h	2007-09-19 10:25:12.000000000 -0600
+++ work2/include/asm-ia64/sal.h	2007-09-19 10:27:15.000000000 -0600
@@ -46,25 +46,28 @@
 extern spinlock_t sal_lock;
 
 /* SAL spec _requires_ eight args for each call. */
-#define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)	\
-	result = (*ia64_sal)(a0,a1,a2,a3,a4,a5,a6,a7)
+#define __IA64_FW_CALL(entry,result,a0,a1,a2,a3,a4,a5,a6,a7)	\
+	result = (*entry)(a0,a1,a2,a3,a4,a5,a6,a7)
 
-# define SAL_CALL(result,args...) do {				\
+# define IA64_FW_CALL(entry,result,args...) do {		\
 	unsigned long __ia64_sc_flags;				\
 	struct ia64_fpreg __ia64_sc_fr[6];			\
 	ia64_save_scratch_fpregs(__ia64_sc_fr);			\
 	spin_lock_irqsave(&sal_lock, __ia64_sc_flags);		\
-	__SAL_CALL(result, args);				\
+	__IA64_FW_CALL(entry, result, args);			\
 	spin_unlock_irqrestore(&sal_lock, __ia64_sc_flags);	\
 	ia64_load_scratch_fpregs(__ia64_sc_fr);			\
 } while (0)
 
+# define SAL_CALL(result,args...)			\
+	IA64_FW_CALL(ia64_sal, result, args);
+
 # define SAL_CALL_NOLOCK(result,args...) do {		\
 	unsigned long __ia64_scn_flags;			\
 	struct ia64_fpreg __ia64_scn_fr[6];		\
 	ia64_save_scratch_fpregs(__ia64_scn_fr);	\
 	local_irq_save(__ia64_scn_flags);		\
-	__SAL_CALL(result, args);			\
+	__IA64_FW_CALL(ia64_sal, result, args);		\
 	local_irq_restore(__ia64_scn_flags);		\
 	ia64_load_scratch_fpregs(__ia64_scn_fr);	\
 } while (0)
@@ -73,7 +76,7 @@
 	struct ia64_fpreg __ia64_scs_fr[6];		\
 	ia64_save_scratch_fpregs(__ia64_scs_fr);	\
 	preempt_disable();				\
-	__SAL_CALL(result, args);			\
+	__IA64_FW_CALL(ia64_sal, result, args);		\
 	preempt_enable();				\
 	ia64_load_scratch_fpregs(__ia64_scs_fr);	\
 } while (0)
