From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 18 Dec 2003 20:30:22 +0000
Subject: [PATCH] Prevent SAL calls from being preempted
Message-Id: <marc-linux-ia64-107177977525156@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Prevent SAL calls from being preempted.

(SAL_CALL_REENTRANT): Disable preemption around the SAL call to
	make sure we don't get rescheduled on a different CPU.

=== include/asm-ia64/sal.h 1.19 vs edited ==--- 1.19/include/asm-ia64/sal.h	Sat Aug 16 18:31:13 2003
+++ edited/include/asm-ia64/sal.h	Wed Dec 10 14:10:04 2003
@@ -71,7 +71,9 @@
 # define SAL_CALL_REENTRANT(result,args...) do {	\
 	struct ia64_fpreg __ia64_scs_fr[6];		\
 	ia64_save_scratch_fpregs(__ia64_scs_fr);	\
+	preempt_disable();				\
 	__SAL_CALL(result, args);			\
+	preempt_enable();				\
 	ia64_load_scratch_fpregs(__ia64_scs_fr);	\
 } while (0)
 

