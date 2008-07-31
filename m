From: Simon Horman <horms@verge.net.au>
Date: Thu, 31 Jul 2008 01:22:09 +0000
Subject: [patch 1/6] kdump: Make elfcorehdr_addr independent of CONFIG_PROC_VMCORE
Message-Id: <20080731012927.076924783@vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080731012208.115225969@vergenet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-sh@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Terry Loftin <terry.loftin@hp.com>, Paul Mundt <lethal@linux-sh.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Vivek Goyal <vgoyal@redhat.com>

From: Vivek Goyal <vgoyal@redhat.com>

o elfcorehdr_addr is used by not only the code under CONFIG_PROC_VMCORE but
  also by the code which is not inside CONFIG_PROC_VMCORE. For example,
  is_kdump_kernel() is used by powerpc code to determine if kernel is booting
  after a panic then use previous kernel's TCE table. So even if
  CONFIG_PROC_VMCORE is not set in second kernel, one should be able to
  correctly determine that we are booting after a panic and setup calgary
  iommu accordingly.

o So remove the assumption that elfcorehdr_addr is under CONFIG_PROC_VMCORE.

o Move definition of elfcorehdr_addr to arch dependent crash files.
  (Unfortunately crash dump does not have an arch independent file otherwise
   that would have been the best place).

o kexec.c is not the right place as one can Have CRASH_DUMP enabled in
  second kernel without KEXEC being enabled.

o I don't see sh setup code parsing the command line for elfcorehdr_addr. I 
  am wondering how does vmcore interface work on sh. Anyway, I am atleast
  defining elfcoredhr_addr so that compilation is not broken on sh.

Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Simon Horman <horms@verge.net.au>
Acked-by: Paul Mundt <lethal@linux-sh.org>
---

 arch/ia64/kernel/crash_dump.c    |    4 ++++
 arch/ia64/kernel/setup.c         |    9 ++++++++-
 arch/powerpc/kernel/crash_dump.c |   10 ++++++++--
 arch/sh/kernel/crash_dump.c      |    3 +++
 arch/x86/kernel/crash_dump_32.c  |    3 +++
 arch/x86/kernel/crash_dump_64.c  |    3 +++
 arch/x86/kernel/setup.c          |    8 +++++++-
 fs/proc/vmcore.c                 |    3 ---
 include/linux/crash_dump.h       |   14 ++++++++++----
 9 files changed, 46 insertions(+), 11 deletions(-)

Andrew, this patch is a clean-up and is not required by other patches,
so it could wait until post 2.6.27 if you prefer. However, it is a
valuable cleanup that removes messiness and should remove some of
the confusion around elfcorehdr_addr and is_kdump_kernel(). So I
would prefer it to be included in 2.6.27.

sh setup code has been added in a separate patch that will
be merged by Paul Mundt.

- Simon Horman

diff -puN include/linux/crash_dump.h~remove-elfcore-hdr-addr-definition-vmcore include/linux/crash_dump.h
--- linux-2.6.27-pre-rc1/include/linux/crash_dump.h~remove-elfcore-hdr-addr-definition-vmcore	2008-07-28 12:00:44.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/include/linux/crash_dump.h	2008-07-28 12:00:56.000000000 -0400
@@ -9,11 +9,7 @@
 
 #define ELFCORE_ADDR_MAX	(-1ULL)
 
-#ifdef CONFIG_PROC_VMCORE
 extern unsigned long long elfcorehdr_addr;
-#else
-static const unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
-#endif
 
 extern ssize_t copy_oldmem_page(unsigned long, char *, size_t,
 						unsigned long, int);
@@ -28,6 +24,16 @@ extern struct proc_dir_entry *proc_vmcor
 
 #define vmcore_elf_check_arch(x) (elf_check_arch(x) || vmcore_elf_check_arch_cross(x))
 
+/*
+ * is_kdump_kernel() checks whether this kernel is booting after a panic of
+ * previous kernel or not. This is determined by checking if previous kernel
+ * has passed the elf core header address on command line.
+ *
+ * This is not just a test if CONFIG_CRASH_DUMP is enabled or not. It will
+ * return 1 if CONFIG_CRASH_DUMP=y and if kernel is booting after a panic of
+ * previous kernel.
+ */
+
 static inline int is_kdump_kernel(void)
 {
 	return (elfcorehdr_addr != ELFCORE_ADDR_MAX) ? 1 : 0;
diff -puN fs/proc/vmcore.c~remove-elfcore-hdr-addr-definition-vmcore fs/proc/vmcore.c
--- linux-2.6.27-pre-rc1/fs/proc/vmcore.c~remove-elfcore-hdr-addr-definition-vmcore	2008-07-28 09:19:50.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/fs/proc/vmcore.c	2008-07-28 09:20:10.000000000 -0400
@@ -32,9 +32,6 @@ static size_t elfcorebuf_sz;
 /* Total size of vmcore file. */
 static u64 vmcore_size;
 
-/* Stores the physical address of elf header of crash image. */
-unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
-
 struct proc_dir_entry *proc_vmcore = NULL;
 
 /* Reads a page from the oldmem device from given offset. */
diff -puN arch/x86/kernel/crash_dump_32.c~remove-elfcore-hdr-addr-definition-vmcore arch/x86/kernel/crash_dump_32.c
--- linux-2.6.27-pre-rc1/arch/x86/kernel/crash_dump_32.c~remove-elfcore-hdr-addr-definition-vmcore	2008-07-29 05:28:26.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/arch/x86/kernel/crash_dump_32.c	2008-07-29 05:28:26.000000000 -0400
@@ -13,6 +13,9 @@
 
 static void *kdump_buf_page;
 
+/* Stores the physical address of elf header of crash image. */
+unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
+
 /**
  * copy_oldmem_page - copy one page from "oldmem"
  * @pfn: page frame number to be copied
diff -puN arch/x86/kernel/crash_dump_64.c~remove-elfcore-hdr-addr-definition-vmcore arch/x86/kernel/crash_dump_64.c
--- linux-2.6.27-pre-rc1/arch/x86/kernel/crash_dump_64.c~remove-elfcore-hdr-addr-definition-vmcore	2008-07-29 05:28:26.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/arch/x86/kernel/crash_dump_64.c	2008-07-29 05:28:26.000000000 -0400
@@ -11,6 +11,9 @@
 #include <asm/uaccess.h>
 #include <asm/io.h>
 
+/* Stores the physical address of elf header of crash image. */
+unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
+
 /**
  * copy_oldmem_page - copy one page from "oldmem"
  * @pfn: page frame number to be copied
diff -puN arch/x86/kernel/setup.c~remove-elfcore-hdr-addr-definition-vmcore arch/x86/kernel/setup.c
--- linux-2.6.27-pre-rc1/arch/x86/kernel/setup.c~remove-elfcore-hdr-addr-definition-vmcore	2008-07-29 05:28:26.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/arch/x86/kernel/setup.c	2008-07-29 05:28:26.000000000 -0400
@@ -558,7 +558,13 @@ static void __init reserve_standard_io_r
 
 }
 
-#ifdef CONFIG_PROC_VMCORE
+/*
+ * Note: elfcorehdr_addr is not just limited to vmcore. It is also used by
+ * is_kdump_kernel() to determine if we are booting after a panic. Hence
+ * ifdef it under CONFIG_CRASH_DUMP and not CONFIG_PROC_VMCORE.
+ */
+
+#ifdef CONFIG_CRASH_DUMP
 /* elfcorehdr= specifies the location of elf core header
  * stored by the crashed kernel. This option will be passed
  * by kexec loader to the capture kernel.
diff -puN arch/powerpc/kernel/crash_dump.c~remove-elfcore-hdr-addr-definition-vmcore arch/powerpc/kernel/crash_dump.c
--- linux-2.6.27-pre-rc1/arch/powerpc/kernel/crash_dump.c~remove-elfcore-hdr-addr-definition-vmcore	2008-07-29 05:30:33.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/arch/powerpc/kernel/crash_dump.c	2008-07-29 05:30:33.000000000 -0400
@@ -27,6 +27,9 @@
 #define DBG(fmt...)
 #endif
 
+/* Stores the physical address of elf header of crash image. */
+unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
+
 void __init reserve_kdump_trampoline(void)
 {
 	lmb_reserve(0, KDUMP_RESERVE_LIMIT);
@@ -66,7 +69,11 @@ void __init setup_kdump_trampoline(void)
 	DBG(" <- setup_kdump_trampoline()\n");
 }
 
-#ifdef CONFIG_PROC_VMCORE
+/*
+ * Note: elfcorehdr_addr is not just limited to vmcore. It is also used by
+ * is_kdump_kernel() to determine if we are booting after a panic. Hence
+ * ifdef it under CONFIG_CRASH_DUMP and not CONFIG_PROC_VMCORE.
+ */
 static int __init parse_elfcorehdr(char *p)
 {
 	if (p)
@@ -75,7 +82,6 @@ static int __init parse_elfcorehdr(char 
 	return 1;
 }
 __setup("elfcorehdr=", parse_elfcorehdr);
-#endif
 
 static int __init parse_savemaxmem(char *p)
 {
diff -puN arch/ia64/kernel/setup.c~remove-elfcore-hdr-addr-definition-vmcore arch/ia64/kernel/setup.c
--- linux-2.6.27-pre-rc1/arch/ia64/kernel/setup.c~remove-elfcore-hdr-addr-definition-vmcore	2008-07-29 05:30:54.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/arch/ia64/kernel/setup.c	2008-07-29 05:30:54.000000000 -0400
@@ -478,7 +478,12 @@ static __init int setup_nomca(char *s)
 }
 early_param("nomca", setup_nomca);
 
-#ifdef CONFIG_PROC_VMCORE
+/*
+ * Note: elfcorehdr_addr is not just limited to vmcore. It is also used by
+ * is_kdump_kernel() to determine if we are booting after a panic. Hence
+ * ifdef it under CONFIG_CRASH_DUMP and not CONFIG_PROC_VMCORE.
+ */
+#ifdef CONFIG_CRASH_DUMP
 /* elfcorehdr= specifies the location of elf core header
  * stored by the crashed kernel.
  */
@@ -491,7 +496,9 @@ static int __init parse_elfcorehdr(char 
 	return 0;
 }
 early_param("elfcorehdr", parse_elfcorehdr);
+#endif
 
+#ifdef CONFIG_PROC_VMCORE
 int __init reserve_elfcorehdr(unsigned long *start, unsigned long *end)
 {
 	unsigned long length;
diff -puN arch/ia64/kernel/crash_dump.c~remove-elfcore-hdr-addr-definition-vmcore arch/ia64/kernel/crash_dump.c
--- linux-2.6.27-pre-rc1/arch/ia64/kernel/crash_dump.c~remove-elfcore-hdr-addr-definition-vmcore	2008-07-29 05:37:10.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/arch/ia64/kernel/crash_dump.c	2008-07-29 05:37:58.000000000 -0400
@@ -8,10 +8,14 @@
 
 #include <linux/errno.h>
 #include <linux/types.h>
+#include <linux/crash_dump.h>
 
 #include <asm/page.h>
 #include <asm/uaccess.h>
 
+/* Stores the physical address of elf header of crash image. */
+unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
+
 /**
  * copy_oldmem_page - copy one page from "oldmem"
  * @pfn: page frame number to be copied
diff -puN arch/sh/kernel/crash_dump.c~remove-elfcore-hdr-addr-definition-vmcore arch/sh/kernel/crash_dump.c
--- linux-2.6.27-pre-rc1/arch/sh/kernel/crash_dump.c~remove-elfcore-hdr-addr-definition-vmcore	2008-07-29 05:31:04.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/arch/sh/kernel/crash_dump.c	2008-07-29 05:31:04.000000000 -0400
@@ -10,6 +10,9 @@
 #include <linux/io.h>
 #include <asm/uaccess.h>
 
+/* Stores the physical address of elf header of crash image. */
+unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
+
 /**
  * copy_oldmem_page - copy one page from "oldmem"
  * @pfn: page frame number to be copied
_

-- 

-- 
Horms

