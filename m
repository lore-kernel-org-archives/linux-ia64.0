From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 07 Dec 2004 00:40:28 +0000
Subject: Re: [RFC] I/O error handling for userspace
Message-Id: <200412061640.28787.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412030831.25662.jbarnes@engr.sgi.com>
In-Reply-To: <200412030831.25662.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, December 6, 2004 4:38 pm, Keith Owens wrote:
> >We need to do a few things in order to ensure safety (this should apply to
> > the double bit memory error case too I think):
> >  o make sure the process doesn't run until we've tried to recover from
> > the error
> >  o don't take any locks while we're in machine check context
> >  o don't destroy our current context since we may want to resume to it
> >    eventually (esp. in the case where we received the machine check in
> > kernel context)
> >
> >So, given the above, maybe we could put the process in a TASK_STOPPED
> > state and pend a scheduler tick on the CPU where we took the machine
> > check? that point, we could also wake up an MCA worker thread or raise an
> > MCA interrupt (maybe using the NMI interrupt vector, it's high priority
> > and isn't used right now) to send the signal or do whatever cleanup was
> > needed.
>
> You seem to be assuming that the offending process is currently
> running.  I don't see how that is guaranteed, the task could start the
> I/O then sleep waiting for completion.  When the MCA arrives, any task
> could be in control of the cpu, including the idle task.

No, I just left that part out.  For the case of I/O reads (and even memory 
errors) we have a reverse mapping from the failing address to its owning 
process, so we can figure out who to signal from any context.  What I'd like 
to avoid is destroying the current context, like we do in the double bit 
error case now when we recover into the mca bh handler.

Jesse
