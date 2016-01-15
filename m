From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Date: Fri, 15 Jan 2016 01:07:14 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <56984642.3090106@imgtec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160113104516.GE25458@arm.com> <5696CF08.8080700@imgtec.com>
	<20160114121449.GC15828@arm.com> <5697F6D2.60409@imgtec.com>
	<20160114203430.GC3818@linux.vnet.ibm.com>
	<56980C91.1010403@imgtec.com>
	<20160114212913.GF3818@linux.vnet.ibm.com>
	<569814F2.50801@imgtec.com>
	<20160114225510.GJ3818@linux.vnet.ibm.com>
	<56983054.4070807@imgtec.com>
	<20160115004753.GN3818@linux.vnet.ibm.com>
In-Reply-To: <20160115004753.GN3818@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulmck@linux.vnet.ibm.com
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.orglinux-a

On 01/14/2016 04:47 PM, Paul E. McKenney wrote:
> On Thu, Jan 14, 2016 at 03:33:40PM -0800, Leonid Yegoshin wrote:
>> Don't be fooled here by words "ordered" and "completed" - it is HW
>> design items and actually written poorly.
>> Just assume that SYNC_MB is absolutely the same as SYNC for any CPU
>> and coherent device (besides performance). The difference can be in
>> non-coherent devices because SYNC actually tries to make a barrier
>> for them too. In some SoCs it is just the same because there is no
>> need to barrier a non-coherent device (device register access
>> usually strictly ordered... if there is no bridge in between).
> So smp_mb() can be SYNC_MB.  However, mb() needs to be SYNC for MMIO
> purposes, correct?

Absolutely. For MIPS R2 which is not Octeon.

>> Note: I am not sure about ANY past MIPS R2 CPU because that stuff is
>> implemented some time but nobody made it in Linux kernel (it was
>> used by some vendor for non-Linux system). For that reason my patch
>> for lightweight SYNCs has an option - implement it or implement a
>> generic SYNC. It is possible that some vendor did it in different
>> way but nobody knows or test it. But as a minimum - SYNC must be
>> implemented in spinlocks/atomics/bitops, in recent P5600 it is
>> proven that read can pass write in atomics.
>>
>> MIPS R6 is a different story, I verified lightweight SYNCs from the
>> beginning and it also should use SYNCs.
> So you need to build a different kernel for some types of MIPS systems?
> Or do you do boot-time rewriting, like a number of other arches do?

I don't know. I would like to have responses. Ralf asked Maciej about 
old systems and that came nowhere. Even rewrite - don't know what to do 
with that: no lightweight SYNC or no SYNC at all - yes, it is still 
possible that SYNC on some systems can be too heavy or even harmful, 
nobody tested that.

- Leonid.


