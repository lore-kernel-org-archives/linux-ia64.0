From: Jack Steiner <steiner@sgi.com>
Date: Fri, 11 Mar 2005 21:16:37 +0000
Subject: [PATCH] - Change SAL call request code for SN systems
Message-Id: <20050311211637.GA28715@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony - please apply to 2.6.12-test ASAP.


Change the value of the SAL call number for a new SAL request. The
initial implementation in the PROM did not match what the OS expected. 
Since the OS can run on PROMs that do not implement the new call, 
changing the call number avoids the issue. New PROMs will implement
the new call number. (This avoids problems with the 4.05 PROM).


Signed-off-by: Jack Steiner <steiner@sgi.com>




Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-03-11 11:30:21.694324178 -0600
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-03-11 14:50:32.991091767 -0600
@@ -35,8 +35,8 @@
 #define  SN_SAL_PRINT_ERROR			   0x02000012
 #define  SN_SAL_SET_ERROR_HANDLING_FEATURES	   0x0200001a	// reentrant
 #define  SN_SAL_GET_FIT_COMPT			   0x0200001b	// reentrant
-#define  SN_SAL_GET_SN_INFO                        0x0200001c
 #define  SN_SAL_GET_SAPIC_INFO                     0x0200001d
+#define  SN_SAL_GET_SN_INFO                        0x0200001e
 #define  SN_SAL_CONSOLE_PUTC                       0x02000021
 #define  SN_SAL_CONSOLE_GETC                       0x02000022
 #define  SN_SAL_CONSOLE_PUTS                       0x02000023
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


