From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 07 Dec 2004 01:36:00 +0000
Subject: Re: [RFC] I/O error handling for userspace
Message-Id: <200412061736.00361.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412030831.25662.jbarnes@engr.sgi.com>
In-Reply-To: <200412030831.25662.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, December 6, 2004 5:29 pm, Keith Owens wrote:
> I understand that you know the pid of the offending process (OP), that
> is not my concern.  Your comment "put the process in a TASK_STOPPED
> state and pend a scheduler tick on the CPU where we took the machine
> check" assumes that sending a scheduler tick will reschedule the OP.

That's not what I was trying to say, I know that the OP may not be running.  I 
just want to make sure that it doesn't get re-run when we return back to the 
interrupted context or get rescheduled to if it was sleeping at the time we 
took the machine check.

> IOW you are assuming that the OP is currently running on this cpu.  If
> the OP is already stopped, what sends a signal to the OP?

The machine check interrupt handler or worker thread that I also mentioned (at 
least that's what I was trying to get at).

> My earlier suggestion of setting TIF_SIGNAL_MCA on both the OP and the
> current process handles both cases.  Whether it is running or stopped,
> the next return from kernel on this cpu will send the signal.  And we
> get that check for free, adding another TIF flag has no impact on the
> fast path for ia64_leave_kernel.

Yeah, that sounds like it would work too, and would probably be simpler.

Thanks,
Jesse
