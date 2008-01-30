From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 30 Jan 2008 19:05:27 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <20080130190527.GA3681@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org> <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be> <47A09F8A.3000309@sgi.com> <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <20080130184920.GA32212@elte.hu>
In-Reply-To: <20080130184920.GA32212@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Mike Travis <travis@sgi.com>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> > Uni-processor build still fails with this patch (config is 
> > arch/ia64/configs/tiger_defconfig with CONFIG_SMP switched from =y 
> > to =n).
> 
> could you try the full patchset that Travis has just sent and which 
> i've put into x86.git, you can pull it from:

btw., i needed the fix below to get DISCONTIGMEM + !NUMA to build. (this 
is an ia64 build breakage independent of the x86.git merge)

	Ingo

-------------->
Subject: ia64: build fix
From: Ingo Molnar <mingo@elte.hu>

DISCONTIGMEM does not build with NUMA disabled:

include/linux/gfp.h: In function `alloc_pages_node':
include/linux/gfp.h:189: error: implicit declaration of function `NODE_DATA'
include/linux/gfp.h:189: error: invalid type argument of `->'
In file included from include/asm/uaccess.h:39,

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/ia64/Kconfig |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-x86.q/arch/ia64/Kconfig
=================================--- linux-x86.q.orig/arch/ia64/Kconfig
+++ linux-x86.q/arch/ia64/Kconfig
@@ -351,7 +351,8 @@ config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 
 config ARCH_DISCONTIGMEM_ENABLE
-	def_bool y
+	def_bool n
+	depends on NUMA
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
 	  for architectures which are either NUMA (Non-Uniform Memory Access)
@@ -372,7 +373,7 @@ config ARCH_DISCONTIGMEM_DEFAULT
 
 config NUMA
 	bool "NUMA support"
-	depends on !IA64_HP_SIM && !FLATMEM
+	depends on !IA64_HP_SIM
 	default y if IA64_SGI_SN2
 	select ACPI_NUMA if ACPI
 	help
