From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 15 Nov 2005 20:21:15 +0000
Subject: Re: Question about interrupt enabling/disabling in kernel exit path
Message-Id: <1132086075.5230.23.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131559925.5214.100.camel@localhost.localdomain>
In-Reply-To: <1131559925.5214.100.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-11-14 at 13:52 -0800, David Mosberger-Tang wrote:
> > Then I notice that after we return from do_notify_resume_user() we don't
> > recheck TIF_NEED_RESCHED, etc. in the thread_info flags.
> 
> Why do you say this?  It's not true.  After processing pending work,
> we go back to .work_processed_{syscall,kernel), which will again
> invoke .work_pending, if necessary.

OK.  I guess I'm misinterpreting the comments on the line labeled
'.ret10:'.
Say's it's setting p6 to zero, so no recheck.  I'm not fluent [writing
nor reading] ia64 assembler, but it appeared to me that with p6 set to
zero on return from notify_resume(), the checks for more work back
at .work_processed_* would be disabled.

Are the comments at the ia64_leave_kernel entry point stale?

> 
> AFAIR, it's OK to reenable interrupts in notify_resume_user() because
> we know we're at the top of the kernel stack (i.e., there is no risk
> of nesting the kernel stack too deeply due to pending interrupts),
> provided the interrupts are off again when resuming execution at
> .work_processed_kernel.

OK.  Ken said he thought it was OK to disable.  And Stephane mentioned
that he's seen interrupts enabled when entering do_notify_resume_user()
as well.

Thanks,
Lee

