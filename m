From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Date: Thu, 14 Jan 2016 19:42:02 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <5697FA0A.6040601@imgtec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160112092711.GP6344@twins.programming.kicks-ass.net>
	<20160112102555.GV6373@twins.programming.kicks-ass.net>
	<20160112104012.GW6373@twins.programming.kicks-ass.net>
	<20160112114111.GB15737@arm.com> <569565DA.2010903@imgtec.com>
	<20160113104516.GE25458@arm.com> <56969F4B.7070001@imgtec.com>
	<20160113204844.GV6357@twins.programming.kicks-ass.net>
	<5696BA6E.4070508@imgtec.com> <20160114120445.GB15828@arm.com>
	<20160114161604.GT3818@linux.vnet.ibm.com>
In-Reply-To: <20160114161604.GT3818@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulmck@linux.vnet.ibm.com, Will Deacon <will.deacon@arm.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, And

On 01/14/2016 08:16 AM, Paul E. McKenney wrote:
> On Thu, Jan 14, 2016 at 12:04:45PM +0000, Will Deacon wrote:
>> On Wed, Jan 13, 2016 at 12:58:22PM -0800, Leonid Yegoshin wrote:
>>> On 01/13/2016 12:48 PM, Peter Zijlstra wrote:
>>>> On Wed, Jan 13, 2016 at 11:02:35AM -0800, Leonid Yegoshin wrote:
>>>>
>>>>> I ask HW team about it but I have a question - has it any relationship with
>>>>> replacing MIPS SYNC with lightweight SYNCs (SYNC_WMB etc)?
>>>> Of course. If you cannot explain the semantics of the primitives you
>>>> introduce, how can we judge the patch.
>>>>
>>>>
>>> You missed a point - it is a question about replacement of SYNC with
>>> lightweight primitives. It is NOT a question about multithread system
>>> behavior without any SYNC. The answer on a latest Will's question lies in
>>> different area.
> What Will said!
>
> Yes, you can cut corners within MIPS architecture-specific code,
> but primitives that are used in the core kernel really do need to
> work as expected.
>
> 							Thanx, Paul
>
>
Absolutelly! Please use SYNC - right now it is not.

An the only point - please use an appropriate SYNC_* barriers instead of 
heavy bold hammer. That stuff was design explicitly to support the 
requirements of Documentation/memory-barriers.txt

It is easy - just use smp_acquire instead of plain smp_mb 
insmp_load_acquire, at least for MIPS.

- Leonid.
- Leonid.
