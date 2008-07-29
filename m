From: Simon Horman <horms@verge.net.au>
Date: Tue, 29 Jul 2008 23:16:04 +0000
Subject: Re: [patch 2/3] kdump: add is_vmcore_usable() and vmcore_unusable()
Message-Id: <20080729231602.GG6370@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729081235.293361145@vergenet.net> <20080729081629.522008269@vergenet.net>
In-Reply-To: <20080729081629.522008269@vergenet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kexec@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Vivek Goyal <vgoyal@redhat.com>

The usage of elfcorehdr_addr has changed recently
such that being set to ELFCORE_ADDR_MAX is used by
is_kdump_kernel() to indicate if the code is executing
in a kernel executed as a crash kernel.

However, arch/ia64/kernel/setup.c:reserve_elfcorehdr will
rest elfcorehdr_addr to ELFCORE_ADDR_MAX on error,
which means any subsequent calls to is_kdump_kernel()
will return 0, even though they should return 1.

Ok, at this point in time there are no subsequent calls,
but I think its fair to say that there is ample scope for error
or at the very least confusion.

This patch add an extra state, ELFCORE_ADDR_ERR, which
indicates that elfcorehdr_addr was passed on the command line,
and thus execution is taking place in a crashdump kernel,
but vmcore can't be used for some reason. This is tested
for using is_vmcore_usable() and set using vmcore_unusable().
A subsequent patch makes use of this new code.

To summarise, the states that elfcorehdr_addr can now be in are as follows:

ELFCORE_ADDR_MAX: not a crashdump kernel
ELFCORE_ADDR_ERR: crashdump kernel but vmcore is unusable
any other value:  crash dump kernel and vmcore is usable

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

 fs/proc/vmcore.c           |    2 +-
 include/linux/crash_dump.h |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 1 deletion(-)

Wed, 30 Jul 2008 09:10:37 +1000
* Fixed logic bug in vmcore_unusable().
  if (!is_kdump_kernel()) is correct
  if (is_kdump_kernel()) is not

Index: linux-2.6/include/linux/crash_dump.h
=================================--- linux-2.6.orig/include/linux/crash_dump.h	2008-07-30 09:05:50.000000000 +1000
+++ linux-2.6/include/linux/crash_dump.h	2008-07-30 09:08:58.000000000 +1000
@@ -8,6 +8,7 @@
 #include <linux/proc_fs.h>
 
 #define ELFCORE_ADDR_MAX	(-1ULL)
+#define ELFCORE_ADDR_ERR	(-2ULL)
 
 extern unsigned long long elfcorehdr_addr;
 
@@ -42,5 +43,30 @@ static inline int is_kdump_kernel(void)
 static inline int is_kdump_kernel(void) { return 0; }
 #endif /* CONFIG_CRASH_DUMP */
 
+#ifdef CONFIG_PROC_VMCORE
+/* is_vmcore_usable() checks if the kernel is booting after a panic and
+ * the vmcore region is usable.
+ *
+ * This makes use of the fact that due to alignment 1 is not
+ * a valid pointer, much in the vain of IS_ERR(), except
+ * dealing directly with an unsigned long long rather than a pointer.
+ */
+
+static inline int is_vmcore_usable(void)
+{
+	return is_kdump_kernel() && elfcorehdr_addr != ELFCORE_ADDR_ERR ? 1 : 0;
+}
+
+/* vmcore_unusable() marks the vmcore as unusable,
+ * without disturbing the logic of is_kdump_kernel()
+ */
+
+static inline void vmcore_unusable(void)
+{
+	if (is_kdump_kernel())
+		elfcorehdr_addr = ELFCORE_ADDR_ERR;
+}
+#endif /* CONFIG_PROC_VMCORE */
+
 extern unsigned long saved_max_pfn;
 #endif /* LINUX_CRASHDUMP_H */
Index: linux-2.6/fs/proc/vmcore.c
=================================--- linux-2.6.orig/fs/proc/vmcore.c	2008-07-30 09:05:50.000000000 +1000
+++ linux-2.6/fs/proc/vmcore.c	2008-07-30 09:07:07.000000000 +1000
@@ -650,7 +650,7 @@ static int __init vmcore_init(void)
 	int rc = 0;
 
 	/* If elfcorehdr= has been passed in cmdline, then capture the dump.*/
-	if (!(elfcorehdr_addr < ELFCORE_ADDR_MAX))
+	if (!(is_vmcore_usable()))
 		return rc;
 	rc = parse_crash_elf_headers();
 	if (rc) {
