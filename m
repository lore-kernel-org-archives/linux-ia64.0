From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 01 Apr 2003 18:06:44 +0000
Subject: [Linux-ia64] [PATCH] sal calls w/o taking sal_lock
Message-Id: <marc-linux-ia64-105590723705376@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch adds SAL_CALL_NOLOCK so that platforms may call the SAL
without taking a lock, if appropriate.  The ia64_sal_mc_rendez() has
been changed to use it, since it won't return until all CPUs have been
rendevoused by the SAL, if I understand correctly.  It's also used by
various SN specific SAL routines that access the system controllers
and might be useful to other plaforms.

Thanks,
Jesse


diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64/include/asm-ia64/sal.h linux-2.5.64-salcallnolock/include/asm-ia64/sal.h
--- linux-2.5.64-ia64/include/asm-ia64/sal.h	Fri Mar  7 16:02:45 2003
+++ linux-2.5.64-salcallnolock/include/asm-ia64/sal.h	Tue Apr  1 09:56:02 2003
@@ -46,6 +46,16 @@
 	ia64_load_scratch_fpregs(fr);                   \
 } while (0)
 
+# define SAL_CALL_NOLOCK(result,args...) do {		\
+	unsigned long flags;				\
+	struct ia64_fpreg fr[6];			\
+	ia64_save_scratch_fpregs(fr);                   \
+	local_irq_save(flags);				\
+	__SAL_CALL(result,args);			\
+	local_irq_restore(flags);			\
+	ia64_load_scratch_fpregs(fr);                   \
+} while (0)
+
 #define SAL_SET_VECTORS			0x01000000
 #define SAL_GET_STATE_INFO		0x01000001
 #define SAL_GET_STATE_INFO_SIZE		0x01000002
@@ -685,14 +695,15 @@
 }
 
 /*
- * Causes the processor to go into a spin loop within SAL where SAL awaits a wakeup from
- * the monarch processor.
+ * Causes the processor to go into a spin loop within SAL where SAL awaits a wakeup
+ * from the monarch processor.  Must not lock, this will not return on any cpu until
+ * the monarch processor sends a wake up.
  */
 static inline s64
 ia64_sal_mc_rendez (void)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_MC_RENDEZ, 0, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(isrv, SAL_MC_RENDEZ, 0, 0, 0, 0, 0, 0, 0);
 	return isrv.status;
 }
 

