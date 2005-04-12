From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 12 Apr 2005 18:03:43 +0000
Subject: [IA64] fix "section mismatch" compile-time-error
Message-Id: <200504121803.j3CI3hZY011772@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I noticed this typo when trying to compile a kernel which had
CONFIG_HOTPLUG turned off.  In that case, __devinit is no longer a
no-op and the compiler then detects a section-conflict.  Fix by using
__devinitdata instead of __devinit.

Please apply into the *test* repository.

Thanks,

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/smpboot.c 1.69 vs edited ==--- 1.69/arch/ia64/kernel/smpboot.c	2005-03-21 10:35:10 -08:00
+++ edited/arch/ia64/kernel/smpboot.c	2005-04-12 10:55:06 -07:00
@@ -624,7 +624,7 @@
 	__u16   thread_id;
 	__u16   proc_fixed_addr;
 	__u8    valid;
-}mt_info[NR_CPUS] __devinit;
+} mt_info[NR_CPUS] __devinitdata;
 
 #ifdef CONFIG_HOTPLUG_CPU
 static inline void
