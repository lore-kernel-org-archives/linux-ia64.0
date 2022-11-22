From: Nadav Amit <nadav.amit@gmail.com>
Date: Tue, 22 Nov 2022 19:53:28 +0000
Subject: [PATCH 2/3] lib/usercopy: Allow traceing of usercopy, xarray, iov_iter
Message-Id: <20221122195329.252654-3-namit@vmware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221122195329.252654-1-namit@vmware.com>
In-Reply-To: <20221122195329.252654-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Nadav Amit <namit@vmware.com>

From: Nadav Amit <namit@vmware.com>

There is no reason not to allow the use of ftrace for usercopy, xarray
and iov_iter.  Enable tracing for these compilation unit.

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 lib/Makefile | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/Makefile b/lib/Makefile
index 59bd7c2f793a..32766aa26670 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -27,6 +27,8 @@ KASAN_SANITIZE_string.o := n
 CFLAGS_string.o += -fno-stack-protector
 endif
 
+CFLAGS_xarray.o += $(CC_FLAGS_FTRACE)
+CFLAGS_iov_iter.o += $(CC_FLAGS_FTRACE)
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o timerqueue.o xarray.o \
 	 maple_tree.o idr.o extable.o irq_regs.o argv_split.o \
@@ -42,6 +44,7 @@ lib-$(CONFIG_SMP) += cpumask.o
 lib-y	+= kobject.o klist.o
 obj-y	+= lockref.o
 
+CFLAGS_usercopy.o += $(CC_FLAGS_FTRACE)
 obj-y += bcd.o sort.o parser.o debug_locks.o random32.o \
 	 bust_spinlocks.o kasprintf.o bitmap.o scatterlist.o \
 	 list_sort.o uuid.o iov_iter.o clz_ctz.o \
-- 
2.25.1
