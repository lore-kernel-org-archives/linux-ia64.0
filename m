From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Date: Thu, 14 Jan 2016 21:01:05 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <56980C91.1010403@imgtec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <56945366.2090504@imgtec.com>
	<20160112092711.GP6344@twins.programming.kicks-ass.net>
	<20160112102555.GV6373@twins.programming.kicks-ass.net>
	<20160112104012.GW6373@twins.programming.kicks-ass.net>
	<20160112114111.GB15737@arm.com> <569565DA.2010903@imgtec.com>
	<20160113104516.GE25458@arm.com> <5696CF08.8080700@imgtec.com>
	<20160114121449.GC15828@arm.com> <5697F6D2.60409@imgtec.com>
	<20160114203430.GC3818@linux.vnet.ibm.com>
In-Reply-To: <20160114203430.GC3818@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulmck@linux.vnet.ibm.com
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.orglinux-a

I need some time to understand your test examples. However,

On 01/14/2016 12:34 PM, Paul E. McKenney wrote:
>
>
> The WRC+addr+addr is OK because data dependencies are not required to be
> transitive, in other words, they are not required to flow from one CPU to
> another without the help of an explicit memory barrier.

I don't see any reliable way to fit WRC+addr+addr into "DATA DEPENDENCY 
BARRIERS" section recommendation to have data dependency barrier between 
read of a shared pointer/index and read the shared data based on that 
pointer. If you have this two reads, it doesn't matter the rest of 
scenario, you should put the dependency barrier in code anyway. If you 
don't do it in WRC+addr+addr scenario then after years it can be easily 
changed to different scenario which fits some of scenario in "DATA 
DEPENDENCY BARRIERS" section and fails.

>    Transitivity is

Peter Zijlstra recently wrote: "In particular we're very much all 
'confused' about the various notions of transitivity". I am confused 
too, so - please use some more simple way to explain your words. Sorry, 
but we need a common ground first.

- Leonid.
