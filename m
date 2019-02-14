From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 14 Feb 2019 10:37:15 +0000
Subject: Re: [PATCH v4 0/3] locking/rwsem: Rwsem rearchitecture part 0
Message-Id: <20190214103715.GI32494@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1550095217-12047-1-git-send-email-longman@redhat.com>
In-Reply-To: <1550095217-12047-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Will Deacon <will.deacon@arm.com>, linux-mips@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, Arnd Bergmann <arnd@arndb.de>, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Tim Chen <tim.c.chen@linux.intel.com>, linux-parisc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-alpha@vger.ker

On Wed, Feb 13, 2019 at 05:00:14PM -0500, Waiman Long wrote:
> v4:
>  - Remove rwsem-spinlock.c and make all archs use rwsem-xadd.c.
> 
> v3:
>  - Optimize __down_read_trylock() for the uncontended case as suggested
>    by Linus.
> 
> v2:
>  - Add patch 2 to optimize __down_read_trylock() as suggested by PeterZ.
>  - Update performance test data in patch 1.
> 
> The goal of this patchset is to remove the architecture specific files
> for rwsem-xadd to make it easer to add enhancements in the later rwsem
> patches. It also removes the legacy rwsem-spinlock.c file and make all
> the architectures use one single implementation of rwsem - rwsem-xadd.c.
> 
> Waiman Long (3):
>   locking/rwsem: Remove arch specific rwsem files
>   locking/rwsem: Remove rwsem-spinlock.c & use rwsem-xadd.c for all
>     archs
>   locking/rwsem: Optimize down_read_trylock()

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

with the caveat that I'm happy to exchange patch 3 back to my earlier
suggestion in case Will expesses concerns wrt the ARM64 performance of
Linus' suggestion.
