From: Robin Holt <holt@sgi.com>
Date: Thu, 12 Feb 2004 22:17:52 +0000
Subject: Re: How do I raise a thread to realtime priority?
Message-Id: <20040212221752.GA16976@lnx-holt>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040212215357.GA15214@lnx-holt>
In-Reply-To: <20040212215357.GA15214@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 12, 2004 at 10:08:20PM +0000, Matthew Wilcox wrote:
> On Thu, Feb 12, 2004 at 03:53:57PM -0600, Robin Holt wrote:
> > In the 2.4 kernel headers, unistd.h had a _syscall3 that I could
> > use to make an extern of the sys_sched_setscheduler raise a tasks
> > priority to realtime.  With 2.6, the _syscall3 has been replaced
> > with static inlines.  This all seems well.
> > 
> > Since sys_sched_setscheduler is not in the unistd.h, should I add
> > it to unistd.h?  Is there a prefered method for exporting/inlining
> > syscall entry points?
> 
> libc "exports syscall entry points" -- call sched_setscheduler().
> That works on 2.4 and 2.6.

Maybe I wasn't clear.  This is a kernel thread that is trying to
raise priority.
