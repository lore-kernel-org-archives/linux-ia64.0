From: Keith Owens <kaos@sgi.com>
Date: Tue, 07 Dec 2004 01:29:22 +0000
Subject: Re: [RFC] I/O error handling for userspace
Message-Id: <5098.1102382962@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412030831.25662.jbarnes@engr.sgi.com>
In-Reply-To: <200412030831.25662.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 6 Dec 2004 16:40:28 -0800, 
Jesse Barnes <jbarnes@engr.sgi.com> wrote:
>On Monday, December 6, 2004 4:38 pm, Keith Owens wrote:
>> >We need to do a few things in order to ensure safety (this should apply to
>> > the double bit memory error case too I think):
>> >  o make sure the process doesn't run until we've tried to recover from
>> > the error
>> >  o don't take any locks while we're in machine check context
>> >  o don't destroy our current context since we may want to resume to it
>> >    eventually (esp. in the case where we received the machine check in
>> > kernel context)
>> >
>> >So, given the above, maybe we could put the process in a TASK_STOPPED
>> > state and pend a scheduler tick on the CPU where we took the machine
>> > check? that point, we could also wake up an MCA worker thread or raise an
>> > MCA interrupt (maybe using the NMI interrupt vector, it's high priority
>> > and isn't used right now) to send the signal or do whatever cleanup was
>> > needed.
>>
>> You seem to be assuming that the offending process is currently
>> running.  I don't see how that is guaranteed, the task could start the
>> I/O then sleep waiting for completion.  When the MCA arrives, any task
>> could be in control of the cpu, including the idle task.
>
>No, I just left that part out.  For the case of I/O reads (and even memory 
>errors) we have a reverse mapping from the failing address to its owning 
>process, so we can figure out who to signal from any context.  What I'd like 
>to avoid is destroying the current context, like we do in the double bit 
>error case now when we recover into the mca bh handler.

I understand that you know the pid of the offending process (OP), that
is not my concern.  Your comment "put the process in a TASK_STOPPED
state and pend a scheduler tick on the CPU where we took the machine
check" assumes that sending a scheduler tick will reschedule the OP.
IOW you are assuming that the OP is currently running on this cpu.  If
the OP is already stopped, what sends a signal to the OP?

My earlier suggestion of setting TIF_SIGNAL_MCA on both the OP and the
current process handles both cases.  Whether it is running or stopped,
the next return from kernel on this cpu will send the signal.  And we
get that check for free, adding another TIF flag has no impact on the
fast path for ia64_leave_kernel.

