From: Keith Owens <kaos@sgi.com>
Date: Thu, 09 Dec 2004 01:41:33 +0000
Subject: Re: [patch 2.6.10-rc3] Add TIF_SIGDELAYED processing
Message-Id: <5351.1102556493@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <15449.1102482344@kao1.melbourne.sgi.com>
In-Reply-To: <15449.1102482344@kao1.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Dec 2004 17:22:27 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Wed, 08 Dec 2004 16:05:44 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> Some of the work on recoverable MCA events has a requirement
>  Keith> to send a signal to a user process.  But it is not safe to
>  Keith> send signals from MCA/INIT/NMI/PMI, because the rest of the
>  Keith> kernel is an unknown state.  This patch adds set_sigdelayed()
>  Keith> which is called from the problem contexts to set the delayed
>  Keith> signal.  The delayed signal will be delivered from the right
>  Keith> context on the next transition from kernel to user space.
>
>  Keith> If TIF_SIGDELAYED is set when we run ia64_leave_kernel or
>  Keith> ia64_leave_syscall then the delayed signal is delivered and
>  Keith> cleared.  All code for sigdelayed processing is on the slow
>  Keith> paths.
>
>  Keith> A recoverable MCA handler that wants to kill a user task just
>  Keith> does
>
>  Keith>   set_sigdelayed(pid, signo, code, addr);
>
>It seems rather dangerous to stash away PIDs and deliver signals to
>them later on.  It's just an invitation for races, IMHO.

The pid is checked to see if it is still valid, see do_sigdelayed().
Yes, there is a very small race where the pid could be reused, but to
hit that race we have to -

* Terminate the failing task with that pid.

* Either of the current task or the idle task must sleep for a period
  that is long enough for the failing pid to be reassigned and

* The new task with the failing pid must be running when the current or
  idle task is rescheduled for the first time.

The pids recycle with a period of approximately 0x8000.  It is highly
unlikely that the current or idle task will sleep for that long,
especially since the current task is usually the one that caused the
MCA so it gets killed anyway.

To make it really safe, I can save the start_time from the offending
task in struct sigdelayed and only send the signal if the saved value
matches the start_time of the task that currently has this pid.  It
just takes a little more space.

