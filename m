From: Christoph Hellwig <hch@lst.de>
Date: Sun, 10 May 2020 07:54:45 +0000
Subject: [PATCH 06/31] unicore32: remove flush_cache_user_range
Message-Id: <20200510075510.987823-7-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200510075510.987823-1-hch@lst.de>
In-Reply-To: <20200510075510.987823-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>
Cc: Jessica Yu <jeyu@kernel.org>, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-fsdevel@vger.kernel.org

flush_cache_user_range is an ARMism not used by any generic or unicore32
specific code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/unicore32/include/asm/cacheflush.h | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/arch/unicore32/include/asm/cacheflush.h b/arch/unicore32/include/asm/cacheflush.h
index dc8c0b41538f8..9393ca4047e93 100644
--- a/arch/unicore32/include/asm/cacheflush.h
+++ b/arch/unicore32/include/asm/cacheflush.h
@@ -132,14 +132,6 @@ extern void flush_cache_page(struct vm_area_struct *vma,
 
 #define flush_cache_dup_mm(mm) flush_cache_mm(mm)
 
-/*
- * flush_cache_user_range is used when we want to ensure that the
- * Harvard caches are synchronised for the user space address range.
- * This is used for the UniCore private sys_cacheflush system call.
- */
-#define flush_cache_user_range(vma, start, end) \
-	__cpuc_coherent_user_range((start) & PAGE_MASK, PAGE_ALIGN(end))
-
 /*
  * Perform necessary cache operations to ensure that data previously
  * stored within this range of addresses can be executed by the CPU.
-- 
2.26.2
