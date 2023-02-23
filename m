From: Andrzej Hajda <andrzej.hajda@intel.com>
Date: Thu, 23 Feb 2023 21:24:19 +0000
Subject: Re: [Intel-gfx] [PATCH v5 0/7] Introduce __xchg, non-atomic xchg
Message-Id: <17f40b7c-f98d-789d-fa19-12ec077b756a@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230118153529.57695-1-andrzej.hajda@intel.com>
 <Y/ZLH5F8LA3H10aL@hirez.programming.kicks-ass.net>
In-Reply-To: <Y/ZLH5F8LA3H10aL@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mips@vger.kernel.org, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-snps-arc@lists.infradead.org, Boqun Feng <boqun.feng@gmail.com>, linux-xtensa@linux-xtensa.org, Arnd Bergmann <arnd@arndb.de>, intel-gfx@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, loongarch@lists.linux.dev, Rodrigo Vivi <rodrigo.vivi@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

On 22.02.2023 18:04, Peter Zijlstra wrote:
> On Wed, Jan 18, 2023 at 04:35:22PM +0100, Andrzej Hajda wrote:
> 
>> Andrzej Hajda (7):
>>    arch: rename all internal names __xchg to __arch_xchg
>>    linux/include: add non-atomic version of xchg
>>    arch/*/uprobes: simplify arch_uretprobe_hijack_return_addr
>>    llist: simplify __llist_del_all
>>    io_uring: use __xchg if possible
>>    qed: use __xchg if possible
>>    drm/i915/gt: use __xchg instead of internal helper
> 
> Nothing crazy in here I suppose, I somewhat wonder why you went through
> the trouble, but meh.

If you are asking why I have proposed this patchset, then the answer is 
simple, 1st I've tried to find a way to move internal i915 helper to 
core (see patch 7).
Then I was looking for possible other users of this helper. And 
apparently there are many of them, patches 3-7 shows some.


> 
> You want me to take this through te locking tree (for the next cycle,
> not this one) where I normally take atomic things or does someone else
> want this?

If you could take it I will be happy.

Regards
Andrzej
