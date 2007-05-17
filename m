From: Robin Holt <holt@sgi.com>
Date: Thu, 17 May 2007 13:00:07 +0000
Subject: Re: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <20070517130007.GA4383@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 17, 2007 at 09:38:59PM +1000, Keith Owens wrote:
> Robin Holt (on Thu, 17 May 2007 06:16:52 -0500) wrote:
...
> AFAICT there is no lock on struct task_struct p that stops it being
> scheduled to run after you test if it is running.  proc_task_lookup()
> only does get_task_struct() which prevents the task from being deleted,
> it does not prevent the task from being scheduled while you are looking
> at it.
> 
> So even with that check, it can race between not running and running
> while you do the unwind, and still get the MCA.

I realized the problem, but don't see an easy fix.  I think the hope
is we would be far enough back in the call trace so that portion of the
stack would be constant.

To me, this still seems like a reasonable check.  Do you object to
this patch or are you just pointing out the hole.  I see the other
architectures have the same problem.  Would you suggest repeating the
check before each call to unw_unwind()?

Thanks,
Robin
