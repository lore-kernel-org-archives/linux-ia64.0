From: Hari Bathini <hbathini@linux.vnet.ibm.com>
Date: Fri, 24 Mar 2017 11:16:29 +0000
Subject: [RESEND PATCH v4 4/5] powerpc/fadump: reuse crashkernel parameter for fadump memory reservation
Message-Id: <149035346749.6881.911095631212975718.stgit@hbathini.in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <149035332237.6881.9486330442785822384.stgit@hbathini.in.ibm.com>
In-Reply-To: <149035332237.6881.9486330442785822384.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, dyoung@redhat.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, ebiederm@xmission.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com

fadump supports specifying memory to reserve for fadump's crash kernel
with fadump_reserve_mem kernel parameter. This parameter currently
supports passing a fixed memory size, like fadump_reserve_mem=<size>
only. This patch aims to add support for other syntaxes like range-based
memory size <range1>:<size1>[,<range2>:<size2>,<range3>:<size3>,...]
which allows using the same parameter to boot the kernel with different
system RAM sizes.

As crashkernel parameter already supports the above mentioned syntaxes,
this patch deprecates fadump_reserve_mem parameter and reuses crashkernel
parameter instead, to specify memory for fadump's crash kernel memory
reservation as well. If any offset is provided in crashkernel parameter,
it will be ignored in case of fadump, as fadump reserves memory at end
of RAM.

Advantages using crashkernel parameter instead of fadump_reserve_mem
parameter are one less kernel parameter overall, code reuse and support
for multiple syntaxes to specify memory.

Suggested-by: Dave Young <dyoung@redhat.com>
Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
Reviewed-by: Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>
---
 arch/powerpc/kernel/fadump.c |   23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/arch/powerpc/kernel/fadump.c b/arch/powerpc/kernel/fadump.c
index 31c0abe..e013f8f 100644
--- a/arch/powerpc/kernel/fadump.c
+++ b/arch/powerpc/kernel/fadump.c
@@ -210,14 +210,20 @@ static unsigned long init_fadump_mem_struct(struct fadump_mem_struct *fdm,
  */
 static inline unsigned long fadump_calculate_reserve_size(void)
 {
-	unsigned long size;
+	int ret;
+	unsigned long long base, size;
 
 	/*
-	 * Check if the size is specified through fadump_reserve_mem= cmdline
-	 * option. If yes, then use that.
+	 * Check if the size is specified through crashkernel= cmdline
+	 * option. If yes, then use that but ignore base as fadump
+	 * reserves memory at end of RAM.
 	 */
-	if (fw_dump.reserve_bootvar)
+	ret = parse_crashkernel(boot_command_line, memblock_phys_mem_size(),
+				&size, &base);
+	if (ret = 0 && size > 0) {
+		fw_dump.reserve_bootvar = (unsigned long)size;
 		return fw_dump.reserve_bootvar;
+	}
 
 	/* divide by 20 to get 5% of value */
 	size = memblock_end_of_DRAM() / 20;
@@ -353,15 +359,6 @@ static int __init early_fadump_param(char *p)
 }
 early_param("fadump", early_fadump_param);
 
-/* Look for fadump_reserve_mem= cmdline option */
-static int __init early_fadump_reserve_mem(char *p)
-{
-	if (p)
-		fw_dump.reserve_bootvar = memparse(p, &p);
-	return 0;
-}
-early_param("fadump_reserve_mem", early_fadump_reserve_mem);
-
 static void register_fw_dump(struct fadump_mem_struct *fdm)
 {
 	int rc;

