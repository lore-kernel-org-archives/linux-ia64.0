From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 17 Oct 2007 20:20:18 +0000
Subject: Re: [PATCH 0/3] vmcoreinfo support for dump filtering
Message-Id: <20071017132018.218043bb.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822210838oomichi@mail.jp.nec.com>
	<12c511ca0710171019t35cb1670k9e1bdcfb3bf99793@mail.gmail.com>
In-Reply-To: <12c511ca0710171019t35cb1670k9e1bdcfb3bf99793@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: oomichi@mxs.nes.nec.co.jp, linux-kernel@vger.kernel.org, kexec@lists.infradead.org, nhorman@redhat.com, vgoyal@in.ibm.com, bwalle@suse.de, dzickus@redhat.com, da-x@monatomic.org, linux-ia64@vger.kernel.org

On Wed, 17 Oct 2007 10:19:18 -0700
"Tony Luck" <tony.luck@intel.com> wrote:

> > This patch set frees the restriction that makedumpfile users should
> > install a vmlinux file (including the debugging information) into
> > each system.
> 
> This patch went from Andrew to Linus last night, and looks at first
> glance to be the reason why the ia64 build is broken this morning
> when using the arch/ia64/configs/tiger_defconfig configuration.
> 
> Here are the error messages:
> arch/ia64/kernel/machine_kexec.c: In function `arch_crash_save_vmcoreinfo':
> arch/ia64/kernel/machine_kexec.c:131: error: `pgdat_list' undeclared
> (first use in this function)
> arch/ia64/kernel/machine_kexec.c:131: error: (Each undeclared
> identifier is reported only once
> arch/ia64/kernel/machine_kexec.c:131: error: for each function it appears in.)
> arch/ia64/kernel/machine_kexec.c:134: error: `node_memblk' undeclared
> (first use in this function)
> arch/ia64/kernel/machine_kexec.c:135: error: `NR_NODE_MEMBLKS'
> undeclared (first use in this function)
> arch/ia64/kernel/machine_kexec.c:136: error: invalid application of
> `sizeof' to incomplete type `node_memblk_s'
> arch/ia64/kernel/machine_kexec.c:137: error: dereferencing pointer to
> incomplete type
> arch/ia64/kernel/machine_kexec.c:138: error: dereferencing pointer to
> incomplete type
> make[1]: *** [arch/ia64/kernel/machine_kexec.o] Error 1
> 

This?


--- a/arch/ia64/kernel/machine_kexec.c~ia64-fix-non-numa-build
+++ a/arch/ia64/kernel/machine_kexec.c
@@ -17,6 +17,8 @@
 #include <linux/efi.h>
 #include <linux/numa.h>
 #include <linux/mmzone.h>
+
+#include <asm/numa.h>
 #include <asm/mmu_context.h>
 #include <asm/setup.h>
 #include <asm/delay.h>
@@ -127,7 +129,7 @@ void machine_kexec(struct kimage *image)
 
 void arch_crash_save_vmcoreinfo(void)
 {
-#ifdef CONFIG_ARCH_DISCONTIGMEM_ENABLE
+#if defined(CONFIG_ARCH_DISCONTIGMEM_ENABLE) && defined(CONFIG_NUMA)
 	VMCOREINFO_SYMBOL(pgdat_list);
 	VMCOREINFO_LENGTH(pgdat_list, MAX_NUMNODES);
 
_

(the asm/numa.h include isn't needed by this patch, but strictly should be
there, as this file refers to things which are defined in asm/numa.h)

(it's weird that linux/numa.h doesn't include asm/numa.h)

(please tell me if you want me to send this to Linus)
