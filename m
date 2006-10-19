From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 19 Oct 2006 21:52:05 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061019215205.GD22389@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Willy,

On Thu, Oct 19, 2006 at 03:21:37PM -0600, Matthew Wilcox wrote:
> On Thu, Oct 19, 2006 at 02:05:19PM -0700, Stephane Eranian wrote:
> > I don't think this is going to work for the simple reason that perfmon supports per-thread
> > monitoring. As a thread migrates from one CPU to another, its PMU state migrates with it.
> > So you cannot reload a full Montecito state onto a Madison PMU. You will not crash, because
> > write to unimplemented PMD are ignored but you will get false results. Even in system-wide
> > tools are not prepare to cope with mixed configurations.
> 
> I suppose you could lock a thread to running only on the kind of CPU it
> started running on.  It's not a great solution though.
> 

The problem is that some jobs, especially in scientific computing, rely on setting their
own affinity to achieve best performance. You don't know to affect this from within  the
kernel. Monitoring may start at the first user level instruction of a program. The scheduler
may pick a first CPU that may be different than the one that the application will want to go
with sched_affinity().


-- 
-Stephane
