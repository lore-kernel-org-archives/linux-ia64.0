From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Thu, 08 Aug 2002 04:19:20 +0000
Subject: Re: [Linux-ia64] Re: CPU hotplug boot change for IA64
Message-Id: <marc-linux-ia64-105590701905923@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Tue, 6 Aug 2002 20:33:09 +0200
Erich Focht <efocht@ess.nec.de> wrote:

> The patch looks fine. Before applying it to 2.5.29 my BigSur ended up
> with no tasks beeing scheduled to cpu#1 and no migration_task and
> ksoftirqd for the same cpu.
>
> But the system came up. After applying it 
> the system hangs in the boot sequence right after "Freeing unused
> kernel memory". But CPU#1 was woken up correctly. Sorry, have no kdb
> to be able to tell you more...
> 
> Does anybody else have these problems?

ksoftirqd and migration_thread are spawned in cpu_up() in kernel/cpu.c.
But, cpu_up() wasn't called because the cpu had already been running
at that time (see arch/ia64/kernel/smpboot.c and init/main.c.)
I tried to change init/main.c to call cpu_up() for APs, and I made sure
that the kernel caused the system hangs as you reported.
This means that 2.5.29 kernel is not stable on SMP regardless of
CPU Hot Plug patch applying.
I found that kudzu(1) and shutdown of ethernet may cause system hangs
but I'm not sure why.

Regards,
Kimi

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


