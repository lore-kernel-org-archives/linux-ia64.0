From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 17 Oct 2007 08:16:19 +0000
Subject: Re: [PATCH 9/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4715C4D3.70004@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4714BF9C.6090308@jp.fujitsu.com>
In-Reply-To: <4714BF9C.6090308@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Chubb wrote:
> This patchset duplicates some of the Microstate Accounting patchset
> (which attempts to keep track of time spent in various states for each
> thread).  As such I've had some experience trying to do this stuff.

Google is kind enough to tell me how was your Microstate Accounting
patchset. Both of yours and mine intended to implement a state-transition
based accounting to get more accurate cpu time. It is common point.

The differences are origin (maybe msa is from Solaris, right?), targeting
arch (sys_msa aimed at multiple archs, but my patchset touches ia64 only),
and actual achievement on linux (completely new vs proven on IBM archs).

>   Things to watch are:
>  -- With Montvale and later, the processor clock speed can be
>     varied via ACPI.  Does ITC rate change?  In additon, KVM can
>     virtualise ITC (although it doesn't at present)

The factors for cycle-to-nsec translation are treated as per-cpu data.
Thus it would not be problem if processor clocks are varied at boot.

I'm not sure whether the clocks can be changed while running or not.
If it can, at least it will also affect sched_clock(), and god knows
who will work for the problem...

>  -- ITC is not synchronised across multiple processors.  I don't think
>     this'll be an issue for you as you're only measuring time on-cpu,
>     and migration necessarily goes via a run queue.

Yes, it doesn't matter. I don't compare cycles from different cpus.

>  -- Adding ACCOUNT_SYS_ENTER adds around 40 cycles to the system
>     call path.  If you wanted, you could move reading ITC earlier (it
>     takes up to 36 cycles), and overlap with other work.

Indeed. It is worth to do.

Thanks,
H.Seto

> Peter C
> --
> Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
> http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
