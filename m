From: Andrew Morton <akpm@osdl.org>
Date: Tue, 25 May 2004 05:26:12 +0000
Subject: Re: [PATCH]  Reduce TLB flushing during process migration
Message-Id: <20040524222612.66d54222.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040522121159.GB19454@sgi.com>
In-Reply-To: <20040522121159.GB19454@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner <steiner@sgi.com> wrote:
>
> Here is an updated patch for flushing the TLB on SN2 after a process
>  migration. The patch is based on the latest "//linux.bkbits.net/linux-2.5"
>  bitkeeper tree.

Instant oops on ia32 because p->mm is NULL for kernel threads.  You might
want to check that on ia64 too - it's not clear to me why it works there.

--- 25/include/asm-generic/tlb.h~reduce-tlb-flushing-during-process-migration-oops-fix	2004-05-24 22:20:30.018626600 -0700
+++ 25-akpm/include/asm-generic/tlb.h	2004-05-24 22:21:12.621150032 -0700
@@ -147,6 +147,10 @@ static inline void tlb_remove_page(struc
 		__pmd_free_tlb(tlb, pmdp);			\
 	} while (0)
 
-#define tlb_migrate_finish(mm) flush_tlb_mm(mm)
+#define tlb_migrate_finish(mm)					\
+	do {							\
+		if (likely(mm))					\
+			flush_tlb_mm(mm);			\
+	} while (0)
 
 #endif /* _ASM_GENERIC__TLB_H */


But I don't understand why your patch adds two flush_tlb_mm() calls into
sched.c on ia32 where there previously was no such call.
