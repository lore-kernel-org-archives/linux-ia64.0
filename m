From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 22 Mar 2019 19:30:10 +0000
Subject: Re: [PATCH v5 1/3] locking/rwsem: Remove arch specific rwsem files
Message-Id: <20190322193010.azb7rmmmaclhal35@linux-r8p5>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190322143008.21313-1-longman@redhat.com>
 <20190322143008.21313-2-longman@redhat.com>
 <CAHk-=wikkO-1f1=FEOEzkSnaDg3yJLP=4Vd59UCuLBztFd0KOw@mail.gmail.com>
In-Reply-To: <CAHk-=wikkO-1f1=FEOEzkSnaDg3yJLP=4Vd59UCuLBztFd0KOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.orgLinux-shlist

On Fri, 22 Mar 2019, Linus Torvalds wrote:
>Some of them _might_ be performance-critical. There's the one on
>mmap_sem in the fault handling path, for example. And yes, I'd expect
>the normal case to very much be "no other readers or writers" for that
>one.

Yeah, the mmap_sem case in the fault path is really expecting an unlocked
state. To the point that four archs have added branch predictions, ie:

 92181f190b6 (x86: optimise x86's do_page_fault (C entry point for the page fault path))
 b15021d994f (powerpc/mm: Add a bunch of (un)likely annotations to do_page_fault)

And using PROFILE_ANNOTATED_BRANCHES shows pretty clearly:
(without resetting the counters)

 correct incorrect  %        Function              File          Line
 ------- ---------  -        --------              ----          ----
  4603685       34   0 do_user_addr_fault         fault.c          1416 (bootup)
382327745      449   0 do_user_addr_fault         fault.c          1416 (kernel build)
399446159      461   0 do_user_addr_fault         fault.c          1416 (redis benchmark)

It would probably wouldn't harm doing the unlikely() for all archs, or
alternatively, add likely() to the atomic_long_try_cmpxchg_acquire in
patch 3 and do it implicitly but maybe that would be less flexible(?)

Thanks,
Davidlohr
