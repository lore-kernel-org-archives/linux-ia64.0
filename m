From: Jack Steiner <steiner@sgi.com>
Date: Thu, 19 Oct 2006 21:29:43 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061019212943.GB22721@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 19, 2006 at 02:22:41PM -0700, Luck, Tony wrote:
> > I don't think this is going to work for the simple reason that perfmon supports per-thread
> > monitoring. As a thread migrates from one CPU to another, its PMU state migrates with it.
> > So you cannot reload a full Montecito state onto a Madison PMU. You will not crash, because
> > write to unimplemented PMD are ignored but you will get false results. Even in system-wide
> > tools are not prepare to cope with mixed configurations.
> 
> Well you could do some ugly things forcing a sched_setaffinity-like call to prevent
> the task migrating to an incompatible cpu (but you'd also have to somehow make sure
> that the process didn't call sched_setaffinity() itself to undo this).
> 
> System wide sounds like an even bigger problem.
> 
> Forcing perfmon into "generic" mode sounds like a saner option.

The downside of this is that you loose much of the capabilities of perfmon. 

Is there a compromise where the kernel can detect that a migration has
occurred between unlike processor types and at that point, if non-generic
monitoring is being done, issue an error & disable performance monitoring.
Then users that play by the rules & run within (for example) cpusets
containing the same processor types can still use the full capabilities of
perfmon.


I agree that system-wide is a big problem.

-- jack
