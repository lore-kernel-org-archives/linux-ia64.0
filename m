From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Date: Wed, 13 Jan 2016 00:21:36 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <56959890.80101@imgtec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-12-git-send-email-mst@redhat.com> <56945366.2090504@imgtec.com> <20160112092711.GP6344@twins.programming.kicks-ass.net> <20160112102555.GV6373@twins.programming.kicks-ass.net> <20160112104012.GW6373@twins.programming.kicks-ass.net> <20160112114111.GB15737@arm.com> <569565DA.2010903@imgtec.com> <20160112214003.GQ6357@twins.programming.kicks-ass.net>
In-Reply-To: <20160112214003.GQ6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.k

On 01/12/2016 01:40 PM, Peter Zijlstra wrote:
>
>> It is selectable only for MIPS R2 but not MIPS R6. The reason is - most of
>> MIPS R2 CPUs have short pipeline and that SYNC is just waste of CPU
>> resource, especially taking into account that "lightweight syncs" are
>> converted to a heavy "SYNC 0" in many of that CPUs. However the latest
>> MIPS/Imagination CPU have a pipeline long enough to hit a problem - absence
>> of SYNC at LL/SC inside atomics, barriers etc.
> What ?! Are you saying that because R2 has short pipelines its unlikely
> to hit the reordering issues and we can omit barriers?

It was my guess to explain - why barriers was not included originally. 
You can check with Ralf, he knows more about that time MIPS Linux code.

I bother with this more than 2 years and I just try to solve that issue 
- in recent CPUs the load after LL/SC synchronization instruction loop 
can get ahead of SC for sure, it was tested.

>
>>> And reading the MIPS64 v6.04 instruction set manual, I think 0x11/0x12
>>> are_NOT_  transitive and therefore cannot be used to implement the
>>> smp_mb__{before,after} stuff.
>>>
>>> That is, in MIPS speak, those SYNC types are Ordering Barriers, not
>>> Completion Barriers.
>> Please see above, point 2.
> That did not in fact enlighten things. Are they transitive/multi-copy
> atomic or not?

Peter Zijlstra recently wrote: "In particular we're very much all 
'confused' about the various notions of transitivity". I am actually 
confused too and need some examples here.

>
> (and here Will will go into great detail on the differences between the
> two and make our collective brains explode :-)
>
>>> That is, currently all architectures -- with exception of PPC -- have
>>> RCsc locks, but using these non-transitive things will get you RCpc
>>> locks.
>>>
>>> So yes, MIPS can go RCpc for its locks and share the burden of pain with
>>> PPC, but that needs to be a very concious decision.
>> I don't understand that - I tried hard but I can't find any word like
>> "RCsc", "RCpc" in Documents/ directory. Web search goes nowhere, of course.
> From: lkml.kernel.org/r/20150828153921.GF19282@twins.programming.kicks-ass.net
>
> Yes, the difference between RCpc and RCsc is in the meaning of RELEASE +
> ACQUIRE. With RCsc that implies a full memory barrier, with RCpc it does
> not.

MIPS Arch starting from R2 requires that. If some CPU can't, it should 
execute a full "SYNC 0" instead, which is a full memory barrier.

>
> Currently PowerPC is the only arch that (can, and) does RCpc and gives a
> weaker RELEASE + ACQUIRE. Only the CPU who did the ACQUIRE is guaranteed
> to see the stores of the CPU which did the RELEASE in order.

Yes, it was a goal for SYNC_ACQUIRE and SYNC_RELEASE.

Caveats:

     - "Full memory barrier" on MIPS means - full barrier for any device 
in coherent domain. In MIPS Tech/Imagination Tech MIPS-based CPU it is 
"for any device connected to CM or IOCU + directly connected memory".

     - It is not applied to instruction fetch. However, I-Cache flushes 
and SYNCI are consistent with that. There is also hazard barrier 
instructions to clear CPU pipeline to some extent - to help with this 
limitation.

I don't think that these caveats prevent a correct Acquire/Release semantic.

- Leonid.


