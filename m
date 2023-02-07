From: Finn Thain <fthain@linux-m68k.org>
Date: Tue, 07 Feb 2023 03:07:03 +0000
Subject: Re: [PATCH 04/10] m68k: fix livelock in uaccess
Message-Id: <fc3d0151-30a0-c029-3e43-68664d4d50e6@linux-m68k.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV> <Y9l0aBPUEpf1bci9@ZenIV> <92a4aa45-0a7c-a389-798a-2f3e3cfa516f@linux-m68k.org> <CAHk-=wirpn8qX5hCyeS0a4GCQH5p-2ACXgzJTj7zjZ5rGux_Bw@mail.gmail.com>
In-Reply-To: <CAHk-=wirpn8qX5hCyeS0a4GCQH5p-2ACXgzJTj7zjZ5rGux_Bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org

On Sun, 5 Feb 2023, Linus Torvalds wrote:

> On Sat, Feb 4, 2023 at 10:16 PM Finn Thain <fthain@linux-m68k.org> wrote:
> >
> > That could be a bug I was chasing back in 2021 but never found. The mmap
> > stressors in stress-ng were triggering a crash on a Mac Quadras, though
> > only rarely. Sometimes it would run all day without a failure.
> >
> > Last year when I started using GCC 12 to build the kernel, I saw the same
> > workload fail again but the failure mode had become a silent hang/livelock
> > instead of the oopses I got with GCC 6.
> >
> > When I press the NMI button after the livelock I always see
> > do_page_fault() in the backtrace. So I've been testing your patch. I've
> > been running the same stress-ng reproducer for about 12 hours now with no
> > failures which looks promising.
> >
> > In case that stress-ng testing is of use:
> > Tested-by: Finn Thain <fthain@linux-m68k.org>
> 
> Could you test the thing that Mark Rutland pointed to? He had an
> actual test-case for this for the arm64 fixes some years ago.
> 
> See
> 
>    https://lore.kernel.org/all/Y9pD+TMP+%2FSyfeJm@FVFF77S0Q05N/
> 
> for his email with links to his old test-case?
> 

With qemu-system-m68k v7.2 runing Linux v6.1, killing Mark's program did 
not trigger any failure.

With my Quadra 650 running the same binaries, killing Mark's program 
produces the BUG splat below. I can confirm that Al's patch fixes it.

[  199.060000] BUG: scheduling while atomic: test/48/0x0003e2e6
[  199.060000] Modules linked in:
[  199.060000] CPU: 0 PID: 48 Comm: test Tainted: G        W          6.1.0-mac #3
[  199.060000] Stack from 00a6204c:
[  199.060000]         00a6204c 004c1979 004c1979 00000000 00a6215e 00a6206c 00408d62 004c1979
[  199.060000]         00a62074 0003ad4a 00a620a8 004099e2 00983480 00000000 00a6215e 00000000
[  199.060000]         00000002 00983480 00a62000 0040970a 00a6209c 00a6209c 00a620c0 00a620c0
[  199.060000]         00409b94 00000000 00bcf0c0 00a62198 00a357fc 00a6216c 00120e5c 00bcf0d0
[  199.060000]         00000003 00000001 00000001 0123f039 00000000 00a357fc 00aead38 005870dc
[  199.060000]         005870dc 00a31200 00000000 00000000 00000000 00010000 0000c000 00000000
[  199.060000] Call Trace: [<00408d62>] dump_stack+0x10/0x16
[  199.060000]  [<0003ad4a>] __schedule_bug+0x5e/0x70
[  199.060000]  [<004099e2>] __schedule+0x2d8/0x446
[  199.060000]  [<0040970a>] __schedule+0x0/0x446
[  199.060000]  [<00409b94>] schedule+0x44/0x8e
[  199.060000]  [<00120e5c>] handle_userfault+0x298/0x3de
[  199.060000]  [<00010000>] zer_rp2+0x14/0x18
[  199.060000]  [<0000c000>] cu_dmrs+0x0/0x16
[  199.060000]  [<00001200>] kernel_pg_dir+0x200/0x1000
[  199.060000]  [<00010000>] zer_rp2+0x14/0x18
[  199.060000]  [<0000c000>] cu_dmrs+0x0/0x16
[  199.060000]  [<00001200>] kernel_pg_dir+0x200/0x1000
[  199.060000]  [<00010000>] zer_rp2+0x14/0x18
[  199.060000]  [<0000c000>] cu_dmrs+0x0/0x16
[  199.060000]  [<000ab0a0>] handle_mm_fault+0xa34/0xa56
[  199.060000]  [<000c0000>] __alloc_pages_bulk+0x26/0x3f8
[  199.060000]  [<00007056>] do_page_fault+0xd8/0x28a
[  199.060000]  [<00006098>] buserr_c+0x1a6/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<000056fc>] do_040writeback1+0x0/0x1d8
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<000062cc>] buserr_c+0x3da/0x6b0
[  199.060000]  [<00001000>] kernel_pg_dir+0x0/0x1000
[  199.060000]  [<00002ac0>] buserr+0x20/0x28
[  199.060000]  [<00001000>] kernel_pg_dir+0x0/0x1000
[  199.060000]  [<00008001>] mac_irq_disable+0x3b/0x98
[  199.060000]  [<00001000>] kernel_pg_dir+0x0/0x1000
[  199.060000]  [<00008001>] mac_irq_disable+0x3b/0x98
[  199.060000] 
