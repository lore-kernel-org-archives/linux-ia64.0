From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 09 Jul 2002 21:03:13 +0000
Subject: [Linux-ia64] Security issue with Linux/IA-64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050906010000020001080202"
Message-Id: <marc-linux-ia64-105590701905749@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050906010000020001080202
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I found that running the following program as an unprivileged user on
Linux/IA-64 could hang the system.

#include <unistd.h>
#include <sys/mman.h>

int main(int argc, char **argv)
{
        munmap( (void *) 0x2000000000000000L, 0x2000000000000000L - 1); 
}

The attached patch fixes the problem. We recommend that distributions 
pick this up as soon as possible, because of the nature of the problem.

    -Arun


--------------050906010000020001080202
Content-Type: text/plain;
 name="flush7.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="flush7.txt"

===== include/asm-ia64/pgalloc.h 1.6 vs edited =====
--- 1.6/include/asm-ia64/pgalloc.h	Fri Jun 21 16:18:11 2002
+++ edited/include/asm-ia64/pgalloc.h	Tue Jul  9 13:55:27 2002
@@ -17,6 +17,7 @@
 
 #include <linux/mm.h>
 #include <linux/threads.h>
+#include <linux/compiler.h>
 
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
@@ -204,9 +205,15 @@
 static inline void
 flush_tlb_pgtables (struct mm_struct *mm, unsigned long start, unsigned long end)
 {
-	if (rgn_index(start) != rgn_index(end))
-		printk("flush_tlb_pgtables: can't flush across regions!!\n");
-	flush_tlb_range(mm, ia64_thash(start), ia64_thash(end));
+	if (unlikely(end - start >= 1024*1024*1024*1024UL
+		     || rgn_index(start) != rgn_index(end - 1)))
+		/*
+		 * This condition is very rare and normal applications shouldn't get
+		 * here. No attempt has been made to optimize for this case.
+		 */
+		flush_tlb_all();
+	else
+		flush_tlb_range(mm, ia64_thash(start), ia64_thash(end));
 }
 
 /*

--------------050906010000020001080202--


