From: Keith Owens <kaos@sgi.com>
Date: Sat, 22 Mar 2003 03:57:58 +0000
Subject: [Linux-ia64] [patch] 2.4.20-ia64 mca rendezvous
Message-Id: <marc-linux-ia64-105590723705288@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We are not setting the 'always rendezvous for mca' flag.  kdb needs it
set to get decent mca debugging on all cpus but I do not want kdb to
change sal behaviour.  Since we do not recover from mca without a
debugger, I see no reason why this flag should not be on for all
kernels.

The rendezvous timeout was set to 100 * HZ, but SAL expects the timeout
to be in milliseconds, HZ may not be 1 millisecond.  The patch makes
the timeout an explicit 20 seconds, semi-arbitrary value.

Index: 20.5/arch/ia64/kernel/mca.c
--- 20.5/arch/ia64/kernel/mca.c Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
+++ 20.5(w)/arch/ia64/kernel/mca.c Sat, 22 Mar 2003 14:51:16 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
@@ -432,7 +432,7 @@ ia64_mca_init(void)
 					 SAL_MC_PARAM_MECHANISM_INT,
 					 IA64_MCA_RENDEZ_VECTOR,
 					 IA64_MCA_RENDEZ_TIMEOUT,
-					 0)))
+					 SAL_MC_PARAM_RZ_ALWAYS)))
 	{
 		printk("ia64_mca_init: Failed to register rendezvous interrupt "
 		       "with SAL.  rc = %ld\n", rc);
Index: 20.5/include/asm-ia64/mca.h
--- 20.5/include/asm-ia64/mca.h Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/t/19_mca.h 1.1.3.1.1.1.1.2 644)
+++ 20.5(w)/include/asm-ia64/mca.h Sat, 22 Mar 2003 14:51:16 +1100 kaos (linux-2.4/t/19_mca.h 1.1.3.1.1.1.1.2 644)
@@ -24,7 +24,7 @@ enum {
 	IA64_MCA_FAILURE	=	1
 };
 
-#define IA64_MCA_RENDEZ_TIMEOUT		(100 * HZ)	/* 1000 milliseconds */
+#define IA64_MCA_RENDEZ_TIMEOUT		(20 * 1000)	/* value in milliseconds - 20 seconds */
 
 #define IA64_CMC_INT_DISABLE		0
 #define IA64_CMC_INT_ENABLE		1


