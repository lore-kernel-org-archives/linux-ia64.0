From: Vivek Goyal <vgoyal@redhat.com>
Date: Mon, 28 Jul 2008 21:10:25 +0000
Subject: [PATCH 1/5] Move elfcorehdr_addr out of vmcore.c (Was: Re: [patch]
Message-Id: <20080728211025.GA9985@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080727234529.GM6175@verge.net.au> <20080728015117.GA12055@verge.net.au> <20080728024526.GB3334@verge.net.au> <20080728034007.GA30450@verge.net.au>
In-Reply-To: <20080728034007.GA30450@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Muli Ben-Yehuda <muli@il.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Chandru <chandru@in.ibm.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Terry Loftin <terry.loftin@hp.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org

Hi All,

How does following series of patches look like. I have moved
elfcorehdr_addr out of vmcore.c and pushed it to arch dependent section 
of crash dump to make sure that it can be worked with even when
CONFIG_PROC_VMCORE is disabled and CONFIG_CRASH_DUMP is enabled.

I tested it on x86_64. Compile tested it on i386 and ppc64. ia64 and
sh versions are completely untested.

Thanks
Vivek




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

Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
---

 fs/proc/vmcore.c           |    3 ---
 include/linux/crash_dump.h |   14 ++++++++++----
 2 files changed, 10 insertions(+), 7 deletions(-)

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
_
