From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 09:00:29 +0000
Subject: [patch] whitespace fix in smpboot.c
Message-Id: <200504290900.j3T90TiH001329@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[IA64] Trivial whitespace fix

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

Index: arch/ia64/kernel/smpboot.c
=================================--- a63eb89df905efd86a58940286a63c5f670b1c05/arch/ia64/kernel/smpboot.c  (mode:100644 sha1:0d5ee57c9865ce10128cdf89a05d0af48d8d7020)
+++ uncommitted/arch/ia64/kernel/smpboot.c  (mode:100644)
@@ -624,7 +624,7 @@
 	__u16   thread_id;
 	__u16   proc_fixed_addr;
 	__u8    valid;
-}mt_info[NR_CPUS] __devinit;
+} mt_info[NR_CPUS] __devinitdata;
 
 #ifdef CONFIG_HOTPLUG_CPU
 static inline void
