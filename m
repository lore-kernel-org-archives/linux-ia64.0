From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 09 Sep 2003 03:48:23 +0000
Subject: unwind.c fix for spinlock-debug compilation
Message-Id: <marc-linux-ia64-106307953919670@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


If you try to compile 2.6.0-test[45] with spinlock debugging on, then
unwind.c won't compile, because it uses a #define magic that hides
the variable in the spinlock debugging code (also called magic)

Suggested patch appended.

=== arch/ia64/kernel/unwind.c 1.32 vs edited ==--- 1.32/arch/ia64/kernel/unwind.c	Sat Jul 26 11:42:20 2003
+++ edited/arch/ia64/kernel/unwind.c	Tue Sep  9 13:38:35 2003
@@ -1171,9 +1171,10 @@
 static inline unw_hash_index_t
 hash (unsigned long ip)
 {
-#	define magic	0x9e3779b97f4a7c16	/* based on (sqrt(5)/2-1)*2^64 */
+#	define hashmagic	0x9e3779b97f4a7c16	/* based on (sqrt(5)/2-1)*2^64 */
 
-	return (ip >> 4)*magic >> (64 - UNW_LOG_HASH_SIZE);
+	return (ip >> 4)*hashmagic >> (64 - UNW_LOG_HASH_SIZE);
+#undef hashmagic
 }
 
 static inline long

