From: Horms <horms@verge.net.au>
Date: Mon, 23 Oct 2006 08:48:41 +0000
Subject: [patch 1/5] move ia64_sal_retval and ia64_sal_handler above __SAL_CALL
Message-Id: <20061023090334.049412560@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This moves the definition of ia64_sal_retval and ia64_sal_handler above 
__SAL_CALL in preparation for a typed function, which returns
ia64_sal_retval and takes a ia64_sal_handler as one of its argument
and is called by __SAL_CALL.

Signed-Off-By: Simon Horman <horms@verge.net.au>

 include/asm-ia64/sal.h |   32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

Index: kexec-ia64-2.6/include/asm-ia64/sal.h
=================================--- kexec-ia64-2.6.orig/include/asm-ia64/sal.h	2006-10-05 12:33:37.000000000 +0900
+++ kexec-ia64-2.6/include/asm-ia64/sal.h	2006-10-05 12:33:41.000000000 +0900
@@ -45,6 +45,22 @@
 
 extern spinlock_t sal_lock;
 
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
+
 /* SAL spec _requires_ eight args for each call. */
 #define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)	\
 	result = (*ia64_sal)(a0,a1,a2,a3,a4,a5,a6,a7)
@@ -95,22 +111,6 @@
 
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

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

