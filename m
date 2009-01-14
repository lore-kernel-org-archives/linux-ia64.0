From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 14 Jan 2009 11:12:26 +0000
Subject: Re: [PATCH 0/9] ftrace: updates for tip
Message-Id: <20090114111226.GL2913@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090113061110.856268617@goodmis.org> <alpine.DEB.1.10.0901130905110.31098@gandalf.stny.rr.com> <alpine.DEB.1.10.0901131147310.9837@gandalf.stny.rr.com>
In-Reply-To: <alpine.DEB.1.10.0901131147310.9837@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, u.kleine-koenig@pengutronix.de


* Steven Rostedt <rostedt@goodmis.org> wrote:

> 
> On Tue, 13 Jan 2009, Steven Rostedt wrote:
> 
> > 
> > 
> > On Tue, 13 Jan 2009, Steven Rostedt wrote:
> > 
> > > 
> > > The following patches are in:
> > > 
> > >   git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git
> > > 
> > >     branch: tip/devel
> > 
> > Ingo,
> > 
> > Don't pull any of this yet please. I'm going to rebase some of the patches 
> > to fix the change logs (typos). I'll let you know when that's finished.
> > 
> 
> OK, I rebased in changing the change logs. Here's what I did:
> 
> s/destinct/distinct/
> s/K?nig/Koenig/
> 
> Here's the changes:
> 
> 
> The following patches are in:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git
> 
>     branch: tip/devel
> 
> 
> Frederic Weisbecker (2):
>       tracing/ftrace: separate events tracing and stats tracing engine
>       tracing: add a new workqueue tracer
> 
> Shaohua Li (6):
>       ftrace, ia64: make recordmcount distinct module compile
>       ftrace, ia64: explictly ignore a file in recordmcount.pl
>       ftrace, ia64: Add macro for ftrace_caller
>       ftrace, ia64: Add recordmcount for ia64
>       ftrace, ia64: IA64 static ftrace support
>       ftrace, ia64: IA64 dynamic ftrace support
> 
> Uwe Kleine-Koenig (1):
>       ftrace, trivial: fix typo "resgister" -> "register"
> 
> ----
>  arch/ia64/Kconfig              |    3 +
>  arch/ia64/include/asm/ftrace.h |   28 ++++
>  arch/ia64/kernel/Makefile      |    5 +
>  arch/ia64/kernel/entry.S       |  100 ++++++++++++++
>  arch/ia64/kernel/ftrace.c      |  206 ++++++++++++++++++++++++++++
>  arch/ia64/kernel/ia64_ksyms.c  |    6 +
>  include/linux/ftrace.h         |    4 +
>  include/trace/workqueue.h      |   25 ++++
>  kernel/trace/Kconfig           |   11 ++
>  kernel/trace/Makefile          |    1 +
>  kernel/trace/ftrace.c          |   14 +--
>  kernel/trace/trace.c           |    2 -
>  kernel/trace/trace.h           |   20 ---
>  kernel/trace/trace_branch.c    |  108 +++++++++-------
>  kernel/trace/trace_stat.c      |  191 +++++++++++---------------
>  kernel/trace/trace_stat.h      |   31 +++++
>  kernel/trace/trace_workqueue.c |  287 ++++++++++++++++++++++++++++++++++++++++
>  kernel/workqueue.c             |   16 ++-
>  scripts/Makefile.build         |   13 +-
>  scripts/recordmcount.pl        |   18 ++-
>  20 files changed, 888 insertions(+), 201 deletions(-)

pulled into tip/tracing/ftrace, thanks Steve!

	Ingo
