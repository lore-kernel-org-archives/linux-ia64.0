From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 30 Jan 2008 20:59:15 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <20080130205915.GA4562@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <47A0CD4B.5040706@sgi.com> <1FE6DD409037234FAB833C420AA843EC757F12@orsmsx424.amr.corp.intel.com> <20080130194616.GA19426@elte.hu> <1FE6DD409037234FAB833C420AA843EC757F7C@orsmsx424.amr.corp.intel.com> <20080130200221.GA28073@elte.hu> <1FE6DD409037234FAB833C420AA843EC757FC2@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC757FC2@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Mike Travis <travis@sgi.com>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org


* Luck, Tony <tony.luck@intel.com> wrote:

> > could you send the .config you are using?
> 
> Ok.  Attached.

thanks a ton - this produced a link error here too.

after half an hour of head scratching, the updated patch below solves 
the build problem.

The problem i believe is this code in arch/ia64/kernel/mca_asm.S:

#define GET_IA64_MCA_DATA(reg)                                          \
        GET_THIS_PADDR(reg, ia64_mca_data)                              \
        ;;                                                              \
        ld8 reg=[reg]

this i believe builds an implicit dependency between the mca_asm.o 
position within the image and the ia64_mca_data percpu variable it 
accesses - it relies on the immediate 22 addressing mode that has 4MB of 
scope. Per chance, the .config you sent creates a 14MB image, and the 
percpu variables moved too far away for the linker to be able to fulfill 
this constraint.

The workaround is to define PER_CPU_ATTRIBUTES to link percpu variables 
back into the .percpu section on UP too - which ia64 links specially 
into its vmlinux.lds. But ultimately i think the better solution would 
be to remove this dependency between arch/ia64/kernel/mca_asm.S and the 
position of the percpu data.

Is my analysis correct? Do you like my fix and does the patch build and 
boot on your system? Thanks,

	Ingo

--------------->
Subject: ia64: on UP percpu variables are not small memory model
From: Ingo Molnar <mingo@elte.hu>

Tony says:

| The CONFIG_SMP=n path in ia64 makes quite radical changes ... rather
| than putting all the per-cpu stuff into the top 64K of address space
| and providing a per-cpu TLB mapping for that range to a different
| physical address ... it just makes all the per-cpu stuff link as ordinary
| variables in .data.

the new generic percpu code got confused about this as PER_CPU_ATTRIBUTES
was defined even on UP, so it picked up that small memory model - which
was not possible to get linked. The right fix is to only define that
on SMP. This resolved the build failures in my cross-compiling environment.

also link these variables into the .percpu section - some assembly code 
has offset dependencies.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 include/asm-ia64/percpu.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: linux-x86.q/include/asm-ia64/percpu.h
=================================--- linux-x86.q.orig/include/asm-ia64/percpu.h
+++ linux-x86.q/include/asm-ia64/percpu.h
@@ -15,18 +15,20 @@
 
 #include <linux/threads.h>
 
+#ifdef CONFIG_SMP
+
 #ifdef HAVE_MODEL_SMALL_ATTRIBUTE
 # define PER_CPU_ATTRIBUTES	__attribute__((__model__ (__small__)))
 #endif
 
-#ifdef CONFIG_SMP
-
 #define __my_cpu_offset	__ia64_per_cpu_var(local_per_cpu_offset)
 
 extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
+#define PER_CPU_ATTRIBUTES	__attribute__((__section__(".data.percpu")))
+
 #define per_cpu_init()				(__phys_per_cpu_start)
 
 #endif	/* SMP */
