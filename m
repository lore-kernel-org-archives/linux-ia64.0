From: "Jan Beulich" <jbeulich@novell.com>
Date: Wed, 12 Dec 2007 15:21:30 +0000
Subject: [PATCH] ia64: make flush_tlb_kernel_range() an inline function
Message-Id: <47600A8A.76E4.0078.0@novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This fixes an unused variable warning in mm/vmalloc.c.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

 include/asm-ia64/tlbflush.h |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

--- linux-2.6.24-rc5/include/asm-ia64/tlbflush.h	2007-12-12 12:27:38.000000000 +0100
+++ 2.6.24-rc5-ia64-flush-tlb-kernel-range/include/asm-ia64/tlbflush.h	2007-12-12 15:24:27.000000000 +0100
@@ -92,6 +92,10 @@ void smp_local_flush_tlb(void);
 #define smp_local_flush_tlb()
 #endif
 
-#define flush_tlb_kernel_range(start, end)	flush_tlb_all()	/* XXX fix me */
+static inline void flush_tlb_kernel_range(unsigned long start,
+					  unsigned long end)
+{
+	flush_tlb_all();	/* XXX fix me */
+}
 
 #endif /* _ASM_IA64_TLBFLUSH_H */



