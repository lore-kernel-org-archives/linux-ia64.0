From: Keith Owens <kaos@sgi.com>
Date: Sat, 22 Mar 2003 04:51:54 +0000
Subject: [Linux-ia64] [patch] 2.4.20 ia64_sal_mc_rendez must not lock
Message-Id: <marc-linux-ia64-105590723705290@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No cpu will return from ia64_sal_mc_rendez() until all cpus have
entered rendezvous and the monarch cpu sends the wake up ipi.  All cpus
try to call ia64_sal_mc_rendez() but only the first one makes it, the
others all block on the spinlock and eventually SAL hits them with an
INIT.

Why do I get the feeling that I am the first person to really use this
code?

With this patch and my previous patch to set SAL_MC_PARAM_RZ_ALWAYS,
kdb v4.0 gets backtrace on _ALL_ cpus when an MCA occurs.  Well, almost
all, if any of the cpus are spinning disabled then the MCA rendezvous
interrupt does not get through, SAL sends INIT and that cpu drops into
INIT processing.  kdb processing for INIT handlers is not complete yet,
work in progress.

Index: 20.5/include/asm-ia64/sal.h
--- 20.5/include/asm-ia64/sal.h Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/s/47_sal.h 1.1.3.2.3.1.1.1.1.3 644)
+++ 20.5(w)/include/asm-ia64/sal.h Sat, 22 Mar 2003 15:35:13 +1100 kaos (linux-2.4/s/47_sal.h 1.1.3.2.3.1.1.1.1.3 644)
@@ -46,6 +46,16 @@ extern spinlock_t sal_lock;
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
@@ -700,13 +710,14 @@ ia64_sal_get_state_info_size (u64 sal_in
 }
 
 /* Causes the processor to go into a spin loop within SAL where SAL awaits a wakeup
- * from the monarch processor.
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
 


