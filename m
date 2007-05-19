From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Sat, 19 May 2007 02:26:38 +0000
Subject: Re: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <ed5aea430705181926q1f29ddfpefac75221d7b472b@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't think the original patch solves the problem.  The issue is
that even if a task is stopped at the time unwinding is initiated, it
may be resumed later on (e.g., by another CPU), so the unwinding MUST
be safe even on a running task.  get_wchan() unwinding the currently
running task is a special case, but fixing just that special case will
only make it harder to debug and fix the fundamental bug later on.

August 2005 sounds about right, I'm afraid.  I'd love to update the
patch, but with Summer travel coming up etc., it won't happen before
July, for sure.  It would be best if somebody else could champion the
libunwind-in-the-kernel effort.  It's really needed but my time
available for this project will remain spotty for a while...

  --david

On 5/18/07, Luck, Tony <tony.luck@intel.com> wrote:
> If the problem *only* occurs when trying to get_wchan on the
> current task (a futile endevour) then the original patch
> should be fine all by itself ... there are no races involved
> the current task is going to remain in TASK_RUNNING state at
> any point that it happens to look at itself.
>
> A quick scan of my e-mail archives shows an updated libunwind
> patch from you dated August 2005 ... which is a lot more than
> a couple of months ago :-) I assume that I've missed some more
> recent posting.
>
> -Tony
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
