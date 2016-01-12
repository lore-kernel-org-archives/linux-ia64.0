From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 12 Jan 2016 21:40:03 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160112214003.GQ6357@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-12-git-send-email-mst@redhat.com>
 <56945366.2090504@imgtec.com>
 <20160112092711.GP6344@twins.programming.kicks-ass.net>
 <20160112102555.GV6373@twins.programming.kicks-ass.net>
 <20160112104012.GW6373@twins.programming.kicks-ass.net>
 <20160112114111.GB15737@arm.com>
 <569565DA.2010903@imgtec.com>
In-Reply-To: <569565DA.2010903@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: Will Deacon <will.deacon@arm.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linu

On Tue, Jan 12, 2016 at 12:45:14PM -0800, Leonid Yegoshin wrote:
> (I try to answer on multiple mails in one)
> 
> First of all, it seems like some generic notes should be given here:
> 
> 1. Generic MIPS "SYNC" (aka "SYNC 0") instruction is a very heavy in some
> CPUs. On that CPUs it basically kills pipelines in each CPU, can do a
> special memory/IO bus transaction (similar to "fence") and hold a system
> until all R/W is completed. It is like Big Kernel Lock but worse. So, the
> move to SMP_* kind of barriers is needed to improve performance, especially
> on newest CPUs with long pipelines.

The MIPS SYNC isn't any worse than the PPC SYNC, x86 MFENCE or arm DSB
SY, yes they're heavy, so what.

> 2. MIPS Arch document may be misleading because words "ordering" and
> "completion" means different from Linux, the SYNC instruction description is
> written for HW engineers. I wrote that in a separate patch of the same
> patchset - http://patchwork.linux-mips.org/patch/10505/ "MIPS: R6: Use
> lightweight SYNC instruction in smp_* memory barriers":

Did you actually say anything here?

> >This instructions were specifically designed to work for smp_*() sort of
> >memory barriers in MIPS R2/R3/R5 and R6.
> >
> >Unfortunately, it's description is very cryptic and is done in HW engineering
> >style which prevents use of it by SW.
> 
> 3. I bother MIPS Arch team long time until I completely understood that MIPS
> SYNC_WMB, SYNC_MB, SYNC_RMB, SYNC_RELEASE and SYNC_ACQUIRE do an exactly
> that is required in Documentation/memory-barriers.txt

Ha! and you think that document covers all the really fun details?

In particular we're very much all 'confused' about the various notions
of transitivity and what barriers imply how much of it.

> In Peter Zijlstra mail:
> 
> >1) you do not make such things selectable; either the hardware needs
> >them or it doesn't. If it does you_must_  use them, however unlikely.

> It is selectable only for MIPS R2 but not MIPS R6. The reason is - most of
> MIPS R2 CPUs have short pipeline and that SYNC is just waste of CPU
> resource, especially taking into account that "lightweight syncs" are
> converted to a heavy "SYNC 0" in many of that CPUs. However the latest
> MIPS/Imagination CPU have a pipeline long enough to hit a problem - absence
> of SYNC at LL/SC inside atomics, barriers etc.

What ?! Are you saying that because R2 has short pipelines its unlikely
to hit the reordering issues and we can omit barriers?

> >And reading the MIPS64 v6.04 instruction set manual, I think 0x11/0x12
> >are_NOT_  transitive and therefore cannot be used to implement the
> >smp_mb__{before,after} stuff.
> >
> >That is, in MIPS speak, those SYNC types are Ordering Barriers, not
> >Completion Barriers.
> 
> Please see above, point 2.

That did not in fact enlighten things. Are they transitive/multi-copy
atomic or not?

(and here Will will go into great detail on the differences between the
two and make our collective brains explode :-)

> >That is, currently all architectures -- with exception of PPC -- have
> >RCsc locks, but using these non-transitive things will get you RCpc
> >locks.
> >
> >So yes, MIPS can go RCpc for its locks and share the burden of pain with
> >PPC, but that needs to be a very concious decision.
> 
> I don't understand that - I tried hard but I can't find any word like
> "RCsc", "RCpc" in Documents/ directory. Web search goes nowhere, of course.

From: lkml.kernel.org/r/20150828153921.GF19282@twins.programming.kicks-ass.net

Yes, the difference between RCpc and RCsc is in the meaning of RELEASE +
ACQUIRE. With RCsc that implies a full memory barrier, with RCpc it does
not.

Currently PowerPC is the only arch that (can, and) does RCpc and gives a
weaker RELEASE + ACQUIRE. Only the CPU who did the ACQUIRE is guaranteed
to see the stores of the CPU which did the RELEASE in order.

As it stands, RCU is the only _known_ codebase where this matters, but
we did in fact write code for a fair number of years 'assuming' RELEASE
+ ACQUIRE was a full barrier, so who knows what else is out there.


RCsc - release consistency sequential consistency
RCpc - release consistency processor consistency

https://en.wikipedia.org/wiki/Processor_consistency

