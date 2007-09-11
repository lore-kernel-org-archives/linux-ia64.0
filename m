From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 11 Sep 2007 23:15:58 +0000
Subject: [patch 1/2] ia64: change SAL wrappers from macros to functions and export them
Message-Id: <200709111715.58586.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200709111714.57095.bjorn.helgaas@hp.com>
In-Reply-To: <200709111714.57095.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

[patch] ia64: change SAL wrappers from macros to functions and export them

This changes the body of SAL_CALL() from a macro into a function,
fw_call_lock().  The reasons to do this are:

    - SAL_CALL() always calls through the ia64_sal function pointer,
      and I want to add a new functionality that needs the same conventions
      as SAL_CALL (FP regs saved/restored, sal_lock acquired, etc), but
      doesn't use the ia64_sal function pointer, and

    - I'd like to make this new functionality a module, and I'd rather export
      fw_call_lock() than sal_lock.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: w/include/asm-ia64/sal.h
=================================--- w.orig/include/asm-ia64/sal.h	2007-09-11 15:41:47.000000000 -0600
+++ w/include/asm-ia64/sal.h	2007-09-11 15:41:54.000000000 -0600
@@ -45,38 +45,38 @@
 
 extern spinlock_t sal_lock;
 
-/* SAL spec _requires_ eight args for each call. */
-#define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)	\
-	result = (*ia64_sal)(a0,a1,a2,a3,a4,a5,a6,a7)
-
-# define SAL_CALL(result,args...) do {				\
-	unsigned long __ia64_sc_flags;				\
-	struct ia64_fpreg __ia64_sc_fr[6];			\
-	ia64_save_scratch_fpregs(__ia64_sc_fr);			\
-	spin_lock_irqsave(&sal_lock, __ia64_sc_flags);		\
-	__SAL_CALL(result, args);				\
-	spin_unlock_irqrestore(&sal_lock, __ia64_sc_flags);	\
-	ia64_load_scratch_fpregs(__ia64_sc_fr);			\
-} while (0)
-
-# define SAL_CALL_NOLOCK(result,args...) do {		\
-	unsigned long __ia64_scn_flags;			\
-	struct ia64_fpreg __ia64_scn_fr[6];		\
-	ia64_save_scratch_fpregs(__ia64_scn_fr);	\
-	local_irq_save(__ia64_scn_flags);		\
-	__SAL_CALL(result, args);			\
-	local_irq_restore(__ia64_scn_flags);		\
-	ia64_load_scratch_fpregs(__ia64_scn_fr);	\
-} while (0)
-
-# define SAL_CALL_REENTRANT(result,args...) do {	\
-	struct ia64_fpreg __ia64_scs_fr[6];		\
-	ia64_save_scratch_fpregs(__ia64_scs_fr);	\
-	preempt_disable();				\
-	__SAL_CALL(result, args);			\
-	preempt_enable();				\
-	ia64_load_scratch_fpregs(__ia64_scs_fr);	\
-} while (0)
+struct ia64_sal_retval {
+	/*
+	 * A zero status value indicates call completed without error.
+	 * A negative status value indicates reason of call failure.
+	 * A positive status value indicates success but an
+	 * informational value should be printed (e.g., "reboot for
+	 * change to take effect").
+	 */
+	s64 status;
+	u64 v0;
+	u64 v1;
+	u64 v2;
+};
+
+typedef struct ia64_sal_retval (*ia64_sal_handler) (u64, ...);
+extern ia64_sal_handler ia64_sal;
+
+extern void fw_call_lock(ia64_sal_handler, struct ia64_sal_retval *,
+	u64, u64, u64, u64, u64, u64, u64, u64);
+extern void fw_call_nolock(ia64_sal_handler, struct ia64_sal_retval *,
+	u64, u64, u64, u64, u64, u64, u64, u64);
+extern void fw_call_reentrant(ia64_sal_handler, struct ia64_sal_retval *,
+	u64, u64, u64, u64, u64, u64, u64, u64);
+
+# define SAL_CALL(result, args...)		\
+	fw_call_lock(ia64_sal, &result, args)
+
+# define SAL_CALL_NOLOCK(result, args...)	\
+	fw_call_nolock(ia64_sal, &result, args)
+
+# define SAL_CALL_REENTRANT(result,args...)	\
+	fw_call_reentrant(ia64_sal, &result, args)
 
 #define SAL_SET_VECTORS			0x01000000
 #define SAL_GET_STATE_INFO		0x01000001
@@ -95,22 +95,6 @@
 
 #define SAL_UPDATE_PAL			0x01000020
 
-struct ia64_sal_retval {
-	/*
-	 * A zero status value indicates call completed without error.
-	 * A negative status value indicates reason of call failure.
-	 * A positive status value indicates success but an
-	 * informational value should be printed (e.g., "reboot for
-	 * change to take effect").
-	 */
-	s64 status;
-	u64 v0;
-	u64 v1;
-	u64 v2;
-};
-
-typedef struct ia64_sal_retval (*ia64_sal_handler) (u64, ...);
-
 enum {
 	SAL_FREQ_BASE_PLATFORM = 0,
 	SAL_FREQ_BASE_INTERVAL_TIMER = 1,
@@ -228,7 +212,6 @@
 	u64 vector;		/* interrupt vector in range 0x10-0xff */
 } ia64_sal_desc_ap_wakeup_t ;
 
-extern ia64_sal_handler ia64_sal;
 extern struct ia64_sal_desc_ptc *ia64_ptc_domain_info;
 
 extern unsigned short sal_revision;	/* supported SAL spec revision */
@@ -692,7 +675,7 @@
 {
 	struct ia64_sal_retval isrv;
 	SAL_CALL_REENTRANT(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
-	              sal_info, 0, 0, 0, 0);
+	              (u64) sal_info, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
 
Index: w/arch/ia64/kernel/sal.c
=================================--- w.orig/arch/ia64/kernel/sal.c	2007-09-11 15:41:47.000000000 -0600
+++ w/arch/ia64/kernel/sal.c	2007-09-11 16:08:40.000000000 -0600
@@ -83,6 +83,50 @@
 	return str;
 }
 
+void
+fw_call_lock(ia64_sal_handler fn, struct ia64_sal_retval *result,
+        u64 a0, u64 a1, u64 a2, u64 a3, u64 a4, u64 a5, u64 a6, u64 a7)
+{
+	unsigned long flags;
+	struct ia64_fpreg fr[6];
+
+	ia64_save_scratch_fpregs(fr);
+	spin_lock_irqsave(&sal_lock, flags);
+	*result = (*fn)(a0, a1, a2, a3, a4, a5, a6, a7);
+	spin_unlock_irqrestore(&sal_lock, flags);
+	ia64_load_scratch_fpregs(fr);
+}
+EXPORT_SYMBOL_GPL(fw_call_lock);
+
+void
+fw_call_nolock(ia64_sal_handler fn, struct ia64_sal_retval *result,
+        u64 a0, u64 a1, u64 a2, u64 a3, u64 a4, u64 a5, u64 a6, u64 a7)
+{
+	unsigned long flags;
+	struct ia64_fpreg fr[6];
+
+	ia64_save_scratch_fpregs(fr);
+	local_irq_save(flags);
+	*result = (*fn)(a0, a1, a2, a3, a4, a5, a6, a7);
+	local_irq_restore(flags);
+	ia64_load_scratch_fpregs(fr);
+}
+EXPORT_SYMBOL_GPL(fw_call_nolock);
+
+void
+fw_call_reentrant(ia64_sal_handler fn, struct ia64_sal_retval *result,
+        u64 a0, u64 a1, u64 a2, u64 a3, u64 a4, u64 a5, u64 a6, u64 a7)
+{
+	struct ia64_fpreg fr[6];
+
+	ia64_save_scratch_fpregs(fr);
+	preempt_disable();
+	*result = (*fn)(a0, a1, a2, a3, a4, a5, a6, a7);
+	preempt_enable();
+	ia64_load_scratch_fpregs(fr);
+}
+EXPORT_SYMBOL_GPL(fw_call_reentrant);
+
 void __init
 ia64_sal_handler_init (void *entry_point, void *gpval)
 {
Index: w/include/asm-ia64/sn/sn_sal.h
=================================--- w.orig/include/asm-ia64/sn/sn_sal.h	2007-09-11 15:41:47.000000000 -0600
+++ w/include/asm-ia64/sn/sn_sal.h	2007-09-11 15:41:54.000000000 -0600
@@ -547,7 +547,7 @@
 ia64_sn_sys_serial_get(char *buf)
 {
 	struct ia64_sal_retval ret_stuff;
-	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_SYS_SERIAL_GET, buf, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_SYS_SERIAL_GET, (u64) buf, 0, 0, 0, 0, 0, 0);
 	return ret_stuff.status;
 }
 
@@ -968,8 +968,8 @@
 		      u64 banlen)
 {
 	struct ia64_sal_retval rv;
-	SAL_CALL_NOLOCK(rv, SN_SAL_GET_FIT_COMPT, nasid, index, fitentry,
-			banbuf, banlen, 0, 0);
+	SAL_CALL_NOLOCK(rv, SN_SAL_GET_FIT_COMPT, nasid, index, (u64) fitentry,
+			(u64) banbuf, banlen, 0, 0);
 	return (int) rv.status;
 }
 
