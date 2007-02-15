From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 15 Feb 2007 09:00:45 +0000
Subject: Re: 2.6.20 new perfmon code base + libpfm + pfmon
Message-Id: <20070215090045.GA12544@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070213184839.GC10031@frankl.hpl.hp.com> <20070213140533.a5ca27ad.akpm@linux-foundation.org> <p737iulhcfb.fsf@bingen.suse.de>
In-Reply-To: <p737iulhcfb.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net, perfmon@napali.hpl.hp.com, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net

Andi,

On Wed, Feb 14, 2007 at 12:20:56AM +0100, Andi Kleen wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > > On Tue, 13 Feb 2007 10:48:39 -0800 Stephane Eranian <eranian@hpl.hp.com> wrote:
> > > I have released another version of the perfmon new code base package.
> > 
> > Can we have a bug push to get this merged up please?
> 
> Yes, there certainly seems to be user interest in this.
> 
> I've been merging the x86 specific infrastructure Stephane sent.
> So hopefully the basics are there already.
> 
Yes, almost everything is in there now. Tony Luck told me he has integrated
the idle notifier for IA-64. I saw that the i386 version of the notifier
was recently integrated as well. So I think that for 2.6.21 we'll have
everything we need for i386, x86-64 and ia64. On MIPS and PowerPC,
a few things are still missing but they should be fixed soon.

On x86-64 and i386, the one last thing I would need that you do not already
have is in the NMI handler for the architectural perfmon to switch PERFCTR0
to PERFCTR1. This would allow certain events to be measured while the NMI
watchdog is active. This is needed on Intel Core-based processors where
certain events can ONLY be measured by PERFCTR0. The CPU_CLK_UNHALTED event
used by the watchdog can be measured by any counter.

I have attached the x86-64 patch for this. I can submit the i386 version
as well.

> The big open question was still the review of the syscall interface.
> Probably needs some determined reviewers.
> 
Not a problem.

> I did a review of some of the basic low level code some time ago;
> there were some issues but I believe they are probably all resolved
> by now (but I haven't verified that recently) 
> 
Yes, all the changes and fixes you and Andrew had requested have been made.


changelog:
	- for architectural perfmon support, switch from PERFCTR0 to PERFCTR1.
	  this does free PERFCTR0 which is the only counter supported for certain
	  events on Intel Core-based processors.

signed-off-by: stephane eranian <eranian@hpl.hp.com>

diff --exclude=.git -urp linux-2.6.20.base/arch/x86_64/kernel/nmi.c linux-2.6.20/arch/x86_64/kernel/nmi.c
--- linux-2.6.20.base/arch/x86_64/kernel/nmi.c	2007-02-05 00:31:52.000000000 -0800
+++ linux-2.6.20/arch/x86_64/kernel/nmi.c	2007-02-09 09:44:29.000000000 -0800
@@ -275,7 +275,7 @@ int __init check_nmi_watchdog (void)
 		 * 32nd bit should be 1, for 33.. to be 1.
 		 * Find the appropriate nmi_hz
 		 */
-	 	if (wd->perfctr_msr = MSR_ARCH_PERFMON_PERFCTR0 &&
+	 	if (wd->perfctr_msr = MSR_ARCH_PERFMON_PERFCTR1 &&
 			((u64)cpu_khz * 1000) > 0x7fffffffULL) {
 			nmi_hz = ((u64)cpu_khz * 1000) / 0x7fffffffUL + 1;
 		}
@@ -615,8 +615,8 @@ static int setup_intel_arch_watchdog(voi
 	    (ebx & ARCH_PERFMON_UNHALTED_CORE_CYCLES_PRESENT))
 		goto fail;
 
-	perfctr_msr = MSR_ARCH_PERFMON_PERFCTR0;
-	evntsel_msr = MSR_ARCH_PERFMON_EVENTSEL0;
+	perfctr_msr = MSR_ARCH_PERFMON_PERFCTR1;
+	evntsel_msr = MSR_ARCH_PERFMON_EVENTSEL1;
 
 	if (!reserve_perfctr_nmi(perfctr_msr))
 		goto fail;
@@ -855,7 +855,7 @@ int __kprobes nmi_watchdog_tick(struct p
 				dummy &= ~P4_CCCR_OVF;
 	 			wrmsrl(wd->cccr_msr, dummy);
 	 			apic_write(APIC_LVTPC, APIC_DM_NMI);
-	 		} else if (wd->perfctr_msr = MSR_ARCH_PERFMON_PERFCTR0) {
+	 		} else if (wd->perfctr_msr = MSR_ARCH_PERFMON_PERFCTR1) {
 				/*
 				 * ArchPerfom/Core Duo needs to re-unmask
 				 * the apic vector

