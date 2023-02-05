From: Al Viro <viro@zeniv.linux.org.uk>
Date: Sun, 05 Feb 2023 20:39:44 +0000
Subject: Re: [PATCH 04/10] m68k: fix livelock in uaccess
Message-Id: <Y+AUEJpWYdUzW0OD@ZenIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV>
 <Y9l0aBPUEpf1bci9@ZenIV>
 <92a4aa45-0a7c-a389-798a-2f3e3cfa516f@linux-m68k.org>
In-Reply-To: <92a4aa45-0a7c-a389-798a-2f3e3cfa516f@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Finn Thain <fthain@linux-m68k.org>
Cc: linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Feb 05, 2023 at 05:18:08PM +1100, Finn Thain wrote:

> That could be a bug I was chasing back in 2021 but never found. The mmap 
> stressors in stress-ng were triggering a crash on a Mac Quadras, though 
> only rarely. Sometimes it would run all day without a failure.
> 
> Last year when I started using GCC 12 to build the kernel, I saw the same 
> workload fail again but the failure mode had become a silent hang/livelock 
> instead of the oopses I got with GCC 6.
> 
> When I press the NMI button after the livelock I always see 
> do_page_fault() in the backtrace. So I've been testing your patch. I've 
> been running the same stress-ng reproducer for about 12 hours now with no 
> failures which looks promising.
> 
> In case that stress-ng testing is of use:
> Tested-by: Finn Thain <fthain@linux-m68k.org>
> 
> BTW, how did you identify that bug in do_page_fault()? If its the same bug 
> I was chasing, it could be an old one. The stress-ng logs I collected last 
> year include a crash from a v4.14 build.

Went to reread the current state of mm/gup.c, decided to reread handle_mm_fault()
and its callers, noticed fault_signal_pending() which hadn't been there back
when I last crawled through that area, realized what it had replaced, went
to check if everything had been converted (arch/um got missed, BTW).  Noticed
the difference between the architectures (the first hit was on alpha, without
the "sod off to no_context if it's a user fault" logics, the last - xtensa, with
it).  Checked the log for xtensa, found the commit from 2021 adding that part;
looked on arm and arm64, found commits from 2017 doing the same thing, then,
on x86, Linus' commit from 2014 adding the x86 counterpart...  Figuring out
what all of those had been for wasn't particularly hard, and it was easy
to check which architectures still needed the same thing...

BTW, since these patches would be much easier to backport than any unification
work, I think the right thing to do would be to have further unification done on
top of them.
