From: Keith Owens <kaos@sgi.com>
Date: Thu, 30 Oct 2003 08:31:01 +0000
Subject: [patch 1/4] kernel salinfo changes
Message-Id: <marc-linux-ia64-106750297018132@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

patch 1 - Print the header from INIT records, correct typo in sal.h.

diff -ur 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo0/arch/ia64/kernel/mca.c 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo1/arch/ia64/kernel/mca.c
--- 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo0/arch/ia64/kernel/mca.c	Thu Oct 30 17:06:18 2003
+++ 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo1/arch/ia64/kernel/mca.c	Thu Oct 30 18:33:20 2003
@@ -2383,7 +2383,8 @@
 		ia64_log_rec_header_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
 		break;
 	      case SAL_INFO_TYPE_INIT:
-		prfunc("+MCA INIT ERROR LOG (UNIMPLEMENTED)\n");
+		prfunc("+CPU %d: SAL log contains INIT error record\n", smp_processor_id());
+		ia64_log_rec_header_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
 		break;
 	      case SAL_INFO_TYPE_CMC:
 		prfunc("+BEGIN HARDWARE ERROR STATE AT CMC\n");
diff -ur 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo0/include/asm-ia64/sal.h 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo1/include/asm-ia64/sal.h
--- 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo0/include/asm-ia64/sal.h	Thu Oct 30 17:06:20 2003
+++ 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo1/include/asm-ia64/sal.h	Thu Oct 30 18:34:11 2003
@@ -808,4 +808,4 @@
 
 #endif /* __ASSEMBLY__ */
 
-#endif /* _ASM_IA64_PAL_H */
+#endif /* _ASM_IA64_SAL_H */

