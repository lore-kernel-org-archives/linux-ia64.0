From: Keith Owens <kaos@sgi.com>
Date: Tue, 07 Dec 2004 00:38:00 +0000
Subject: Re: [RFC] I/O error handling for userspace
Message-Id: <27858.1102379880@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412030831.25662.jbarnes@engr.sgi.com>
In-Reply-To: <200412030831.25662.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 6 Dec 2004 14:56:58 -0800, 
Jesse Barnes <jbarnes@engr.sgi.com> wrote:
>On Monday, December 6, 2004 9:05 am, Jesse Barnes wrote:
>> This is the only bit I'm unsure about.  I can't just add a spin_trylock
>> version, since the call path for send_sig_info calls the slab allocator,
>> which takes other locks.
>>
>> Assuming that only the CPU that caused the MCA is in the MCA handler
>> (i.e. rendezvous doesn't occur), then the only time that one of the
>> spinlocks could hang is if the current CPU also owned it, right?  Hmm,
>> maybe the ia64_spinlock_contention routine could check for a machine
>> check condition and promote the failure to an uncorrectable one in that
>> case?  That's pretty ugly though...
>
>This is tricky.  If we want I/O error handling to be 100% reliable when I/O 
>errors are caused by userspace applications, we need to deal with the case 
>where the offending process' machine check is received in either user or 
>kernel mode, regardless of what context we're currently in.  My code assumes 
>that we receive the machine check in user mode and so the force_sig_info is 
>safe, but obviously that won't always be the case.
>
>We need to do a few things in order to ensure safety (this should apply to the 
>double bit memory error case too I think):
>  o make sure the process doesn't run until we've tried to recover from the
>    error
>  o don't take any locks while we're in machine check context
>  o don't destroy our current context since we may want to resume to it
>    eventually (esp. in the case where we received the machine check in kernel
>    context)
>
>So, given the above, maybe we could put the process in a TASK_STOPPED state 
>and pend a scheduler tick on the CPU where we took the machine check?
>that point, we could also wake up an MCA worker thread or raise an MCA 
>interrupt (maybe using the NMI interrupt vector, it's high priority and isn't 
>used right now) to send the signal or do whatever cleanup was needed.

You seem to be assuming that the offending process is currently
running.  I don't see how that is guaranteed, the task could start the
I/O then sleep waiting for completion.  When the MCA arrives, any task
could be in control of the cpu, including the idle task.

