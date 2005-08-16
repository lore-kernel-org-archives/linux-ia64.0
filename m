From: Andi Kleen <ak@suse.de>
Date: Tue, 16 Aug 2005 15:57:47 +0000
Subject: [PATCH] Fix gcc 4 warnings on ia64
Message-Id: <20050816155747.GN20749@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I was compiling an IA64 2.6.13rc6 kernel on a machine with gcc 4 
to test something. The compile spew a incredibly large number
of warnings. This patch fixes the most annoying ones from
commonly included makefiles. In these two cases  gcc was complaining
that functions cannot be volatile or const.

There are a lot more warnings left, but they're in individual files.
Most seem to be uninitialized variables because gcc 4 can track
individual structure members for that now. 

Signed-off-by: Andi Kleen <ak@suse.de>

diff -u linux-2.6.13rc6/include/asm-ia64/mmu.h-o linux-2.6.13rc6/include/asm-ia64/mmu.h
diff -u linux-2.6.13rc6/include/asm-ia64/io.h-o linux-2.6.13rc6/include/asm-ia64/io.h
--- linux-2.6.13rc6/include/asm-ia64/io.h-o	2005-06-17 21:48:29.000000000 +0200
+++ linux-2.6.13rc6/include/asm-ia64/io.h	2005-08-16 17:37:56.539836121 +0200
@@ -120,7 +120,7 @@
 	ia64_mfa();
 }
 
-static inline const unsigned long
+static inline unsigned long
 __ia64_get_io_port_base (void)
 {
 	extern unsigned long ia64_iobase;
diff -u linux-2.6.13rc6/include/asm-ia64/mmu_context.h-o linux-2.6.13rc6/include/asm-ia64/mmu_context.h
--- linux-2.6.13rc6/include/asm-ia64/mmu_context.h-o	2005-08-16 17:33:16.000000000 +0200
+++ linux-2.6.13rc6/include/asm-ia64/mmu_context.h	2005-08-16 17:45:14.310318038 +0200
@@ -62,7 +62,7 @@
 	}
 }
 
-static inline mm_context_t
+static inline unsigned long
 get_mmu_context (struct mm_struct *mm)
 {
 	unsigned long flags;




