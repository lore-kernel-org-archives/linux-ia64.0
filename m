From: Nadav Amit <nadav.amit@gmail.com>
Date: Thu, 25 May 2023 21:00:40 +0000
Subject: [PATCH v2 3/3] lib: Allow traceing of usercopy, xarray, iov_iter, find_bit
Message-Id: <20230525210040.3637-4-namit@vmware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230525210040.3637-1-namit@vmware.com>
In-Reply-To: <20230525210040.3637-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Nadav Amit <namit@vmware.com>

From: Nadav Amit <namit@vmware.com>

There is no reason not to allow the use of ftrace for usercopy, xarray
and iov_iter.  Enable tracing for these compilation unit.

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 lib/Makefile | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/Makefile b/lib/Makefile
index 876fcdeae34e..00450e1cc97d 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -27,6 +27,9 @@ KASAN_SANITIZE_string.o := n
 CFLAGS_string.o += -fno-stack-protector
 endif
 
+CFLAGS_xarray.o += $(CC_FLAGS_FTRACE)
+CFLAGS_iov_iter.o += $(CC_FLAGS_FTRACE)
+
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o timerqueue.o xarray.o \
 	 maple_tree.o idr.o extable.o irq_regs.o argv_split.o \
@@ -42,6 +45,8 @@ lib-$(CONFIG_SMP) += cpumask.o
 lib-y	+= kobject.o klist.o
 obj-y	+= lockref.o
 
+CFLAGS_usercopy.o += $(CC_FLAGS_FTRACE)
+CFLAGS_find_bit.o += $(CC_FLAGS_FTRACE)
 obj-y += bcd.o sort.o parser.o debug_locks.o random32.o \
 	 bust_spinlocks.o kasprintf.o bitmap.o scatterlist.o \
 	 list_sort.o uuid.o iov_iter.o clz_ctz.o \
-- 
2.25.1
