From: Waiman Long <longman@redhat.com>
Date: Fri, 15 Feb 2019 18:58:34 +0000
Subject: Re: [PATCH v4 0/3] locking/rwsem: Rwsem rearchitecture part 0
Message-Id: <a45d8b68-5623-d6fe-8080-072994f7625e@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1550095217-12047-1-git-send-email-longman@redhat.com>
 <20190214103715.GI32494@hirez.programming.kicks-ass.net>
 <20190215184056.GC15084@fuggles.cambridge.arm.com>
In-Reply-To: <20190215184056.GC15084@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hp>

On 02/15/2019 01:40 PM, Will Deacon wrote:
> On Thu, Feb 14, 2019 at 11:37:15AM +0100, Peter Zijlstra wrote:
>> On Wed, Feb 13, 2019 at 05:00:14PM -0500, Waiman Long wrote:
>>> v4:
>>>  - Remove rwsem-spinlock.c and make all archs use rwsem-xadd.c.
>>>
>>> v3:
>>>  - Optimize __down_read_trylock() for the uncontended case as suggested
>>>    by Linus.
>>>
>>> v2:
>>>  - Add patch 2 to optimize __down_read_trylock() as suggested by PeterZ.
>>>  - Update performance test data in patch 1.
>>>
>>> The goal of this patchset is to remove the architecture specific files
>>> for rwsem-xadd to make it easer to add enhancements in the later rwsem
>>> patches. It also removes the legacy rwsem-spinlock.c file and make all
>>> the architectures use one single implementation of rwsem - rwsem-xadd.c.
>>>
>>> Waiman Long (3):
>>>   locking/rwsem: Remove arch specific rwsem files
>>>   locking/rwsem: Remove rwsem-spinlock.c & use rwsem-xadd.c for all
>>>     archs
>>>   locking/rwsem: Optimize down_read_trylock()
>> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>>
>> with the caveat that I'm happy to exchange patch 3 back to my earlier
>> suggestion in case Will expesses concerns wrt the ARM64 performance of
>> Linus' suggestion.
> Right, the current proposal doesn't work well for us, unfortunately. Which
> was your earlier suggestion?
>
> Will

In my posting yesterday, I showed that most of the trylocks done were
actually uncontended. Assuming that pattern hold for the most of the
workloads, it will not that bad after all.

-Longman
