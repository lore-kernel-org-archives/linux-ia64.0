From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 01 Mar 2002 23:06:22 +0000
Subject: Re: [Linux-ia64] O(1) scheduler K3+ for IA64
Message-Id: <marc-linux-ia64-105590701905208@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905201@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905201@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hey Erich, I've been testing out your latest K3+ patch (along with
yours and Mike's NUMA scheduler changes) and found that it seems less
stable than the old version that used locking for the tlb flush stuff.
I think there's a deadlock somewhere in the new code since
2.4.17 + kdb + ia64 + Ingo K3 + old K3+: rock solid
2.4.17 + kdb + ia64 + Ingo K3 + new K3+: sometimes hangs at boot,
  sometimes after a few hackbench processes have run

I'm in the process of trying to figure out exactly why the hangs
happen, but I thought I'd let you know since you might be able to find
out right away.

Thanks,
Jesse

On Thu, Feb 28, 2002 at 07:44:42PM +0100, Erich Focht wrote:
> Hi,
> 
> the latest scheduler from Ingo included in 2.5.6-pre1 includes
> set_cpus_allowed() function working for all processes. Here is a port to
> IA64, kernel 2.4.17. Please apply: 
>   - kdb-v2.1-2.4.17-common-2
>   - linux-2.4.17-ia64-011226.diff
>   - kdb-v2.1-2.4.17-ia64-011226-1
>   - sched-O1-2.4.17-K3.patch  from http://people.redhat.com/mingo/O(1)-scheduler/
>   - the appended ia64 port with K3+ changes.
> 
> There is a small bugfix included (disable interrupts in
> migration_task) and I changed the way how the migration tasks were
> distributed across the CPUs. I hope this works for everybody...
> 
> Regards,
> Erich

