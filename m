From: Hiro Fujita <fujita@kanagawa.hitachi.co.jp>
Date: Tue, 17 Oct 2000 06:13:46 +0000
Subject: [Linux-ia64] register initialization error on test9 ?
Message-Id: <marc-linux-ia64-105590678205572@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

there seems to be a register initialization error on test9 kernel.

--- linux-2.4.0-test9-ia64-001004/arch/ia64/kernel/head.S.org	Fri Oct  6 09:20:34 2000
+++ linux-2.4.0-test9-ia64-001004/arch/ia64/kernel/head.S	Mon Oct 16 20:50:07 2000
@@ -73,15 +73,13 @@
 	mov ar.fpsr=r2
 	;;
 
-#ifdef CONFIG_IA64_EARLY_PRINTK
-	mov r2=6
-	mov r3=(8<<8) | (28<<2)
+	movl r2=6<<61
+	mov r3=(6<<8) | (28<<2)
 	;;
 	mov rr[r2]=r3
 	;;
 	srlz.i
 	;;
-#endif
 
 #define isAP	p2	// are we booting an Application Processor (not the BSP)?
 
----------------
In the original code, RR[0] is initialized instead of RR[6].
I don't know whether the RID value should be 8 or 6,
but it is later re-initialized to 6 in ia64_rid_init().

And, this initialization should be done for all application 
processors (APs) even if CONFIG_IA64_EARLY_PRINTK is not defined, 
because RR[6] is used for translation when printk() is called by AP.

When AP calls printk(), writes to VGA region (0xc0000000000bxxxx) is
occured because console_drivers is already initialized by BSP.

Is this right ?
I don't know the detail of address translation.

--
Hiro Fujita
Hitachi, Ltd.

