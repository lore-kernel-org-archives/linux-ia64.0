From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 11 Mar 2003 19:01:54 +0000
Subject: [Linux-ia64] bogus __clear_bit macro
Message-Id: <marc-linux-ia64-105590709806025@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

It looks like when __clear_bit() was implemented, the deletion of the macro falls through the crack.  This macro prohibit the actual __clear_bit to be invoked.

--- include/asm-ia64/bitops.h-	Tue Mar  4 19:29:35 2003
+++ include/asm-ia64/bitops.h	Tue Mar 11 10:49:36 2003
@@ -450,8 +450,6 @@
 
 #ifdef __KERNEL__
 
-#define __clear_bit(nr, addr)        clear_bit(nr, addr)
-
 #define ext2_set_bit                 test_and_set_bit
 #define ext2_clear_bit               test_and_clear_bit
 #define ext2_test_bit                test_bit

