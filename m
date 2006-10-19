From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 19 Oct 2006 21:22:41 +0000
Subject: RE: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <617E1C2C70743745A92448908E030B2AAE14B1@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I don't think this is going to work for the simple reason that perfmon supports per-thread
> monitoring. As a thread migrates from one CPU to another, its PMU state migrates with it.
> So you cannot reload a full Montecito state onto a Madison PMU. You will not crash, because
> write to unimplemented PMD are ignored but you will get false results. Even in system-wide
> tools are not prepare to cope with mixed configurations.

Well you could do some ugly things forcing a sched_setaffinity-like call to prevent
the task migrating to an incompatible cpu (but you'd also have to somehow make sure
that the process didn't call sched_setaffinity() itself to undo this).

System wide sounds like an even bigger problem.

Forcing perfmon into "generic" mode sounds like a saner option.

-Tony
