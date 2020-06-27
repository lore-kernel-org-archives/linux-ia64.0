From: Mike Rapoport <rppt@kernel.org>
Date: Sat, 27 Jun 2020 14:34:52 +0000
Subject: [PATCH 7/8] mm: move lib/ioremap.c to mm/
Message-Id: <20200627143453.31835-8-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200627143453.31835-1-rppt@kernel.org>
In-Reply-To: <20200627143453.31835-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christophe Leroy <christophe.leroy@csgroup.eu>, Joerg Roedel <joro@8bytes.org>, Max Filippov <jcmvbkbc@gmail.com>, Mike Rapoport <rppt@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Satheesh Rajendran <sathnaga@linux.vnet.ibm.com>, Stafford Horne <shorne@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.orglinux

From: Mike Rapoport <rppt@linux.ibm.com>

The functionality in lib/ioremap.c deals with pagetables, vmalloc and
caches, so it naturally belongs to mm/
Moving it there will also allow declaring p?d_alloc_track functions in an
header file inside mm/ rather than having those declarations in
include/linux/mm.h

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 lib/Makefile          | 1 -
 mm/Makefile           | 2 +-
 {lib => mm}/ioremap.c | 0
 3 files changed, 1 insertion(+), 2 deletions(-)
 rename {lib => mm}/ioremap.c (100%)

diff --git a/lib/Makefile b/lib/Makefile
index b1c42c10073b..5f9384adde9c 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -37,7 +37,6 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 nmi_backtrace.o nodemask.o win_minmax.o memcat_p.o
 
 lib-$(CONFIG_PRINTK) += dump_stack.o
-lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
 
 lib-y	+= kobject.o klist.o
diff --git a/mm/Makefile b/mm/Makefile
index 6e9d46b2efc9..d5649f1c12c0 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -38,7 +38,7 @@ mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= highmem.o memory.o mincore.o \
 			   mlock.o mmap.o mmu_gather.o mprotect.o mremap.o \
 			   msync.o page_vma_mapped.o pagewalk.o \
-			   pgtable-generic.o rmap.o vmalloc.o
+			   pgtable-generic.o rmap.o vmalloc.o ioremap.o
 
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
diff --git a/lib/ioremap.c b/mm/ioremap.c
similarity index 100%
rename from lib/ioremap.c
rename to mm/ioremap.c
-- 
2.26.2
